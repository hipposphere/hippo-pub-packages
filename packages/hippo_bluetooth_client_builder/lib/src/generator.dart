import 'dart:convert';
import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

import 'contract_model.dart';

enum GeneratedChannelCodec {
  bytes,
  utf8,
  json;

  static GeneratedChannelCodec parse(String value) {
    return switch (value.trim()) {
      'bytes' => GeneratedChannelCodec.bytes,
      'utf8' => GeneratedChannelCodec.utf8,
      'json' => GeneratedChannelCodec.json,
      _ => throw FormatException("Unsupported codec '$value'. Allowed: bytes, utf8, json."),
    };
  }

  String get dartType => switch (this) {
    GeneratedChannelCodec.bytes => 'Uint8List',
    GeneratedChannelCodec.utf8 => 'String',
    GeneratedChannelCodec.json => 'dynamic',
  };

  String get codecExpression => switch (this) {
    GeneratedChannelCodec.bytes => 'ChannelCodecs.bytes',
    GeneratedChannelCodec.utf8 => 'ChannelCodecs.utf8',
    GeneratedChannelCodec.json => 'ChannelCodecs.json',
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
  final bindingsResult = _buildBindings(contract, options);
  final serviceBindings = bindingsResult.services;
  final schemaModels = _generateSchemaModels(bindingsResult.schemaModels);
  final importUris = <String>{
    'dart:typed_data',
    'package:hippo_bluetooth_client/hippo_bluetooth_client.dart',
    ...schemaModels.importUris,
  };

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
  for (final importUri in _sortImportUris(importUris)) {
    buffer.writeln("import '$importUri';");
  }
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
  buffer.writeln(
    _buildAggregateClientClassSource(
      className: aggregateClientClassName,
      definitionsClassName: definitionsClassName,
      serviceBindings: serviceBindings,
    ),
  );
  buffer.writeln();
  if (schemaModels.source.trim().isNotEmpty) {
    buffer.writeln(schemaModels.source.trim());
    buffer.writeln();
  }

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
        buffer.writeln('  Future<${channel.readDartType}> read${channel.methodBasePascal}({');
        buffer.writeln('    Duration? timeout,');
        if (channel.readModelType != null) {
          buffer.writeln('  }) async {');
          buffer.writeln('    final value = await _client.readChannel<dynamic>(');
          buffer.writeln('      protocolId,');
          buffer.writeln('      ${channel.channelIdConstantName},');
          buffer.writeln('      timeout: timeout,');
          buffer.writeln('    );');
          buffer.writeln('    return ${channel.readModelType}.fromJson(value);');
        } else {
          buffer.writeln('  }) {');
          buffer.writeln('    return _client.readChannel<${channel.readDartType}>(');
          buffer.writeln('      protocolId,');
          buffer.writeln('      ${channel.channelIdConstantName},');
          buffer.writeln('      timeout: timeout,');
          buffer.writeln('    );');
        }
        buffer.writeln('  }');
        buffer.writeln();
      }

      if (channel.channel.canWriteWithResponse || channel.channel.canWriteWithoutResponse) {
        final writesWithResponse = channel.channel.canWriteWithResponse;
        final writesWithoutResponse = channel.channel.canWriteWithoutResponse;

        if (writesWithResponse && writesWithoutResponse) {
          buffer.writeln(
            '  Future<void> write${channel.methodBasePascal}('
            '${channel.writeDartType} value, {',
          );
          buffer.writeln('    bool withoutResponse = false,');
          buffer.writeln('    Duration? timeout,');
          buffer.writeln('  }) {');
          buffer.writeln('    return _client.writeChannel<${channel.writeWireDartType}>(');
          buffer.writeln('      protocolId,');
          buffer.writeln('      ${channel.channelIdConstantName},');
          buffer.writeln('      ${channel.writeValueExpression},');
          buffer.writeln('      withoutResponse: withoutResponse,');
          buffer.writeln('      timeout: timeout,');
          buffer.writeln('    );');
          buffer.writeln('  }');
          buffer.writeln();
        } else {
          final withoutResponse = writesWithoutResponse && !writesWithResponse;
          buffer.writeln(
            '  Future<void> write${channel.methodBasePascal}('
            '${channel.writeDartType} value, {',
          );
          buffer.writeln('    Duration? timeout,');
          buffer.writeln('  }) {');
          buffer.writeln('    return _client.writeChannel<${channel.writeWireDartType}>(');
          buffer.writeln('      protocolId,');
          buffer.writeln('      ${channel.channelIdConstantName},');
          buffer.writeln('      ${channel.writeValueExpression},');
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
          '${channel.writeDartType} value, {',
        );
        buffer.writeln(
          '    ChunkSendOptions options = '
          'const ChunkSendOptions(withoutResponse: $defaultChunkWithoutResponse),',
        );
        buffer.writeln('    Duration? timeout,');
        buffer.writeln('  }) {');
        buffer.writeln('    return _client.sendChunked<${channel.writeWireDartType}>(');
        buffer.writeln('      protocolId,');
        buffer.writeln('      ${channel.channelIdConstantName},');
        buffer.writeln('      ${channel.writeValueExpression},');
        buffer.writeln('      options: options,');
        buffer.writeln('      timeout: timeout,');
        buffer.writeln('    );');
        buffer.writeln('  }');
        buffer.writeln();
      }

