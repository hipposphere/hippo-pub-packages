import 'contract_model.dart';

enum GeneratedChannelCodec {
  bytes,
  utf8,
  jsonMap;

  static GeneratedChannelCodec parse(String value) {
    return switch (value.trim()) {
      'bytes' => GeneratedChannelCodec.bytes,
      'utf8' => GeneratedChannelCodec.utf8,
      'jsonMap' => GeneratedChannelCodec.jsonMap,
      _ => throw FormatException("Unsupported codec '$value'. Allowed: bytes, utf8, jsonMap."),
    };
  }

  String get dartType => switch (this) {
    GeneratedChannelCodec.bytes => 'Uint8List',
    GeneratedChannelCodec.utf8 => 'String',
    GeneratedChannelCodec.jsonMap => 'Map<String, dynamic>',
  };

  String get codecExpression => switch (this) {
    GeneratedChannelCodec.bytes => 'ChannelCodecs.bytes',
    GeneratedChannelCodec.utf8 => 'ChannelCodecs.utf8',
    GeneratedChannelCodec.jsonMap => 'ChannelCodecs.jsonMap',
  };
}

class BleClientCodegenOptions {
  final String? classPrefix;
  final String? libraryName;
  final GeneratedChannelCodec defaultCodec;
  final Map<String, GeneratedChannelCodec> codecOverrides;

  const BleClientCodegenOptions({
    this.classPrefix,
    this.libraryName,
    this.defaultCodec = GeneratedChannelCodec.bytes,
    this.codecOverrides = const <String, GeneratedChannelCodec>{},
  });

  GeneratedChannelCodec codecFor({
    required String protocolId,
    required String channelId,
    String? contractCodec,
  }) {
    final byFullPath = codecOverrides['$protocolId/$channelId'];
    if (byFullPath != null) {
      return byFullPath;
    }
    final byChannelOnly = codecOverrides[channelId];
    if (byChannelOnly != null) {
      return byChannelOnly;
    }
    if (contractCodec != null) {
      return GeneratedChannelCodec.parse(contractCodec);
    }
    return defaultCodec;
  }
}

Map<String, GeneratedChannelCodec> parseCodecOverridesJsonMap(Object? value) {
  if (value is! Map) {
    throw const FormatException('Codec overrides root must be a JSON object.');
  }

  final result = <String, GeneratedChannelCodec>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String || key.trim().isEmpty) {
      throw const FormatException('Codec override keys must be non-empty strings.');
    }

    final rawCodec = entry.value;
    if (rawCodec is! String) {
      throw FormatException("Codec override for key '$key' must be a string codec name.");
    }

    result[key.trim()] = GeneratedChannelCodec.parse(rawCodec);
  }
  return result;
}

