import 'dart:convert';

const supportedBleContractVersion = '1.0.0';

const Set<String> supportedCharacteristicProperties = <String>{
  'read',
  'write',
  'writeWithoutResponse',
  'notify',
  'indicate',
};

const Set<String> supportedChannelCodecs = <String>{'bytes', 'utf8', 'jsonMap'};

enum BleContractSourceKind { services, protocols }

class BleContractInfo {
  final String title;
  final String version;
  final String generatedAt;
  final String? description;

  const BleContractInfo({
    required this.title,
    required this.version,
    required this.generatedAt,
    this.description,
  });
}

class BleContractCharacteristic {
  final String? id;
  final String uuid;
  final List<String> properties;
  final String? codec;

  const BleContractCharacteristic({
    required this.id,
    required this.uuid,
    required this.properties,
    this.codec,
  });

  bool get canRead => properties.contains('read');

  bool get canWriteWithResponse => properties.contains('write');

  bool get canWriteWithoutResponse => properties.contains('writeWithoutResponse');

  bool get canNotify => properties.contains('notify') || properties.contains('indicate');
}

class BleContractService {
  final String? id;
  final String uuid;
  final bool advertise;
  final List<BleContractCharacteristic> characteristics;

  const BleContractService({
    required this.id,
    required this.uuid,
    required this.advertise,
    required this.characteristics,
  });
}

class BleContractDocument {
  final String bleContract;
  final BleContractInfo info;
  final BleContractSourceKind sourceKind;
  final List<BleContractService> services;

  const BleContractDocument({
    required this.bleContract,
    required this.info,
    required this.sourceKind,
    required this.services,
  });
}

class ResolvedBleContract {
  final BleContractDocument document;
  final List<ResolvedBleContractService> services;

  const ResolvedBleContract({required this.document, required this.services});
}

class ResolvedBleContractService {
  final String id;
  final String uuid;
  final bool advertise;
  final List<ResolvedBleContractCharacteristic> characteristics;

  const ResolvedBleContractService({
    required this.id,
    required this.uuid,
    required this.advertise,
    required this.characteristics,
  });
}

class ResolvedBleContractCharacteristic {
  final String id;
  final String uuid;
  final List<String> properties;
  final String? codec;

  const ResolvedBleContractCharacteristic({
    required this.id,
    required this.uuid,
    required this.properties,
    this.codec,
  });

  bool get canRead => properties.contains('read');

  bool get canWriteWithResponse => properties.contains('write');

  bool get canWriteWithoutResponse => properties.contains('writeWithoutResponse');

  bool get canNotify => properties.contains('notify') || properties.contains('indicate');
}

BleContractDocument parseBleContractJsonString(String source) {
  final decoded = jsonDecode(source);
  return parseBleContractJsonObject(decoded);
}

