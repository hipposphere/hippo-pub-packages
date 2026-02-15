import 'dart:async';
import 'dart:typed_data';

import 'package:hippo_bluetooth_client/hippo_bluetooth_client.dart';

class FakeBleGattClient implements BleGattClient {
  @override
  Duration defaultOperationTimeout;

  FakeBleGattClient({
    this.defaultOperationTimeout = const Duration(seconds: 3),
  });

  bool failConnect = false;
  int mtuValue = 185;
  int discoverServicesCalls = 0;

  final Map<String, List<BleServiceInfo>> servicesByRemoteId =
      <String, List<BleServiceInfo>>{};
  final Map<String, Uint8List> readValues = <String, Uint8List>{};
  final List<BleWriteRecord> writes = <BleWriteRecord>[];

  final Map<String, BleConnectionState> _stateByRemoteId =
      <String, BleConnectionState>{};
  final Map<String, StreamController<BleConnectionState>> _stateControllers =
      <String, StreamController<BleConnectionState>>{};
  final Map<String, StreamController<Uint8List>> _notificationControllers =
      <String, StreamController<Uint8List>>{};

  @override
  Stream<BleScanResult> scan({
    List<String> withServiceUuids = const [],
    Duration? timeout,
  }) {
    return const Stream<BleScanResult>.empty();
  }

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> connect(
    String remoteId, {
    Duration? timeout,
    bool autoConnect = false,
    int? mtu,
  }) async {
    if (failConnect) {
      throw const ConnectionError('connect failed');
    }
    _stateByRemoteId[remoteId] = BleConnectionState.connected;
    _stateController(remoteId).add(BleConnectionState.connected);
  }

  @override
  Future<void> disconnect(String remoteId, {Duration? timeout}) async {
    _stateByRemoteId[remoteId] = BleConnectionState.disconnected;
    _stateController(remoteId).add(BleConnectionState.disconnected);
  }

  @override
  Stream<BleConnectionState> observeConnectionState(String remoteId) async* {
    yield _stateByRemoteId[remoteId] ?? BleConnectionState.disconnected;
    yield* _stateController(remoteId).stream;
  }

  @override
  Future<List<BleServiceInfo>> discoverServices(
    String remoteId, {
    Duration? timeout,
  }) async {
    discoverServicesCalls += 1;
    return servicesByRemoteId[remoteId] ?? const <BleServiceInfo>[];
  }

  @override
  Future<Uint8List> readCharacteristic(
    BleCharacteristicRef characteristic, {
    Duration? timeout,
  }) async {
    final key = _fullKey(characteristic);
    final value = readValues[key];
    if (value == null) {
      throw ProtocolError('No fake read value for $key');
    }
    return Uint8List.fromList(value);
  }

  @override
  Future<void> writeCharacteristic(
    BleCharacteristicRef characteristic,
    Uint8List value, {
    bool withoutResponse = false,
    Duration? timeout,
  }) async {
    writes.add(
      BleWriteRecord(
        characteristic: characteristic,
        value: value,
        withoutResponse: withoutResponse,
      ),
    );
  }

  @override
  Stream<Uint8List> subscribeToCharacteristic(
    BleCharacteristicRef characteristic, {
    bool emitCurrentValue = false,
    Duration? timeout,
  }) async* {
    final key = _fullKey(characteristic);
    if (emitCurrentValue) {
      final cached = readValues[key];
      if (cached != null) {
        yield Uint8List.fromList(cached);
      }
    }
    yield* _notificationController(characteristic).stream;
  }

  @override
  int mtuNow(String remoteId) => mtuValue;

  @override
  Future<void> dispose() async {
    for (final controller in _stateControllers.values) {
      await controller.close();
    }
    for (final controller in _notificationControllers.values) {
      await controller.close();
    }
    _stateControllers.clear();
    _notificationControllers.clear();
  }

  void setReadValue(BleCharacteristicRef characteristic, Uint8List value) {
    readValues[_fullKey(characteristic)] = Uint8List.fromList(value);
  }

  void emitNotification(BleCharacteristicRef characteristic, Uint8List value) {
    _notificationController(characteristic).add(Uint8List.fromList(value));
  }

  StreamController<BleConnectionState> _stateController(String remoteId) {
    return _stateControllers.putIfAbsent(
      remoteId,
      () => StreamController<BleConnectionState>.broadcast(),
    );
  }

  StreamController<Uint8List> _notificationController(
    BleCharacteristicRef characteristic,
  ) {
    return _notificationControllers.putIfAbsent(
      _fullKey(characteristic),
      () => StreamController<Uint8List>.broadcast(),
    );
  }

  String _fullKey(BleCharacteristicRef characteristic) {
    return '${characteristic.remoteId}|${characteristic.cacheKey}';
  }
}
