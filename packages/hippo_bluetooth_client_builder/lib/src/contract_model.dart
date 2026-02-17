import 'dart:convert';

const supportedBleContractVersion = '1.0.0';

const Set<String> supportedCharacteristicProperties = <String>{
  'read',
  'write',
  'writeWithoutResponse',
  'notify',
  'indicate',
};

const Set<String> supportedChannelCodecs = <String>{'bytes', 'utf8', 'json'};

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
  final BleContractJsonSchema? codecJsonSchema;

  const BleContractCharacteristic({
    required this.id,
    required this.uuid,
    required this.properties,
    this.codec,
    this.codecJsonSchema,
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
  final BleContractJsonSchema? codecJsonSchema;

  const ResolvedBleContractCharacteristic({
    required this.id,
    required this.uuid,
    required this.properties,
    this.codec,
    this.codecJsonSchema,
  });

  bool get canRead => properties.contains('read');

  bool get canWriteWithResponse => properties.contains('write');

  bool get canWriteWithoutResponse => properties.contains('writeWithoutResponse');

  bool get canNotify => properties.contains('notify') || properties.contains('indicate');
}

class BleContractJsonSchema {
  final Map<String, Object?>? send;
  final Map<String, Object?>? receive;

  const BleContractJsonSchema({this.send, this.receive});
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

      final parsedCodec = _parseCharacteristicCodec(
        characteristicMap,
        fieldBasePath: 'services[$serviceIndex].characteristics[$characteristicIndex]',
      );
      final characteristicCodec = parsedCodec.codec;
      final characteristicCodecJsonSchema = parsedCodec.jsonSchema;

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
          codecJsonSchema: characteristicCodecJsonSchema,
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
          codecJsonSchema: characteristic.codecJsonSchema,
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

String? _normalizeChannelCodec(String? value, {required String fieldName}) {
  if (value == null) {
    return null;
  }
  if (supportedChannelCodecs.contains(value)) {
    return value;
  }
  throw FormatException(
    "Unsupported channel codec '$value' in $fieldName. "
    'Supported: ${supportedChannelCodecs.join(', ')}.',
  );
}

_ParsedCharacteristicCodec _parseCharacteristicCodec(
  Map<String, Object?> characteristicMap, {
  required String fieldBasePath,
}) {
  final codecFieldName = '$fieldBasePath.codec';
  final jsonSchemaFieldName = '$fieldBasePath.jsonSchema';
  final topLevelJsonSchema = _parseCodecJsonSchema(
    characteristicMap['jsonSchema'],
    fieldName: jsonSchemaFieldName,
  );

  final rawCodec = characteristicMap['codec'];
  if (rawCodec == null) {
    if (topLevelJsonSchema != null) {
      throw FormatException('$jsonSchemaFieldName requires codec to be set to json.');
    }
    return const _ParsedCharacteristicCodec(codec: null, jsonSchema: null);
  }

  if (rawCodec is String) {
    final codec = _normalizeChannelCodec(rawCodec, fieldName: codecFieldName);
    if (topLevelJsonSchema != null && codec != 'json') {
      throw FormatException('$jsonSchemaFieldName is only supported when codec is json.');
    }
    return _ParsedCharacteristicCodec(codec: codec, jsonSchema: topLevelJsonSchema);
  }

  if (rawCodec is! Map) {
    throw FormatException('$codecFieldName must be either a string or an object.');
  }

  final codecMap = _asObjectMap(rawCodec, codecFieldName);
  final codecNameRaw =
      _readOptionalString(codecMap, 'name', fieldName: '$codecFieldName.name') ??
      _readOptionalString(codecMap, 'type', fieldName: '$codecFieldName.type');
  final codecName = _normalizeChannelCodec(codecNameRaw, fieldName: codecFieldName);
  final codecLevelJsonSchema = _parseCodecJsonSchema(
    codecMap['jsonSchema'],
    fieldName: '$codecFieldName.jsonSchema',
  );
  if (topLevelJsonSchema != null && codecLevelJsonSchema != null) {
    throw FormatException(
      'Specify jsonSchema either in $jsonSchemaFieldName or $codecFieldName.jsonSchema, not both.',
    );
  }
  final resolvedJsonSchema = codecLevelJsonSchema ?? topLevelJsonSchema;
  if (resolvedJsonSchema != null && codecName != 'json') {
    throw FormatException('jsonSchema is only supported when codec is json in $codecFieldName.');
  }
  return _ParsedCharacteristicCodec(codec: codecName, jsonSchema: resolvedJsonSchema);
}

BleContractJsonSchema? _parseCodecJsonSchema(Object? rawValue, {required String fieldName}) {
  if (rawValue == null) {
    return null;
  }
  final schemaMap = _asObjectMap(rawValue, fieldName);
  final directionalSchema = schemaMap.containsKey('send') || schemaMap.containsKey('receive');
  if (!directionalSchema) {
    return BleContractJsonSchema(send: schemaMap, receive: schemaMap);
  }

  final send = _readOptionalObjectMap(schemaMap, 'send', fieldName: '$fieldName.send');
  final receive = _readOptionalObjectMap(schemaMap, 'receive', fieldName: '$fieldName.receive');
  if (send == null && receive == null) {
    throw FormatException('$fieldName must provide at least one of send or receive.');
  }
  return BleContractJsonSchema(send: send, receive: receive);
}

Map<String, Object?>? _readOptionalObjectMap(
  Map<String, Object?> map,
  String key, {
  required String fieldName,
}) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  return _asObjectMap(value, fieldName);
}

class _ParsedCharacteristicCodec {
  final String? codec;
  final BleContractJsonSchema? jsonSchema;

  const _ParsedCharacteristicCodec({required this.codec, required this.jsonSchema});
}