String generateBleClientDart({
  required ResolvedBleContract contract,
  required BleClientCodegenOptions options,
  required String sourceContractPath,
}) {
  final classPrefix = _toSafePascal(
    options.classPrefix ?? contract.document.info.title,
    fallback: 'Generated',
  );
  final libraryName = _toSafeLibraryName(
    options.libraryName ?? '${_toSnakeCase(classPrefix)}_ble_client',
  );

  final definitionsClassName = '${classPrefix}BleContract';
  final aggregateClientClassName = '${classPrefix}BleClient';
  final serviceBindings = _buildBindings(contract, options);

  final buffer = StringBuffer();
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.');
  buffer.writeln('// Source: $sourceContractPath');
  buffer.writeln(
    '// Contract: ${contract.document.info.title} '
    '${contract.document.info.version} '
    '(bleContract ${contract.document.bleContract})',
  );
  buffer.writeln();
  buffer.writeln('library $libraryName;');
  buffer.writeln();
  buffer.writeln("import 'dart:typed_data';");
  buffer.writeln();
  buffer.writeln("import 'package:hippo_bluetooth_client/hippo_bluetooth_client.dart';");
  buffer.writeln();
  buffer.writeln('abstract final class $definitionsClassName {');
  for (final service in serviceBindings) {
    buffer.writeln('  static final BleProtocolDefinition ${service.protocolFieldName} =');
    buffer.writeln('      BleProtocolDefinition(');
    buffer.writeln("        protocolId: ${_quote(service.service.id)},");
    buffer.writeln("        serviceUuid: ${_quote(canonicalBleUuid(service.service.uuid))},");
    buffer.writeln('        channels: <BleChannelDefinition<dynamic>>[');
    for (final channel in service.channels) {
      buffer.writeln('          const BleChannelDefinition<${channel.codec.dartType}>(');
      buffer.writeln("            channelId: ${_quote(channel.channel.id)},");
      buffer.writeln("            channelUuid: ${_quote(canonicalBleUuid(channel.channel.uuid))},");
      buffer.writeln(
        '            properties: BleChannelProperties('
        'read: ${channel.channel.canRead}, '
        'write: ${channel.channel.canWriteWithResponse || channel.channel.canWriteWithoutResponse}, '
        'notify: ${channel.channel.canNotify}'
        '),',
      );
      buffer.writeln('            codec: ${channel.codec.codecExpression},');
      buffer.writeln('          ),');
    }
    buffer.writeln('        ],');
    buffer.writeln('      );');
    buffer.writeln();
  }
  buffer.writeln('  static final List<BleProtocolDefinition> protocols =');
  buffer.writeln('      <BleProtocolDefinition>[');
  for (final service in serviceBindings) {
    buffer.writeln('        ${service.protocolFieldName},');
  }
  buffer.writeln('      ];');
  buffer.writeln('}');
  buffer.writeln();
  buffer.writeln('class $aggregateClientClassName {');
  if (serviceBindings.isEmpty) {
    buffer.writeln('  $aggregateClientClassName(this.protocolClient);');
  } else {
    buffer.writeln('  $aggregateClientClassName(this.protocolClient)');
    for (var index = 0; index < serviceBindings.length; index += 1) {
      final service = serviceBindings[index];
      final terminator = index + 1 == serviceBindings.length ? ';' : ',';
      buffer.writeln(
        '    : ${service.instanceFieldName} = '
        '${service.className}(protocolClient)$terminator',
      );
    }
  }
  buffer.writeln();
  buffer.writeln('  factory $aggregateClientClassName.create({');
  buffer.writeln('    required BleGattClient gattClient,');
  buffer.writeln('    required String remoteId,');
  buffer.writeln('    Duration defaultOperationTimeout = const Duration(seconds: 15),');
  buffer.writeln('    ChunkReassembler? chunkReassembler,');
  buffer.writeln('  }) {');
  buffer.writeln('    final protocolClient = BleProtocolClient(');
  buffer.writeln('      gattClient: gattClient,');
  buffer.writeln('      remoteId: remoteId,');
  buffer.writeln('      protocols: $definitionsClassName.protocols,');
  buffer.writeln('      defaultOperationTimeout: defaultOperationTimeout,');
  buffer.writeln('      chunkReassembler: chunkReassembler,');
  buffer.writeln('    );');
  buffer.writeln('    return $aggregateClientClassName(protocolClient);');
  buffer.writeln('  }');
  buffer.writeln();
  buffer.writeln('  final BleProtocolClient protocolClient;');
  for (final service in serviceBindings) {
    buffer.writeln('  final ${service.className} ${service.instanceFieldName};');
  }
  buffer.writeln();
  buffer.writeln('  Future<void> dispose() => protocolClient.dispose();');
  buffer.writeln('}');
  buffer.writeln();

  for (final service in serviceBindings) {
    buffer.writeln('class ${service.className} {');
    buffer.writeln('  ${service.className}(this._client);');
    buffer.writeln();
    buffer.writeln('  final BleProtocolClient _client;');
    buffer.writeln();
    buffer.writeln("  static const String protocolId = ${_quote(service.service.id)};");
    buffer.writeln(
      "  static const String serviceUuid = ${_quote(canonicalBleUuid(service.service.uuid))};",
    );
    buffer.writeln('  static const bool advertise = ${service.service.advertise};');
    buffer.writeln();
    for (final channel in service.channels) {
      buffer.writeln(
        '  static const String ${channel.channelIdConstantName} = '
        '${_quote(channel.channel.id)};',
      );
    }
    buffer.writeln();

    for (final channel in service.channels) {
      buffer.writeln(
        '  Future<BleCharacteristicRef> resolve${channel.methodBasePascal}Characteristic({',
      );
      buffer.writeln('    bool refresh = false,');
      buffer.writeln('    Duration? timeout,');
      buffer.writeln('  }) {');
      buffer.writeln('    return _client.getChannelCharacteristicRef(');
      buffer.writeln('      protocolId,');
      buffer.writeln('      ${channel.channelIdConstantName},');
      buffer.writeln('      refresh: refresh,');
      buffer.writeln('      timeout: timeout,');
      buffer.writeln('    );');
      buffer.writeln('  }');
      buffer.writeln();

      if (channel.channel.canRead) {
        buffer.writeln('  Future<${channel.codec.dartType}> read${channel.methodBasePascal}({');
        buffer.writeln('    Duration? timeout,');
        buffer.writeln('  }) {');
        buffer.writeln('    return _client.readChannel<${channel.codec.dartType}>(');
        buffer.writeln('      protocolId,');
        buffer.writeln('      ${channel.channelIdConstantName},');
        buffer.writeln('      timeout: timeout,');
        buffer.writeln('    );');
        buffer.writeln('  }');
        buffer.writeln();
      }

      if (channel.channel.canWriteWithResponse || channel.channel.canWriteWithoutResponse) {
        final writesWithResponse = channel.channel.canWriteWithResponse;
        final writesWithoutResponse = channel.channel.canWriteWithoutResponse;

        if (writesWithResponse && writesWithoutResponse) {
          buffer.writeln(
            '  Future<void> write${channel.methodBasePascal}('
            '${channel.codec.dartType} value, {',
          );
          buffer.writeln('    bool withoutResponse = false,');
          buffer.writeln('    Duration? timeout,');
          buffer.writeln('  }) {');
          buffer.writeln('    return _client.writeChannel<${channel.codec.dartType}>(');
          buffer.writeln('      protocolId,');
          buffer.writeln('      ${channel.channelIdConstantName},');
          buffer.writeln('      value,');
          buffer.writeln('      withoutResponse: withoutResponse,');
          buffer.writeln('      timeout: timeout,');
          buffer.writeln('    );');
          buffer.writeln('  }');
          buffer.writeln();
        } else {
          final withoutResponse = writesWithoutResponse && !writesWithResponse;
          buffer.writeln(
            '  Future<void> write${channel.methodBasePascal}('
            '${channel.codec.dartType} value, {',
          );
          buffer.writeln('    Duration? timeout,');
          buffer.writeln('  }) {');
          buffer.writeln('    return _client.writeChannel<${channel.codec.dartType}>(');
          buffer.writeln('      protocolId,');
          buffer.writeln('      ${channel.channelIdConstantName},');
          buffer.writeln('      value,');
          buffer.writeln('      withoutResponse: $withoutResponse,');
          buffer.writeln('      timeout: timeout,');
          buffer.writeln('    );');
          buffer.writeln('  }');
          buffer.writeln();
        }

        final defaultChunkWithoutResponse =
            channel.channel.canWriteWithoutResponse || !channel.channel.canWriteWithResponse;

        buffer.writeln(
          '  Future<void> send${channel.methodBasePascal}Chunked('
          '${channel.codec.dartType} value, {',
        );
        buffer.writeln(
          '    ChunkSendOptions options = '
          'const ChunkSendOptions(withoutResponse: $defaultChunkWithoutResponse),',
        );
        buffer.writeln('    Duration? timeout,');
        buffer.writeln('  }) {');
        buffer.writeln('    return _client.sendChunked<${channel.codec.dartType}>(');
        buffer.writeln('      protocolId,');
        buffer.writeln('      ${channel.channelIdConstantName},');
        buffer.writeln('      value,');
        buffer.writeln('      options: options,');
        buffer.writeln('      timeout: timeout,');
        buffer.writeln('    );');
        buffer.writeln('  }');
        buffer.writeln();
      }

      if (channel.channel.canNotify) {
        buffer.writeln('  Stream<${channel.codec.dartType}> watch${channel.methodBasePascal}({');
        buffer.writeln('    bool emitCurrentValue = false,');
        buffer.writeln('    Duration? timeout,');
        buffer.writeln('  }) {');
        buffer.writeln('    return _client.subscribeChannel<${channel.codec.dartType}>(');
        buffer.writeln('      protocolId,');
        buffer.writeln('      ${channel.channelIdConstantName},');
        buffer.writeln('      emitCurrentValue: emitCurrentValue,');
        buffer.writeln('      timeout: timeout,');
        buffer.writeln('    );');
        buffer.writeln('  }');
        buffer.writeln();

        buffer.writeln(
          '  Stream<${channel.codec.dartType}> watch${channel.methodBasePascal}Chunked({',
        );
        buffer.writeln('    String? sessionId,');
        buffer.writeln('    bool emitCurrentValue = false,');
        buffer.writeln('    Duration? timeout,');
        buffer.writeln('  }) {');
        buffer.writeln('    return _client.subscribeChunkedChannel<${channel.codec.dartType}>(');
        buffer.writeln('      protocolId,');
        buffer.writeln('      ${channel.channelIdConstantName},');
        buffer.writeln('      sessionId: sessionId,');
        buffer.writeln('      emitCurrentValue: emitCurrentValue,');
        buffer.writeln('      timeout: timeout,');
        buffer.writeln('    );');
        buffer.writeln('  }');
        buffer.writeln();
      }
    }

    buffer.writeln('}');
    buffer.writeln();
  }

  return buffer.toString();
}