      if (channel.channel.canNotify) {
        buffer.writeln('  Stream<${channel.readDartType}> watch${channel.methodBasePascal}({');
        buffer.writeln('    bool emitCurrentValue = false,');
        buffer.writeln('    Duration? timeout,');
        buffer.writeln('  }) {');
        if (channel.readModelType != null) {
          buffer.writeln('    return _client.subscribeChannel<dynamic>(');
          buffer.writeln('      protocolId,');
          buffer.writeln('      ${channel.channelIdConstantName},');
          buffer.writeln('      emitCurrentValue: emitCurrentValue,');
          buffer.writeln('      timeout: timeout,');
          buffer.writeln('    ).map(${channel.readModelType}.fromJson);');
        } else {
          buffer.writeln('    return _client.subscribeChannel<${channel.readDartType}>(');
          buffer.writeln('      protocolId,');
          buffer.writeln('      ${channel.channelIdConstantName},');
          buffer.writeln('      emitCurrentValue: emitCurrentValue,');
          buffer.writeln('      timeout: timeout,');
          buffer.writeln('    );');
        }
        buffer.writeln('  }');
        buffer.writeln();

        buffer.writeln(
          '  Stream<${channel.readDartType}> watch${channel.methodBasePascal}Chunked({',
        );
        buffer.writeln('    String? sessionId,');
        buffer.writeln('    bool emitCurrentValue = false,');
        buffer.writeln('    Duration? timeout,');
        buffer.writeln('  }) {');
        if (channel.readModelType != null) {
          buffer.writeln('    return _client.subscribeChunkedChannel<dynamic>(');
          buffer.writeln('      protocolId,');
          buffer.writeln('      ${channel.channelIdConstantName},');
          buffer.writeln('      sessionId: sessionId,');
          buffer.writeln('      emitCurrentValue: emitCurrentValue,');
          buffer.writeln('      timeout: timeout,');
          buffer.writeln('    ).map(${channel.readModelType}.fromJson);');
        } else {
          buffer.writeln('    return _client.subscribeChunkedChannel<${channel.readDartType}>(');
          buffer.writeln('      protocolId,');
          buffer.writeln('      ${channel.channelIdConstantName},');
          buffer.writeln('      sessionId: sessionId,');
          buffer.writeln('      emitCurrentValue: emitCurrentValue,');
          buffer.writeln('      timeout: timeout,');
          buffer.writeln('    );');
        }
        buffer.writeln('  }');
        buffer.writeln();
      }
    }

    buffer.writeln('}');
    buffer.writeln();
  }

  final formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
    pageWidth: 100,
  );
  return formatter.format(buffer.toString());
}