BleContractDocument parseBleContractJsonObject(Object? root) {
  final rootMap = _asObjectMap(root, 'root');

  final contractVersion = _readRequiredString(rootMap, 'bleContract', fieldName: 'bleContract');
  if (contractVersion != supportedBleContractVersion) {
    throw FormatException(
      "Unsupported bleContract version '$contractVersion'. "
      "Expected '$supportedBleContractVersion'.",
    );
  }

  final infoMap = _asObjectMap(rootMap['info'], 'info');
  final info = BleContractInfo(
    title: _readRequiredString(infoMap, 'title', fieldName: 'info.title'),
    version: _readRequiredString(infoMap, 'version', fieldName: 'info.version'),
    generatedAt: _readRequiredString(infoMap, 'generatedAt', fieldName: 'info.generatedAt'),
    description: _readOptionalString(infoMap, 'description', fieldName: 'info.description'),
  );

  final sourceMap = _asObjectMap(rootMap['source'], 'source');
  final sourceKindRaw = _readRequiredString(sourceMap, 'kind', fieldName: 'source.kind');
  final sourceKind = switch (sourceKindRaw) {
    'services' => BleContractSourceKind.services,
    'protocols' => BleContractSourceKind.protocols,
    _ => throw FormatException(
      "source.kind must be either 'services' or 'protocols', got '$sourceKindRaw'.",
    ),
  };

  final servicesList = _asObjectList(rootMap['services'], 'services');
  if (servicesList.isEmpty) {
    throw const FormatException('services must contain at least one item.');
  }

  final seenCharacteristicUuids = <String>{};
  final services = <BleContractService>[];

  for (var serviceIndex = 0; serviceIndex < servicesList.length; serviceIndex += 1) {
    final serviceMap = _asObjectMap(servicesList[serviceIndex], 'services[$serviceIndex]');

    final serviceId = _readOptionalString(
      serviceMap,
      'id',
      fieldName: 'services[$serviceIndex].id',
    );

    final serviceUuid = normalizeBleUuid(
      _readRequiredString(serviceMap, 'uuid', fieldName: 'services[$serviceIndex].uuid'),
      fieldName: 'services[$serviceIndex].uuid',
    );

    final advertiseRaw = serviceMap['advertise'];
    if (advertiseRaw is! bool) {
      throw FormatException('services[$serviceIndex].advertise must be a boolean.');
    }

    final characteristicsList = _asObjectList(
      serviceMap['characteristics'],
      'services[$serviceIndex].characteristics',
    );
    if (characteristicsList.isEmpty) {
      throw FormatException(
        'services[$serviceIndex].characteristics must contain at least one item.',
      );
    }

    final characteristics = <BleContractCharacteristic>[];
    for (
      var characteristicIndex = 0;
      characteristicIndex < characteristicsList.length;
      characteristicIndex += 1
    ) {
      final characteristicMap = _asObjectMap(
        characteristicsList[characteristicIndex],
        'services[$serviceIndex].characteristics[$characteristicIndex]',
      );

      final characteristicId = _readOptionalString(
        characteristicMap,
        'id',
        fieldName: 'services[$serviceIndex].characteristics[$characteristicIndex].id',
      );

      final characteristicUuid = normalizeBleUuid(
        _readRequiredString(
          characteristicMap,
          'uuid',
          fieldName: 'services[$serviceIndex].characteristics[$characteristicIndex].uuid',
        ),
        fieldName: 'services[$serviceIndex].characteristics[$characteristicIndex].uuid',
      );

      final characteristicCodec = _readOptionalString(
        characteristicMap,
        'codec',
        fieldName: 'services[$serviceIndex].characteristics[$characteristicIndex].codec',
      );
      if (characteristicCodec != null && !supportedChannelCodecs.contains(characteristicCodec)) {
        throw FormatException(
          'Unsupported channel codec '
          "'$characteristicCodec' in "
          'services[$serviceIndex].characteristics[$characteristicIndex].codec. '
          'Supported: ${supportedChannelCodecs.join(', ')}.',
        );
      }

      if (!seenCharacteristicUuids.add(characteristicUuid)) {
        throw FormatException(
          "Characteristic UUID '$characteristicUuid' is duplicated across services.",
        );
      }

      final rawProperties = characteristicMap['properties'];
      if (rawProperties is! List || rawProperties.isEmpty) {
        throw FormatException(
          'services[$serviceIndex].characteristics[$characteristicIndex].properties '
          'must contain at least one item.',
        );
      }
      final properties = <String>[];
      for (var propertyIndex = 0; propertyIndex < rawProperties.length; propertyIndex += 1) {
        final property = rawProperties[propertyIndex];
        if (property is! String || property.trim().isEmpty) {
          throw FormatException(
            'services[$serviceIndex].characteristics[$characteristicIndex].'
            'properties[$propertyIndex] must be a non-empty string.',
          );
        }
        final normalizedProperty = property.trim();
        if (!supportedCharacteristicProperties.contains(normalizedProperty)) {
          throw FormatException(
            'Unsupported characteristic property '
            "'$normalizedProperty' in "
            'services[$serviceIndex].characteristics[$characteristicIndex].'
            'properties[$propertyIndex]. '
            'Supported: ${supportedCharacteristicProperties.join(', ')}.',
          );
        }
        if (!properties.contains(normalizedProperty)) {
          properties.add(normalizedProperty);
        }
      }

      characteristics.add(
        BleContractCharacteristic(
          id: characteristicId,
          uuid: characteristicUuid,
          properties: List<String>.unmodifiable(properties),
          codec: characteristicCodec,
        ),
      );
    }

    services.add(
      BleContractService(
        id: serviceId,
        uuid: serviceUuid,
        advertise: advertiseRaw,
        characteristics: List<BleContractCharacteristic>.unmodifiable(characteristics),
      ),
    );
  }

  return BleContractDocument(
    bleContract: contractVersion,
    info: info,
    sourceKind: sourceKind,
    services: List<BleContractService>.unmodifiable(services),
  );
}

