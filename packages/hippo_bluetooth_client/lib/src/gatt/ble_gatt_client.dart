import 'dart:typed_data';

import 'ble_types.dart';

/// Low-level BLE GATT client abstraction.
///
/// This wraps scanning, connect/disconnect, service discovery, and
/// characteristic IO behind a backend-agnostic contract for easier testing.
abstract interface class BleGattClient {
  /// Default timeout used for operations unless explicitly overridden.
  Duration get defaultOperationTimeout;

  /// Scans for BLE devices.
  ///
  /// Returns a stream of discovered devices. The scan continues until
  /// [stopScan] is called or until backend timeout behavior stops scanning.
  Stream<BleScanResult> scan({
    List<String> withServiceUuids = const [],
    Duration? timeout,
  });

  /// Stops an active scan.
  Future<void> stopScan();

  /// Connects to a remote device.
  Future<void> connect(
    String remoteId, {
    Duration? timeout,
    bool autoConnect = false,
    int? mtu,
  });

  /// Disconnects from a remote device.
  Future<void> disconnect(String remoteId, {Duration? timeout});

  /// Observes connection state updates for [remoteId].
  Stream<BleConnectionState> observeConnectionState(String remoteId);

  /// Discovers services and characteristics for [remoteId].
  Future<List<BleServiceInfo>> discoverServices(
    String remoteId, {
    Duration? timeout,
  });

  /// Reads bytes from a characteristic.
  Future<Uint8List> readCharacteristic(
    BleCharacteristicRef characteristic, {
    Duration? timeout,
  });

  /// Writes bytes to a characteristic.
  Future<void> writeCharacteristic(
    BleCharacteristicRef characteristic,
    Uint8List value, {
    bool withoutResponse = false,
    Duration? timeout,
  });

  /// Subscribes to characteristic notifications/indications.
  Stream<Uint8List> subscribeToCharacteristic(
    BleCharacteristicRef characteristic, {
    bool emitCurrentValue = false,
    Duration? timeout,
  });

  /// Returns the last known MTU for [remoteId].
  int mtuNow(String remoteId);

  /// Releases resources and active subscriptions.
  Future<void> dispose();
}
