import 'dart:convert';
import 'dart:io';

import 'package:schemake/dart_gen.dart';
import 'package:schemake/schemake.dart';

Future<void> main(List<String> args) async {
  try {
    final inputText = (await _readInputText(args)).trim();
    if (inputText.isEmpty) {
      stdout.write(jsonEncode(<String, Object?>{'imports': <String>[], 'source': ''}));
      return;
    }

    final decoded = jsonDecode(inputText);
    if (decoded is! Map) {
      throw const FormatException('Input must be a JSON object.');
    }

    final modelsRaw = decoded['models'];
    if (modelsRaw is! List) {
      throw const FormatException('Input field "models" must be a list.');
    }

    final translator = _JsonSchemaTranslator();
    final rootObjects = <Objects>[];

    for (var index = 0; index < modelsRaw.length; index += 1) {
      final rawModel = modelsRaw[index];
      if (rawModel is! Map) {
        throw FormatException('models[$index] must be an object.');
      }
      final model = rawModel.map<String, Object?>(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      );
      final name = _readRequiredString(model, 'name', fieldName: 'models[$index].name');
      final schema = _asObjectMap(model['schema'], 'models[$index].schema');
      rootObjects.add(
        translator.translateRoot(name: name, schema: schema, fieldName: 'models[$index].schema'),
      );
    }

    final generated = generateDartClasses(
      rootObjects,
      options: const DartGeneratorOptions(
        className: _identityClassName,
        methodGenerators: <DartMethodGenerator>[
          ...DartGeneratorOptions.defaultMethodGenerators,
          ...DartGeneratorOptions.jsonMethodGenerators,
        ],
      ),
    ).toString();

    final generatedOutput = _splitGeneratedSource(generated);
    stdout.write(
      jsonEncode(<String, Object?>{
        'imports': generatedOutput.importUris.toList()..sort(),
        'source': generatedOutput.source,
      }),
    );
  } on Object catch (error, stackTrace) {
    stderr.writeln('json_schema_codegen failed: $error');
    stderr.writeln(stackTrace);
    exitCode = 1;
  }
}

String _identityClassName(String value) => value;

class _JsonSchemaTranslator {
  final Set<String> _usedTypeNames = <String>{};

  Objects translateRoot({
    required String name,
    required Map<String, Object?> schema,
    required String fieldName,
  }) {
    final parsed = _parseSchema(schema, suggestedName: name, fieldName: fieldName);
    if (parsed is! Objects) {
      throw FormatException('$fieldName must define a JSON object schema for model generation.');
    }
    return parsed;
  }

  SchemaType<Object?> _parseSchema(
    Map<String, Object?> schema, {
    required String suggestedName,
    required String fieldName,
  }) {
    final typeInfo = _resolveSchemaType(schema, fieldName: fieldName);
    final typeName = typeInfo.$1;
    final nullable = typeInfo.$2;
    final parsed = switch (typeName) {
      'object' => _parseObjectSchema(schema, suggestedName: suggestedName, fieldName: fieldName),
      'array' => _parseArraySchema(schema, suggestedName: suggestedName, fieldName: fieldName),
      'string' => const Strings(),
      'integer' => const Ints(),
      'number' => const Floats(),
      'boolean' => const Bools(),
      _ => throw FormatException('Unsupported JSON schema type "$typeName" at $fieldName.'),
    };
    if (nullable && parsed is NonNull) {
      return Nullable(parsed) as SchemaType<Object?>;
    }
    return parsed;
  }

  SchemaType<Object?> _parseObjectSchema(
    Map<String, Object?> schema, {
    required String suggestedName,
    required String fieldName,
  }) {
    final propertiesRaw = schema['properties'];
    final additionalPropertiesRaw = schema['additionalProperties'];

    if ((propertiesRaw == null || _isEmptyObjectMap(propertiesRaw)) &&
        additionalPropertiesRaw is Map) {
      final valueSchema = _asObjectMap(additionalPropertiesRaw, '$fieldName.additionalProperties');
      final valueType = _parseSchema(
        valueSchema,
        suggestedName: '${suggestedName}Entry',
        fieldName: '$fieldName.additionalProperties',
      );
      return Maps(
        _reserveTypeName('${suggestedName}Map'),
        valueType: valueType,
        unknownPropertiesStrategy: UnknownPropertiesStrategy.keep,
      );
    }

    final propertySchemas = propertiesRaw == null
        ? <String, Object?>{}
        : _asObjectMap(propertiesRaw, '$fieldName.properties');
    final required = _readRequiredPropertySet(schema['required'], fieldName: '$fieldName.required');

    final unknownPropertiesStrategy = additionalPropertiesRaw == true
        ? UnknownPropertiesStrategy.keep
        : UnknownPropertiesStrategy.forbid;

    final properties = <String, Property<Object?>>{};
    for (final entry in propertySchemas.entries) {
      final propertyName = entry.key;
      final propertySchema = _asObjectMap(entry.value, '$fieldName.properties.$propertyName');
      final parsedType = _parseSchema(
        propertySchema,
        suggestedName: '$suggestedName${_toPascal(propertyName)}',
        fieldName: '$fieldName.properties.$propertyName',
      );
      final isRequired = required.contains(propertyName);
      final propertyType = isRequired || parsedType is Nullable
          ? parsedType
          : Nullable(parsedType as NonNull<Object?>) as SchemaType<Object?>;
      properties[propertyName] = Property<Object?>(
        propertyType,
        description: _readOptionalString(propertySchema, 'description'),
      );
    }

    return Objects(
      _reserveTypeName(suggestedName),
      properties,
      unknownPropertiesStrategy: unknownPropertiesStrategy,
      description: _readOptionalString(schema, 'description'),
    );
  }