ResolvedBleContract resolveBleContract(BleContractDocument document) {
  final resolvedServices = <ResolvedBleContractService>[];
  final usedServiceIds = <String>{};

  for (var serviceIndex = 0; serviceIndex < document.services.length; serviceIndex += 1) {
    final service = document.services[serviceIndex];

    final baseServiceId = service.id ?? 'service_${_shortUuid(service.uuid)}';
    final serviceId = _resolveId(
      baseServiceId,
      usedServiceIds,
      autoGenerated: service.id == null,
      duplicateLabel: 'service id',
    );

    final resolvedCharacteristics = <ResolvedBleContractCharacteristic>[];
    final usedChannelIds = <String>{};
    for (
      var characteristicIndex = 0;
      characteristicIndex < service.characteristics.length;
      characteristicIndex += 1
    ) {
      final characteristic = service.characteristics[characteristicIndex];
      final baseChannelId = characteristic.id ?? 'channel_${_shortUuid(characteristic.uuid)}';
      final channelId = _resolveId(
        baseChannelId,
        usedChannelIds,
        autoGenerated: characteristic.id == null,
        duplicateLabel: "channel id in service '$serviceId'",
      );

      resolvedCharacteristics.add(
        ResolvedBleContractCharacteristic(
          id: channelId,
          uuid: characteristic.uuid,
          properties: characteristic.properties,
          codec: characteristic.codec,
        ),
      );
    }

    resolvedServices.add(
      ResolvedBleContractService(
        id: serviceId,
        uuid: service.uuid,
        advertise: service.advertise,
        characteristics: List<ResolvedBleContractCharacteristic>.unmodifiable(
          resolvedCharacteristics,
        ),
      ),
    );
  }

  return ResolvedBleContract(
    document: document,
    services: List<ResolvedBleContractService>.unmodifiable(resolvedServices),
  );
}

String normalizeBleUuid(String value, {required String fieldName}) {
  final rawValue = value.trim().toLowerCase();
  if (rawValue.isEmpty) {
    throw FormatException('$fieldName must not be empty.');
  }

  final compact = rawValue.replaceAll('-', '');
  final isValid = RegExp(r'^(?:[0-9a-f]{4}|[0-9a-f]{8}|[0-9a-f]{32})$').hasMatch(compact);
  if (!isValid) {
    throw FormatException(
      "Invalid UUID '$value' in $fieldName. Use 16-bit, 32-bit, or 128-bit UUIDs.",
    );
  }

  return compact;
}

String canonicalBleUuid(String compactUuid) {
  if (compactUuid.length == 32) {
    return '${compactUuid.substring(0, 8)}-'
        '${compactUuid.substring(8, 12)}-'
        '${compactUuid.substring(12, 16)}-'
        '${compactUuid.substring(16, 20)}-'
        '${compactUuid.substring(20)}';
  }
  return compactUuid;
}

String _resolveId(
  String id,
  Set<String> usedIds, {
  required bool autoGenerated,
  required String duplicateLabel,
}) {
  if (!usedIds.contains(id)) {
    usedIds.add(id);
    return id;
  }

  if (!autoGenerated) {
    throw FormatException("Duplicate $duplicateLabel '$id'.");
  }

  var suffix = 2;
  while (usedIds.contains('${id}_$suffix')) {
    suffix += 1;
  }
  final resolved = '${id}_$suffix';
  usedIds.add(resolved);
  return resolved;
}

String _shortUuid(String compactUuid) {
  return compactUuid.length <= 8 ? compactUuid : compactUuid.substring(0, 8);
}

Map<String, Object?> _asObjectMap(Object? value, String fieldName) {
  if (value is! Map) {
    throw FormatException('$fieldName must be an object.');
  }
  return value.map<String, Object?>(
    (Object? key, Object? mapValue) => MapEntry(key.toString(), mapValue),
  );
}

List<Object?> _asObjectList(Object? value, String fieldName) {
  if (value is! List) {
    throw FormatException('$fieldName must be a list.');
  }
  return value.cast<Object?>();
}

String _readRequiredString(Map<String, Object?> map, String key, {required String fieldName}) {
  final value = map[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$fieldName must be a non-empty string.');
  }
  return value.trim();
}

String? _readOptionalString(Map<String, Object?> map, String key, {required String fieldName}) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$fieldName must be a non-empty string when provided.');
  }
  return value.trim();
}