String _buildAggregateClientClassSource({
  required String className,
  required String definitionsClassName,
  required List<_ServiceBinding> serviceBindings,
}) {
  final classBuilder = ClassBuilder()..name = className;
  classBuilder.fields.add(
    Field(
      (builder) => builder
        ..name = 'protocolClient'
        ..modifier = FieldModifier.final$
        ..type = refer('BleProtocolClient'),
    ),
  );
  for (final service in serviceBindings) {
    classBuilder.fields.add(
      Field(
        (builder) => builder
          ..name = service.instanceFieldName
          ..modifier = FieldModifier.final$
          ..type = refer(service.className),
      ),
    );
  }

  classBuilder.constructors.add(
    Constructor((builder) {
      builder.requiredParameters.add(
        Parameter(
          (parameterBuilder) => parameterBuilder
            ..name = 'protocolClient'
            ..toThis = true,
        ),
      );
      for (final service in serviceBindings) {
        builder.initializers.add(
          Code('${service.instanceFieldName} = ${service.className}(protocolClient)'),
        );
      }
    }),
  );

  classBuilder.constructors.add(
    Constructor(
      (builder) => builder
        ..factory = true
        ..name = 'create'
        ..optionalParameters.addAll(<Parameter>[
          Parameter(
            (parameterBuilder) => parameterBuilder
              ..named = true
              ..required = true
              ..name = 'gattClient'
              ..type = refer('BleGattClient'),
          ),
          Parameter(
            (parameterBuilder) => parameterBuilder
              ..named = true
              ..required = true
              ..name = 'remoteId'
              ..type = refer('String'),
          ),
          Parameter(
            (parameterBuilder) => parameterBuilder
              ..named = true
              ..name = 'defaultOperationTimeout'
              ..type = refer('Duration')
              ..defaultTo = const Code('const Duration(seconds: 15)'),
          ),
          Parameter(
            (parameterBuilder) => parameterBuilder
              ..named = true
              ..name = 'chunkReassembler'
              ..type = refer('ChunkReassembler?'),
          ),
        ])
        ..body = Code('''
final protocolClient = BleProtocolClient(
  gattClient: gattClient,
  remoteId: remoteId,
  protocols: $definitionsClassName.protocols,
  defaultOperationTimeout: defaultOperationTimeout,
  chunkReassembler: chunkReassembler,
);
return $className(protocolClient);
'''),
    ),
  );

  classBuilder.methods.add(
    Method(
      (builder) => builder
        ..name = 'dispose'
        ..returns = refer('Future<void>')
        ..lambda = true
        ..body = const Code('protocolClient.dispose()'),
    ),
  );

  final emitter = DartEmitter(orderDirectives: true, useNullSafetySyntax: true);
  return classBuilder.build().accept(emitter).toString();
}