  SchemaType<Object?> _parseArraySchema(
    Map<String, Object?> schema, {
    required String suggestedName,
    required String fieldName,
  }) {
    final itemsRaw = schema['items'];
    if (itemsRaw == null) {
      throw FormatException('$fieldName.items is required for array schemas.');
    }
    final itemsSchema = _asObjectMap(itemsRaw, '$fieldName.items');
    final itemsType = _parseSchema(
      itemsSchema,
      suggestedName: '${suggestedName}Item',
      fieldName: '$fieldName.items',
    );
    return Arrays(itemsType);
  }

  (String, bool) _resolveSchemaType(Map<String, Object?> schema, {required String fieldName}) {
    final rawType = schema['type'];
    if (rawType is String) {
      return (rawType, false);
    }
    if (rawType is List) {
      final types = rawType.map((value) => value.toString().trim()).toSet();
      final nullable = types.remove('null');
      if (types.length != 1) {
        throw FormatException('$fieldName.type must resolve to exactly one non-null type.');
      }
      return (types.first, nullable);
    }

    if (schema.containsKey('properties') || schema.containsKey('additionalProperties')) {
      return ('object', false);
    }
    if (schema.containsKey('items')) {
      return ('array', false);
    }
    throw FormatException('$fieldName.type is required and must be a string or list of strings.');
  }

  String _reserveTypeName(String name) {
    final safeName = _toPascal(name);
    if (_usedTypeNames.add(safeName)) {
      return safeName;
    }
    var suffix = 2;
    while (!_usedTypeNames.add('$safeName$suffix')) {
      suffix += 1;
    }
    return '$safeName$suffix';
  }
}

Future<String> _readInputText(List<String> args) async {
  final inputFilePath = _parseInputFilePath(args);
  if (inputFilePath != null) {
    return File(inputFilePath).readAsString();
  }
  return stdin.transform(utf8.decoder).join();
}

String? _parseInputFilePath(List<String> args) {
  const flag = '--input-file';
  for (var index = 0; index < args.length; index += 1) {
    if (args[index] != flag) {
      continue;
    }
    if (index + 1 >= args.length) {
      throw const FormatException('--input-file requires a file path value.');
    }
    final value = args[index + 1].trim();
    if (value.isEmpty) {
      throw const FormatException('--input-file path must not be empty.');
    }
    return value;
  }
  return null;
}

class _GeneratedSourceParts {
  final Set<String> importUris;
  final String source;

  const _GeneratedSourceParts({required this.importUris, required this.source});
}

_GeneratedSourceParts _splitGeneratedSource(String source) {
  final importUris = <String>{};
  final sourceLines = <String>[];
  final importRegex = RegExp(r"^import '([^']+)';$");
  for (final line in LineSplitter.split(source)) {
    final trimmed = line.trim();
    final importMatch = importRegex.firstMatch(trimmed);
    if (importMatch != null) {
      importUris.add(importMatch.group(1)!);
      continue;
    }
    sourceLines.add(line);
  }
  return _GeneratedSourceParts(importUris: importUris, source: sourceLines.join('\n').trim());
}

Map<String, Object?> _asObjectMap(Object? value, String fieldName) {
  if (value is! Map) {
    throw FormatException('$fieldName must be an object.');
  }
  return value.map<String, Object?>(
    (Object? key, Object? mapValue) => MapEntry(key.toString(), mapValue),
  );
}

bool _isEmptyObjectMap(Object? value) {
  if (value is! Map) {
    return false;
  }
  return value.isEmpty;
}

String _readRequiredString(Map<String, Object?> map, String key, {required String fieldName}) {
  final value = map[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$fieldName must be a non-empty string.');
  }
  return value.trim();
}

String? _readOptionalString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return value.trim();
}

Set<String> _readRequiredPropertySet(Object? value, {required String fieldName}) {
  if (value == null) {
    return <String>{};
  }
  if (value is! List) {
    throw FormatException('$fieldName must be a list when provided.');
  }
  final result = <String>{};
  for (var index = 0; index < value.length; index += 1) {
    final entry = value[index];
    if (entry is! String || entry.trim().isEmpty) {
      throw FormatException('$fieldName[$index] must be a non-empty string.');
    }
    result.add(entry.trim());
  }
  return result;
}

String _toPascal(String value) {
  final parts = RegExp(
    r'[A-Za-z0-9]+',
  ).allMatches(value).map((match) => match.group(0)!).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return 'GeneratedModel';
  }
  final result = parts.map((part) => '${part[0].toUpperCase()}${part.substring(1)}').join();
  final startsWithDigit = RegExp(r'^[0-9]').hasMatch(result);
  return startsWithDigit ? 'N$result' : result;
}