List<_ServiceBinding> _buildBindings(
  ResolvedBleContract contract,
  BleClientCodegenOptions options,
) {
  final serviceClassNames = <String>{};
  final serviceInstanceNames = <String>{};
  final protocolFieldNames = <String>{};

  final bindings = <_ServiceBinding>[];
  for (final service in contract.services) {
    final baseServiceName = _toSafePascal(service.id, fallback: 'Service');

    final className = _reserveUniqueName('${baseServiceName}BleService', serviceClassNames);
    final instanceFieldName = _reserveUniqueName(
      _toSafeCamel(service.id, fallback: 'service'),
      serviceInstanceNames,
    );
    final protocolFieldName = _reserveUniqueName(
      _toSafeCamel('${service.id}_protocol', fallback: 'protocol'),
      protocolFieldNames,
    );

    final channels = <_ChannelBinding>[];
    final channelConstantNames = <String>{};
    final methodBaseNames = <String>{};
    for (final channel in service.characteristics) {
      final channelPascal = _reserveUniqueName(
        _toSafePascal(channel.id, fallback: 'Channel'),
        methodBaseNames,
      );
      final constantName = _reserveUniqueName(
        _toSafeCamel('${channel.id}_channel_id', fallback: 'channelId'),
        channelConstantNames,
      );
      final codec = options.codecFor(
        protocolId: service.id,
        channelId: channel.id,
        contractCodec: channel.codec,
      );
      channels.add(
        _ChannelBinding(
          channel: channel,
          methodBasePascal: channelPascal,
          channelIdConstantName: constantName,
          codec: codec,
        ),
      );
    }

    bindings.add(
      _ServiceBinding(
        service: service,
        className: className,
        instanceFieldName: instanceFieldName,
        protocolFieldName: protocolFieldName,
        channels: channels,
      ),
    );
  }

  return bindings;
}