_BindingsBuildResult _buildBindings(ResolvedBleContract contract, BleClientCodegenOptions options) {
  final serviceClassNames = <String>{};
  final serviceInstanceNames = <String>{};
  final protocolFieldNames = <String>{};
  final schemaTypeNames = <String>{};

  final bindings = <_ServiceBinding>[];
  final schemaModels = <_SchemaModelDefinition>[];
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
      String? readModelType;
      String? writeModelType;
      if (codec == GeneratedChannelCodec.json && channel.codecJsonSchema != null) {
        final schemaBaseName = _toSafePascal(
          '${service.id}_${channel.id}',
          fallback: 'JsonPayload',
        );
        if (channel.codecJsonSchema!.send != null) {
          readModelType = _reserveUniqueName('${schemaBaseName}SendPayload', schemaTypeNames);
          schemaModels.add(
            _SchemaModelDefinition(
              name: readModelType,
              schema: Map<String, Object?>.from(channel.codecJsonSchema!.send!),
            ),
          );
        }
        if (channel.codecJsonSchema!.receive != null) {
          writeModelType = _reserveUniqueName('${schemaBaseName}ReceivePayload', schemaTypeNames);
          schemaModels.add(
            _SchemaModelDefinition(
              name: writeModelType,
              schema: Map<String, Object?>.from(channel.codecJsonSchema!.receive!),
            ),
          );
        }
      }

      final readDartType = readModelType ?? codec.dartType;
      final writeDartType = writeModelType ?? codec.dartType;
      final writeWireDartType = writeModelType == null ? codec.dartType : 'dynamic';
      final writeValueExpression = writeModelType == null ? 'value' : 'value.toJson()';
      channels.add(
        _ChannelBinding(
          channel: channel,
          methodBasePascal: channelPascal,
          channelIdConstantName: constantName,
          codec: codec,
          readDartType: readDartType,
          writeDartType: writeDartType,
          readModelType: readModelType,
          writeModelType: writeModelType,
          writeWireDartType: writeWireDartType,
          writeValueExpression: writeValueExpression,
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

  return _BindingsBuildResult(services: bindings, schemaModels: schemaModels);
}

class _BindingsBuildResult {
  final List<_ServiceBinding> services;
  final List<_SchemaModelDefinition> schemaModels;

  const _BindingsBuildResult({required this.services, required this.schemaModels});
}

class _SchemaModelDefinition {
  final String name;
  final Map<String, Object?> schema;

  const _SchemaModelDefinition({required this.name, required this.schema});
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
  final String readDartType;
  final String writeDartType;
  final String? readModelType;
  final String? writeModelType;
  final String writeWireDartType;
  final String writeValueExpression;

  const _ChannelBinding({
    required this.channel,
    required this.methodBasePascal,
    required this.channelIdConstantName,
    required this.codec,
    required this.readDartType,
    required this.writeDartType,
    required this.readModelType,
    required this.writeModelType,
    required this.writeWireDartType,
    required this.writeValueExpression,
  });
}

class _GeneratedSchemaModels {
  final Set<String> importUris;
  final String source;

  const _GeneratedSchemaModels({required this.importUris, required this.source});
}

_GeneratedSchemaModels _generateSchemaModels(List<_SchemaModelDefinition> schemaModels) {
  if (schemaModels.isEmpty) {
    return const _GeneratedSchemaModels(importUris: <String>{}, source: '');
  }

  final dartExecutable = _resolveDartExecutable();
  final toolScriptPath = _resolveJsonSchemaCodegenScriptPath();
  final payload = jsonEncode(<String, Object?>{
    'models': schemaModels
        .map((model) => <String, Object?>{'name': model.name, 'schema': model.schema})
        .toList(),
  });
  final toolScriptFile = File(toolScriptPath);
  final toolWorkingDirectory = toolScriptFile.parent.parent.path;
  final toolScriptArg = p.relative(toolScriptPath, from: toolWorkingDirectory);
  final tempDirectory = Directory.systemTemp.createTempSync('hippo_ble_schema_codegen_');
  final payloadFile = File(p.join(tempDirectory.path, 'payload.json'))..writeAsStringSync(payload);
  ProcessResult processResult;
  try {
    processResult = Process.runSync(
      dartExecutable,
      <String>['--suppress-analytics', 'run', toolScriptArg, '--input-file', payloadFile.path],
      workingDirectory: toolWorkingDirectory,
      runInShell: false,
      environment: <String, String>{...Platform.environment, 'HOME': '/tmp'},
    );
  } finally {
    try {
      tempDirectory.deleteSync(recursive: true);
    } on Object {
      // Ignore temp directory cleanup failures.
    }
  }

  if (processResult.exitCode != 0) {
    throw FormatException(
      'Failed to generate Dart classes from codec JSON schemas.\n'
      'Tool: $toolScriptPath\n'
      'Exit code: ${processResult.exitCode}\n'
      'stderr:\n${processResult.stderr}\n'
      'stdout:\n${processResult.stdout}',
    );
  }

  final stdoutText = processResult.stdout.toString().trim();
  if (stdoutText.isEmpty) {
    return const _GeneratedSchemaModels(importUris: <String>{}, source: '');
  }
  final decoded = jsonDecode(stdoutText);
  if (decoded is! Map) {
    throw const FormatException('Schema generator returned invalid JSON payload.');
  }

  final importUrisRaw = decoded['imports'];
  final sourceRaw = decoded['source'];
  if (importUrisRaw is! List || sourceRaw is! String) {
    throw const FormatException(
      'Schema generator response must contain imports and source fields.',
    );
  }

  final imports = <String>{};
  for (final value in importUrisRaw) {
    if (value is! String || value.trim().isEmpty) {
      throw const FormatException('Schema generator imports must be non-empty strings.');
    }
    imports.add(value.trim());
  }
  return _GeneratedSchemaModels(importUris: imports, source: sourceRaw);
}

String _resolveDartExecutable() {
  final resolved = Platform.resolvedExecutable;
  if (resolved.endsWith('${p.separator}flutter${p.separator}bin${p.separator}dart')) {
    final flutterRoot = p.dirname(p.dirname(resolved));
    final dartSdkExecutable = p.join(flutterRoot, 'bin', 'cache', 'dart-sdk', 'bin', 'dart');
    if (File(dartSdkExecutable).existsSync()) {
      return dartSdkExecutable;
    }
  }
  return resolved;
}

String _resolveJsonSchemaCodegenScriptPath() {
  final candidates = <String>[
    p.join(Directory.current.path, 'tool', 'json_schema_codegen.dart'),
    p.join(
      Directory.current.path,
      'packages',
      'hippo_bluetooth_client_builder',
      'tool',
      'json_schema_codegen.dart',
    ),
  ];
  for (final candidate in candidates) {
    final file = File(candidate);
    if (file.existsSync()) {
      return file.absolute.path;
    }
  }
  throw FormatException(
    'Cannot find json schema codegen script. '
    'Expected one of: ${candidates.join(', ')}.',
  );
}

List<String> _sortImportUris(Set<String> importUris) {
  final sorted = importUris.toList();
  sorted.sort((left, right) {
    final leftOrder = _importOrder(left);
    final rightOrder = _importOrder(right);
    if (leftOrder != rightOrder) {
      return leftOrder.compareTo(rightOrder);
    }
    return left.compareTo(right);
  });
  return sorted;
}

int _importOrder(String uri) {
  if (uri.startsWith('dart:')) {
    return 0;
  }
  if (uri.startsWith('package:')) {
    return 1;
  }
  return 2;
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
