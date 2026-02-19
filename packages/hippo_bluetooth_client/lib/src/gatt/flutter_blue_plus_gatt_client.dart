import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../errors.dart';
import 'ble_gatt_client.dart';
import 'ble_types.dart';

/// [BleGattClient] implementation backed by `flutter_blue_plus`.
class FlutterBluePlusGattClient implements BleGattClient {
  /// Creates a new client.
  FlutterBluePlusGattClient({
    this.license = License.free,
    this.defaultOperationTimeout = const Duration(seconds: 15),
  });

  /// License type required by `flutter_blue_plus`.
  final License license;

  @override
  final Duration defaultOperationTimeout;

  final Map<String, Map<String, BluetoothCharacteristic>>
  _characteristicsByDevice = <String, Map<String, BluetoothCharacteristic>>{};
  final Map<String, StreamSubscription<BluetoothConnectionState>>
  _connectionSubscriptions =
      <String, StreamSubscription<BluetoothConnectionState>>{};

  @override
  Stream<BleScanResult> scan({
    List<String> withServiceUuids = const [],
    Duration? timeout,
  }) async* {
    try {
      await FlutterBluePlus.startScan(
        withServices: withServiceUuids.map(Guid.new).toList(growable: false),
        timeout: timeout,
      );
    } on Object catch (error, stackTrace) {
      throw ConnectionError(
        'Failed to start scan',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    yield* FlutterBluePlus.onScanResults
        .expand((entries) => entries)
        .map(
          (scanResult) => BleScanResult(
            remoteId: scanResult.device.remoteId.str,
            name: scanResult.device.platformName.isNotEmpty
                ? scanResult.device.platformName
                : scanResult.advertisementData.advName,
            rssi: scanResult.rssi,
            connectable: scanResult.advertisementData.connectable,
          ),
        );
  }

  @override
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } on Object catch (error, stackTrace) {
      throw ConnectionError(
        'Failed to stop scan',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> connect(
    String remoteId, {
    Duration? timeout,
    bool autoConnect = false,
    int? mtu,
  }) async {
    final opTimeout = timeout ?? defaultOperationTimeout;
    final device = _device(remoteId);

    try {
      await device.connect(
        license: license,
        timeout: opTimeout,
        autoConnect: autoConnect,
        mtu: autoConnect ? null : mtu,
      );
    } on Object catch (error, stackTrace) {
      throw ConnectionError(
        'Failed to connect to $remoteId',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    _connectionSubscriptions[remoteId] ??= device.connectionState.listen((
      state,
    ) {
      if (state == BluetoothConnectionState.disconnected) {
        _characteristicsByDevice.remove(remoteId);
      }
    });
  }

  @override
  Future<void> disconnect(String remoteId, {Duration? timeout}) async {
    final opTimeout = timeout ?? defaultOperationTimeout;
    try {
      await _device(remoteId).disconnect(timeout: _timeoutSeconds(opTimeout));
      _characteristicsByDevice.remove(remoteId);
    } on Object catch (error, stackTrace) {
      throw ConnectionError(
        'Failed to disconnect $remoteId',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Stream<BleConnectionState> observeConnectionState(String remoteId) {
    return _device(
      remoteId,
    ).connectionState.map(_mapConnectionState).distinct();
  }

  @override
  Future<List<BleServiceInfo>> discoverServices(
    String remoteId, {
    Duration? timeout,
  }) async {
    final opTimeout = timeout ?? defaultOperationTimeout;
    final device = _device(remoteId);

    final services = await _withConnectionError(
      'discover services on $remoteId',
      () => device.discoverServices(timeout: _timeoutSeconds(opTimeout)),
    );

    final characteristics = <String, BluetoothCharacteristic>{};
    final out = <BleServiceInfo>[];
    for (final service in services) {
      out.add(
        BleServiceInfo(
          uuid: service.serviceUuid.str,
          primaryServiceUuid: service.primaryServiceUuid?.str,
          characteristics: service.characteristics
              .map((characteristic) {
                final ref = BleCharacteristicRef(
                  remoteId: remoteId,
                  primaryServiceUuid: characteristic.primaryServiceUuid?.str,
                  serviceUuid: characteristic.serviceUuid.str,
                  characteristicUuid: characteristic.characteristicUuid.str,
                  instanceId: characteristic.instanceId,
                );
                characteristics[ref.cacheKey] = characteristic;
                final properties = characteristic.properties;
                return BleCharacteristicInfo(
                  uuid: characteristic.characteristicUuid.str,
                  instanceId: characteristic.instanceId,
                  properties: BleCharacteristicProperties(
                    read: properties.read,
                    write: properties.write,
                    writeWithoutResponse: properties.writeWithoutResponse,
                    notify: properties.notify,
                    indicate: properties.indicate,
                  ),
                );
              })
              .toList(growable: false),
        ),
      );
    }

    _characteristicsByDevice[remoteId] = characteristics;
    return out;
  }

  @override
  Future<Uint8List> readCharacteristic(
    BleCharacteristicRef characteristic, {
    Duration? timeout,
  }) async {
    final opTimeout = timeout ?? defaultOperationTimeout;
    final resolved = await _resolveCharacteristic(
      characteristic,
      timeout: opTimeout,
    );
    final bytes = await _withConnectionError(
      'read characteristic ${characteristic.characteristicUuid}',
      () => resolved.read(timeout: _timeoutSeconds(opTimeout)),
    );
    return Uint8List.fromList(bytes);
  }

  @override
  Future<void> writeCharacteristic(
    BleCharacteristicRef characteristic,
    Uint8List value, {
    bool withoutResponse = false,
    Duration? timeout,
  }) async {
    final opTimeout = timeout ?? defaultOperationTimeout;
    final resolved = await _resolveCharacteristic(
      characteristic,
      timeout: opTimeout,
    );
    await _withConnectionError(
      'write characteristic ${characteristic.characteristicUuid}',
      () => resolved.write(
        value,
        withoutResponse: withoutResponse,
        timeout: _timeoutSeconds(opTimeout),
      ),
    );
  }

  @override
  Stream<Uint8List> subscribeToCharacteristic(
    BleCharacteristicRef characteristic, {
    bool emitCurrentValue = false,
    Duration? timeout,
  }) async* {
    final opTimeout = timeout ?? defaultOperationTimeout;
    final resolved = await _resolveCharacteristic(
      characteristic,
      timeout: opTimeout,
    );

    await _withConnectionError(
      'enable notifications for ${characteristic.characteristicUuid}',
      () => resolved.setNotifyValue(true, timeout: _timeoutSeconds(opTimeout)),
    );

    try {
      final source = emitCurrentValue
          ? resolved.lastValueStream
          : resolved.onValueReceived;
      yield* source.map(Uint8List.fromList);
    } finally {
      try {
        await resolved.setNotifyValue(
          false,
          timeout: _timeoutSeconds(opTimeout),
        );
      } on Object {
        // Best-effort cleanup.
      }
    }
  }

  @override
  int mtuNow(String remoteId) => _device(remoteId).mtuNow;

  @override
  Future<void> dispose() async {
    for (final subscription in _connectionSubscriptions.values) {
      await subscription.cancel();
    }
    _connectionSubscriptions.clear();
    _characteristicsByDevice.clear();
  }

  BluetoothDevice _device(String remoteId) => BluetoothDevice.fromId(remoteId);

  int _timeoutSeconds(Duration timeout) {
    if (timeout <= Duration.zero) {
      return 1;
    }
    final microseconds = timeout.inMicroseconds;
    return (microseconds / Duration.microsecondsPerSecond).ceil();
  }

  BleConnectionState _mapConnectionState(BluetoothConnectionState input) {
    if (input == BluetoothConnectionState.connected) {
      return BleConnectionState.connected;
    }
    if (input == BluetoothConnectionState.disconnected) {
      return BleConnectionState.disconnected;
    }
    return BleConnectionState.unknown;
  }

  Future<BluetoothCharacteristic> _resolveCharacteristic(
    BleCharacteristicRef ref, {
    required Duration timeout,
  }) async {
    final byDevice = _characteristicsByDevice[ref.remoteId];
    final cached = byDevice?[ref.cacheKey];
    if (cached != null) {
      return cached;
    }

    await discoverServices(ref.remoteId, timeout: timeout);

    final discovered = _characteristicsByDevice[ref.remoteId]?[ref.cacheKey];
    if (discovered != null) {
      return discovered;
    }

    throw ProtocolError(
      'Characteristic ${ref.characteristicUuid} not found on ${ref.remoteId}. '
      'Call discoverServices() after connect.',
    );
  }

  Future<T> _withConnectionError<T>(
    String action,
    Future<T> Function() run,
  ) async {
    try {
      return await run();
    } on Object catch (error, stackTrace) {
      throw ConnectionError(
        'Failed to $action',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