class _ServiceBinding {
  final ResolvedBleContractService service;
  final String className;
  final String instanceFieldName;
  final String protocolFieldName;
  final List<_ChannelBinding> channels;

  const _ServiceBinding({
    required this.service,
    required this.className,
    required this.instanceFieldName,
    required this.protocolFieldName,
    required this.channels,
  });
}

class _ChannelBinding {
  final ResolvedBleContractCharacteristic channel;
  final String methodBasePascal;
  final String channelIdConstantName;
  final GeneratedChannelCodec codec;

  const _ChannelBinding({
    required this.channel,
    required this.methodBasePascal,
    required this.channelIdConstantName,
    required this.codec,
  });
}

String _quote(String value) {
  final escaped = value.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll(r'$', r'\$');
  return "'$escaped'";
}

String _reserveUniqueName(String baseName, Set<String> usedNames) {
  if (!usedNames.contains(baseName)) {
    usedNames.add(baseName);
    return baseName;
  }
  var index = 2;
  while (usedNames.contains('$baseName$index')) {
    index += 1;
  }
  final resolved = '$baseName$index';
  usedNames.add(resolved);
  return resolved;
}

String _toSafePascal(String value, {required String fallback}) {
  final parts = _splitIdentifierParts(value);
  if (parts.isEmpty) {
    return fallback;
  }
  final output = parts
      .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
      .join();
  if (_startsWithDigit(output)) {
    return 'N$output';
  }
  return output;
}

String _toSafeCamel(String value, {required String fallback}) {
  final pascal = _toSafePascal(value, fallback: fallback);
  if (pascal.isEmpty) {
    return fallback;
  }
  return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
}

String _toSafeLibraryName(String value) {
  final snake = _toSnakeCase(value);
  if (snake.isEmpty) {
    return 'generated_ble_client';
  }
  if (_startsWithDigit(snake)) {
    return 'generated_$snake';
  }
  return snake;
}

String _toSnakeCase(String value) {
  final parts = _splitIdentifierParts(value);
  return parts.map((part) => part.toLowerCase()).join('_');
}

List<String> _splitIdentifierParts(String value) {
  final expanded = value.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  return RegExp(
    r'[A-Za-z0-9]+',
  ).allMatches(expanded).map((match) => match.group(0)!).where((part) => part.isNotEmpty).toList();
}

bool _startsWithDigit(String value) {
  if (value.isEmpty) {
    return false;
  }
  final code = value.codeUnitAt(0);
  return code >= 48 && code <= 57;
}
