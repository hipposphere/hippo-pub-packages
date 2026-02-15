import 'dart:typed_data';

/// Connection states exposed by the low-level client.
enum BleConnectionState {
  /// Unknown state.
  unknown,

  /// Device is currently disconnected.
  disconnected,

  /// Device is currently connecting.
  connecting,

  /// Device is currently connected.
  connected,

  /// Device is currently disconnecting.
  disconnecting,
}

/// Lightweight scan result abstraction independent from the BLE backend.
class BleScanResult {
  /// Device identifier (MAC on Android, UUID on iOS).
  final String remoteId;

  /// Best available display name for this device.
  final String name;

  /// RSSI from scan advertisement.
  final int rssi;

  /// Whether the advertisement is connectable.
  final bool connectable;

  /// Creates a new [BleScanResult].
  const BleScanResult({
    required this.remoteId,
    required this.name,
    required this.rssi,
    required this.connectable,
  });
}

/// Characteristic capabilities.
class BleCharacteristicProperties {
  /// Supports `read`.
  final bool read;

  /// Supports `write` with response.
  final bool write;

  /// Supports `write` without response.
  final bool writeWithoutResponse;

  /// Supports notifications.
  final bool notify;

  /// Supports indications.
  final bool indicate;

  /// Creates [BleCharacteristicProperties].
  const BleCharacteristicProperties({
    this.read = false,
    this.write = false,
    this.writeWithoutResponse = false,
    this.notify = false,
    this.indicate = false,
  });

  /// Returns true if this characteristic supports any write mode.
  bool get canWrite => write || writeWithoutResponse;

  /// Returns true if this characteristic can push updates.
  bool get canNotify => notify || indicate;
}

/// Characteristic metadata discovered from a service.
class BleCharacteristicInfo {
  /// Characteristic UUID.
  final String uuid;

  /// Backend instance id to disambiguate duplicated UUIDs.
  final int instanceId;

  /// Characteristic properties.
  final BleCharacteristicProperties properties;

  /// Creates [BleCharacteristicInfo].
  const BleCharacteristicInfo({
    required this.uuid,
    this.instanceId = 0,
    required this.properties,
  });
}

/// Service metadata with child characteristics.
class BleServiceInfo {
  /// Service UUID.
  final String uuid;

  /// Primary service UUID for included/secondary services.
  final String? primaryServiceUuid;

  /// Characteristics in this service.
  final List<BleCharacteristicInfo> characteristics;

  /// Creates [BleServiceInfo].
  const BleServiceInfo({
    required this.uuid,
    this.primaryServiceUuid,
    required this.characteristics,
  });
}

/// Reference to a characteristic bound to a specific remote device.
class BleCharacteristicRef {
  /// Target remote device id.
  final String remoteId;

  /// Service UUID.
  final String serviceUuid;

  /// Characteristic UUID.
  final String characteristicUuid;

  /// Optional primary service UUID for secondary services.
  final String? primaryServiceUuid;

  /// Backend instance id.
  final int instanceId;

  /// Creates [BleCharacteristicRef].
  const BleCharacteristicRef({
    required this.remoteId,
    required this.serviceUuid,
    required this.characteristicUuid,
    this.primaryServiceUuid,
    this.instanceId = 0,
  });

  /// Stable map key for cache lookups.
  String get cacheKey =>
      '${_normalize(primaryServiceUuid)}|${_normalize(serviceUuid)}|${_normalize(characteristicUuid)}|$instanceId';

  static String _normalize(String? value) => value?.toLowerCase() ?? '';
}

/// Runtime write metadata emitted by fakes/tests and optional instrumentation.
class BleWriteRecord {
  /// Written characteristic reference.
  final BleCharacteristicRef characteristic;

  /// Written bytes.
  final Uint8List value;

  /// Whether write was sent without response.
  final bool withoutResponse;

  /// Creates [BleWriteRecord].
  BleWriteRecord({
    required this.characteristic,
    required Uint8List value,
    required this.withoutResponse,
  }) : value = Uint8List.fromList(value);
}
