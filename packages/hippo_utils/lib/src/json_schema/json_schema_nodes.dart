/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hippo_utils/hippo_utils.dart';

enum JsonSchemaNodeType { string, number, integer, boolean, object, array }

const _jsonSchemaStringNodeReservedKeys = <String>{
  'type',
  'title',
  'description',
  'minLength',
  'maxLength',
  'pattern',
  'enum',
};

const _jsonSchemaNumberNodeReservedKeys = <String>{
  'type',
  'title',
  'description',
  'minimum',
  'maximum',
  'exclusiveMinimum',
  'exclusiveMaximum',
  'multipleOf',
};

const _jsonSchemaBooleanNodeReservedKeys = <String>{'type', 'title', 'description', 'default'};

const _jsonSchemaObjectNodeReservedKeys = <String>{
  'type',
  'title',
  'description',
  'properties',
  'required',
  'additionalProperties',
};

const jsonSchemaObjectPropertyOrderExtensionKey = 'x-property-order';

const _jsonSchemaArrayNodeReservedKeys = <String>{
  'type',
  'title',
  'description',
  'items',
  'minItems',
  'maxItems',
  'uniqueItems',
};

@immutable
class JsonSchemaModel {
  const JsonSchemaModel._(this.raw);

  factory JsonSchemaModel(Map<String, dynamic> raw) {
    final normalized = raw.isEmpty ? <String, dynamic>{} : _normalizeMapStringKeys(raw);
    return JsonSchemaModel._(Map.unmodifiable(normalized));
  }

  factory JsonSchemaModel.fromNode(JsonSchemaNode node) {
    return JsonSchemaModel._(Map.unmodifiable(node.toJson()));
  }

  factory JsonSchemaModel.empty() => const JsonSchemaModel._({});

  final Map<String, dynamic> raw;

  JsonSchemaNode get node => JsonSchemaNode.fromJson(raw);

  Map<String, dynamic> toMap() {
    return _cloneMap(raw);
  }

  String toJsonString({bool pretty = false}) {
    if (pretty) {
      final encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(raw);
    }
    return jsonEncode(raw);
  }
}

Map<String, dynamic> _cloneMap(Map<String, dynamic> raw) {
  return raw.map((entryKey, entryValue) {
    if (entryValue is Map<String, dynamic>) {
      return MapEntry(entryKey, _cloneMap(entryValue));
    }
    if (entryValue is List) {
      return MapEntry(entryKey, _cloneList(entryValue));
    }
    return MapEntry(entryKey, entryValue);
  });
}

Map<String, dynamic> _normalizeMapStringKeys(Map<String, dynamic> raw) {
  final normalized = <String, dynamic>{};
  for (final entry in raw.entries) {
    final key = entry.key.toString();
    final value = entry.value;
    if (value is Map) {
      normalized[key] = _normalizeMapStringKeys(value.map((k, v) => MapEntry(k.toString(), v)));
    } else if (value is List) {
      normalized[key] = value.map((entry) {
        if (entry is Map) {
          return _normalizeMapStringKeys(entry.map((k, v) => MapEntry(k.toString(), v)));
        }
        return entry;
      }).toList();
    } else {
      normalized[key] = value;
    }
  }
  return normalized;
}

List<Object?> _cloneList(List<Object?> list) {
  return list.map((entry) {
    if (entry is Map<String, dynamic>) {
      return _cloneMap(entry);
    }
    if (entry is List) {
      return _cloneList(entry);
    }
    return entry;
  }).toList();
}

extension JsonSchemaNodeTypeJson on JsonSchemaNodeType {
  String toJsonType() {
    return switch (this) {
      JsonSchemaNodeType.string => 'string',
      JsonSchemaNodeType.number => 'number',
      JsonSchemaNodeType.integer => 'integer',
      JsonSchemaNodeType.boolean => 'boolean',
      JsonSchemaNodeType.object => 'object',
      JsonSchemaNodeType.array => 'array',
    };
  }
}

sealed class JsonSchemaNode {
  const JsonSchemaNode({
    required this.type,
    this.title,
    this.description,
    Map<String, dynamic>? extensions,
  }) : extensions = extensions ?? const {};

  final JsonSchemaNodeType type;
  final String? title;
  final String? description;
  final Map<String, dynamic> extensions;

  Map<String, dynamic> toJson();

  JsonSchema toSchema() => JsonSchema.fromNode(this);

  JsonSchemaNode copyWith({
    String? title,
    String? description,
    Map<String, dynamic>? extensions,
    bool clearExtensions = false,
  });

  static JsonSchemaNode fromJson(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const JsonSchemaObjectNode();
    }
    final normalized = _normalizeMapTypes(raw);

    final type = _readType(normalized);
    return switch (type) {
      JsonSchemaNodeType.string => JsonSchemaStringNode._fromJson(normalized),
      JsonSchemaNodeType.number => JsonSchemaNumberNode._fromJson(
        normalized,
        JsonSchemaNodeType.number,
      ),
      JsonSchemaNodeType.integer => JsonSchemaNumberNode._fromJson(
        normalized,
        JsonSchemaNodeType.integer,
      ),
      JsonSchemaNodeType.boolean => JsonSchemaBooleanNode._fromJson(normalized),
      JsonSchemaNodeType.object => JsonSchemaObjectNode._fromJson(normalized),
      JsonSchemaNodeType.array => JsonSchemaArrayNode._fromJson(normalized),
    };
  }

  static JsonSchemaNode emptyRoot() {
    return const JsonSchemaObjectNode();
  }

  static JsonSchemaNode defaultForType(
    JsonSchemaNodeType type, {
    String? title,
    String? description,
  }) {
    return switch (type) {
      JsonSchemaNodeType.string => JsonSchemaStringNode(title: title, description: description),
      JsonSchemaNodeType.number => JsonSchemaNumberNode.number(
        title: title,
        description: description,
      ),
      JsonSchemaNodeType.integer => JsonSchemaNumberNode.integer(
        title: title,
        description: description,
      ),
      JsonSchemaNodeType.boolean => JsonSchemaBooleanNode(title: title, description: description),
      JsonSchemaNodeType.object => JsonSchemaObjectNode(title: title, description: description),
      JsonSchemaNodeType.array => JsonSchemaArrayNode(
        title: title,
        description: description,
        items: const JsonSchemaStringNode(),
      ),
    };
  }
}

@immutable
class JsonSchemaStringNode extends JsonSchemaNode {
  const JsonSchemaStringNode({
    super.title,
    super.description,
    super.extensions,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.enumValues,
  }) : super(type: JsonSchemaNodeType.string);

  final int? minLength;
  final int? maxLength;
  final String? pattern;
  final List<String>? enumValues;

  factory JsonSchemaStringNode._fromJson(Map<String, dynamic> raw) {
    final extensions = _readExtensions(raw, _jsonSchemaStringNodeReservedKeys);

    return JsonSchemaStringNode(
      title: _readOptionalString(raw, 'title'),
      description: _readOptionalString(raw, 'description'),
      extensions: extensions,
      minLength: _readOptionalInt(raw, 'minLength'),
      maxLength: _readOptionalInt(raw, 'maxLength'),
      pattern: _readOptionalString(raw, 'pattern'),
      enumValues: _readOptionalStringList(raw, 'enum'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return _appendExtensions(
      _omitNulls({
        'type': type.toJsonType(),
        'title': title?.trim(),
        'description': description?.trim(),
        'minLength': minLength,
        'maxLength': maxLength,
        'pattern': pattern?.trim(),
        'enum': enumValues == null || enumValues!.isEmpty
            ? null
            : enumValues!.map((entry) => entry.trim()).where((entry) => entry.isNotEmpty).toList(),
      }),
      extensions,
    );
  }

  @override
  JsonSchemaStringNode copyWith({
    String? title,
    String? description,
    int? minLength,
    int? maxLength,
    String? pattern,
    List<String>? enumValues,
    Map<String, dynamic>? extensions,
    bool clearExtensions = false,
    bool clearTitle = false,
    bool clearDescription = false,
    bool clearMinLength = false,
    bool clearMaxLength = false,
    bool clearPattern = false,
    bool clearEnumValues = false,
  }) {
    return JsonSchemaStringNode(
      title: clearTitle ? null : (title ?? this.title),
      description: clearDescription ? null : (description ?? this.description),
      minLength: clearMinLength ? null : (minLength ?? this.minLength),
      maxLength: clearMaxLength ? null : (maxLength ?? this.maxLength),
      pattern: clearPattern ? null : (pattern ?? this.pattern),
      enumValues: clearEnumValues ? null : (enumValues ?? this.enumValues),
      extensions: clearExtensions ? const {} : (extensions ?? this.extensions),
    );
  }
}

@immutable
class JsonSchemaNumberNode extends JsonSchemaNode {
  const JsonSchemaNumberNode({
    super.title,
    super.description,
    super.extensions,
    required this.numberType,
    this.minimum,
    this.maximum,
    this.exclusiveMinimum,
    this.exclusiveMaximum,
    this.multipleOf,
  }) : super(type: numberType);

  final JsonSchemaNodeType numberType;
  final double? minimum;
  final double? maximum;
  final bool? exclusiveMinimum;
  final bool? exclusiveMaximum;
  final double? multipleOf;

  const JsonSchemaNumberNode.number({
    super.title,
    super.description,
    super.extensions,
    this.minimum,
    this.maximum,
    this.exclusiveMinimum,
    this.exclusiveMaximum,
    this.multipleOf,
  }) : numberType = JsonSchemaNodeType.number,
       super(type: JsonSchemaNodeType.number);

  const JsonSchemaNumberNode.integer({
    super.title,
    super.description,
    super.extensions,
    this.minimum,
    this.maximum,
    this.exclusiveMinimum,
    this.exclusiveMaximum,
    this.multipleOf,
  }) : numberType = JsonSchemaNodeType.integer,
       super(type: JsonSchemaNodeType.integer);

  factory JsonSchemaNumberNode._fromJson(Map<String, dynamic> raw, JsonSchemaNodeType numberType) {
    final extensions = _readExtensions(raw, _jsonSchemaNumberNodeReservedKeys);

    return JsonSchemaNumberNode(
      numberType: numberType,
      title: _readOptionalString(raw, 'title'),
      description: _readOptionalString(raw, 'description'),
      extensions: extensions,
      minimum: _readOptionalDouble(raw, 'minimum'),
      maximum: _readOptionalDouble(raw, 'maximum'),
      exclusiveMinimum: _readOptionalBool(raw, 'exclusiveMinimum'),
      exclusiveMaximum: _readOptionalBool(raw, 'exclusiveMaximum'),
      multipleOf: _readOptionalDouble(raw, 'multipleOf'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return _appendExtensions(
      _omitNulls({
        'type': type.toJsonType(),
        'title': title?.trim(),
        'description': description?.trim(),
        'minimum': minimum,
        'maximum': maximum,
        'exclusiveMinimum': exclusiveMinimum,
        'exclusiveMaximum': exclusiveMaximum,
        'multipleOf': multipleOf,
      }),
      extensions,
    );
  }

  @override
  JsonSchemaNumberNode copyWith({
    String? title,
    String? description,
    double? minimum,
    double? maximum,
    bool? exclusiveMinimum,
    bool? exclusiveMaximum,
    double? multipleOf,
    JsonSchemaNodeType? numberType,
    Map<String, dynamic>? extensions,
    bool clearExtensions = false,
    bool clearTitle = false,
    bool clearDescription = false,
    bool clearMinimum = false,
    bool clearMaximum = false,
    bool clearExclusiveMinimum = false,
    bool clearExclusiveMaximum = false,
    bool clearMultipleOf = false,
  }) {
    final resolvedType = numberType ?? this.numberType;
    return switch (resolvedType) {
      JsonSchemaNodeType.number => JsonSchemaNumberNode.number(
        title: clearTitle ? null : (title ?? this.title),
        description: clearDescription ? null : (description ?? this.description),
        minimum: clearMinimum ? null : (minimum ?? this.minimum),
        maximum: clearMaximum ? null : (maximum ?? this.maximum),
        exclusiveMinimum: clearExclusiveMinimum
            ? null
            : (exclusiveMinimum ?? this.exclusiveMinimum),
        exclusiveMaximum: clearExclusiveMaximum
            ? null
            : (exclusiveMaximum ?? this.exclusiveMaximum),
        multipleOf: clearMultipleOf ? null : (multipleOf ?? this.multipleOf),
        extensions: clearExtensions ? const {} : (extensions ?? this.extensions),
      ),
      JsonSchemaNodeType.integer => JsonSchemaNumberNode.integer(
        title: clearTitle ? null : (title ?? this.title),
        description: clearDescription ? null : (description ?? this.description),
        minimum: clearMinimum ? null : (minimum ?? this.minimum),
        maximum: clearMaximum ? null : (maximum ?? this.maximum),
        exclusiveMinimum: clearExclusiveMinimum
            ? null
            : (exclusiveMinimum ?? this.exclusiveMinimum),
        exclusiveMaximum: clearExclusiveMaximum
            ? null
            : (exclusiveMaximum ?? this.exclusiveMaximum),
        multipleOf: clearMultipleOf ? null : (multipleOf ?? this.multipleOf),
        extensions: clearExtensions ? const {} : (extensions ?? this.extensions),
      ),
      JsonSchemaNodeType.object => throw StateError(
        'Number nodes cannot have type ${JsonSchemaNodeType.object}.',
      ),
      JsonSchemaNodeType.boolean => throw StateError(
        'Number nodes cannot have type ${JsonSchemaNodeType.boolean}.',
      ),
      JsonSchemaNodeType.string => throw StateError(
        'Number nodes cannot have type ${JsonSchemaNodeType.string}.',
      ),
      JsonSchemaNodeType.array => throw StateError(
        'Number nodes cannot have type ${JsonSchemaNodeType.array}.',
      ),
    };
  }
}

@immutable
class JsonSchemaBooleanNode extends JsonSchemaNode {
  const JsonSchemaBooleanNode({super.title, super.description, super.extensions, this.defaultValue})
    : super(type: JsonSchemaNodeType.boolean);

  final bool? defaultValue;

  factory JsonSchemaBooleanNode._fromJson(Map<String, dynamic> raw) {
    final extensions = _readExtensions(raw, _jsonSchemaBooleanNodeReservedKeys);

    return JsonSchemaBooleanNode(
      title: _readOptionalString(raw, 'title'),
      description: _readOptionalString(raw, 'description'),
      extensions: extensions,
      defaultValue: _readOptionalBool(raw, 'default'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return _appendExtensions(
      _omitNulls({
        'type': type.toJsonType(),
        'title': title?.trim(),
        'description': description?.trim(),
        'default': defaultValue,
      }),
      extensions,
    );
  }

  @override
  JsonSchemaBooleanNode copyWith({
    String? title,
    String? description,
    bool? defaultValue,
    Map<String, dynamic>? extensions,
    bool clearTitle = false,
    bool clearDescription = false,
    bool clearDefaultValue = false,
    bool clearExtensions = false,
  }) {
    return JsonSchemaBooleanNode(
      title: clearTitle ? null : (title ?? this.title),
      description: clearDescription ? null : (description ?? this.description),
      extensions: clearExtensions ? const {} : (extensions ?? this.extensions),
      defaultValue: clearDefaultValue ? null : (defaultValue ?? this.defaultValue),
    );
  }
}

@immutable
class JsonSchemaObjectNode extends JsonSchemaNode {
  const JsonSchemaObjectNode({
    super.title,
    super.description,
    super.extensions,
    this.properties = const {},
    this.required = const {},
    this.additionalProperties = true,
  }) : super(type: JsonSchemaNodeType.object);

  final Map<String, JsonSchemaNode> properties;
  final Set<String> required;
  final bool additionalProperties;

  List<String> get resolvedPropertyOrder => _resolveJsonSchemaObjectPropertyOrder(
    properties,
    extensions[jsonSchemaObjectPropertyOrderExtensionKey],
  );

  Iterable<MapEntry<String, JsonSchemaNode>> get orderedPropertyEntries sync* {
    for (final key in resolvedPropertyOrder) {
      final value = properties[key];
      if (value == null) {
        continue;
      }
      yield MapEntry(key, value);
    }
  }

  Map<String, JsonSchemaNode> get orderedProperties =>
      Map.unmodifiable(Map<String, JsonSchemaNode>.fromEntries(orderedPropertyEntries));

  Map<String, dynamic> get normalizedExtensions =>
      _normalizeJsonSchemaObjectExtensions(properties: properties, extensions: extensions);

  JsonSchemaObjectNode withPropertyOrder(Iterable<String> propertyOrder) {
    final normalizedOrder = _resolveJsonSchemaObjectPropertyOrder(
      properties,
      propertyOrder.toList(growable: false),
    );
    final orderedProperties = _orderJsonSchemaObjectProperties(properties, normalizedOrder);
    return copyWith(
      properties: orderedProperties,
      extensions: _normalizeJsonSchemaObjectExtensions(
        properties: orderedProperties,
        extensions: extensions,
        propertyOrder: normalizedOrder,
      ),
    );
  }

  factory JsonSchemaObjectNode._fromJson(Map<String, dynamic> raw) {
    final properties = _readProperties(raw['properties']);
    final required = _readRequired(raw['required']);
    final extensions = _readExtensions(raw, _jsonSchemaObjectNodeReservedKeys);

    return JsonSchemaObjectNode(
      title: _readOptionalString(raw, 'title'),
      description: _readOptionalString(raw, 'description'),
      extensions: extensions,
      properties: properties,
      required: required,
      additionalProperties: _readOptionalBool(raw, 'additionalProperties') ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final requiredList = required.where((entry) => properties.containsKey(entry)).toList()..sort();
    final orderedProperties = this.orderedProperties;

    return _appendExtensions(
      _omitNulls({
        'type': 'object',
        'title': title?.trim(),
        'description': description?.trim(),
        'properties': orderedProperties.isEmpty
            ? null
            : orderedProperties.map((key, value) => MapEntry(key, value.toJson())),
        'required': requiredList.isEmpty ? null : requiredList,
        'additionalProperties': additionalProperties ? null : false,
      }),
      normalizedExtensions,
    );
  }

  @override
  JsonSchemaObjectNode copyWith({
    String? title,
    String? description,
    Map<String, JsonSchemaNode>? properties,
    Set<String>? required,
    bool? additionalProperties,
    Map<String, dynamic>? extensions,
    bool clearTitle = false,
    bool clearDescription = false,
    bool clearProperties = false,
    bool clearRequired = false,
    bool clearAdditionalProperties = false,
    bool clearExtensions = false,
  }) {
    return JsonSchemaObjectNode(
      title: clearTitle ? null : (title ?? this.title),
      description: clearDescription ? null : (description ?? this.description),
      properties: clearProperties ? const {} : (properties ?? this.properties),
      required: clearRequired ? const {} : (required ?? this.required),
      additionalProperties: clearAdditionalProperties
          ? true
          : (additionalProperties ?? this.additionalProperties),
      extensions: clearExtensions ? const {} : (extensions ?? this.extensions),
    );
  }
}

@immutable
class JsonSchemaArrayNode extends JsonSchemaNode {
  const JsonSchemaArrayNode({
    super.title,
    super.description,
    super.extensions,
    required this.items,
    this.minItems,
    this.maxItems,
    this.uniqueItems,
  }) : super(type: JsonSchemaNodeType.array);

  final JsonSchemaNode items;
  final int? minItems;
  final int? maxItems;
  final bool? uniqueItems;

  factory JsonSchemaArrayNode._fromJson(Map<String, dynamic> raw) {
    final items = raw['items'];
    JsonSchemaNode parsedItems;
    if (items is Map<String, dynamic>) {
      parsedItems = JsonSchemaNode.fromJson(items);
    } else if (items is Map) {
      parsedItems = JsonSchemaNode.fromJson(
        items.map((entryKey, entryValue) => MapEntry(entryKey.toString(), entryValue)),
      );
    } else {
      parsedItems = const JsonSchemaStringNode();
    }
    final extensions = _readExtensions(raw, _jsonSchemaArrayNodeReservedKeys);

    return JsonSchemaArrayNode(
      title: _readOptionalString(raw, 'title'),
      description: _readOptionalString(raw, 'description'),
      extensions: extensions,
      items: parsedItems,
      minItems: _readOptionalInt(raw, 'minItems'),
      maxItems: _readOptionalInt(raw, 'maxItems'),
      uniqueItems: _readOptionalBool(raw, 'uniqueItems'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return _appendExtensions(
      _omitNulls({
        'type': 'array',
        'title': title?.trim(),
        'description': description?.trim(),
        'items': items.toJson(),
        'minItems': minItems,
        'maxItems': maxItems,
        'uniqueItems': uniqueItems,
      }),
      extensions,
    );
  }

  @override
  JsonSchemaArrayNode copyWith({
    String? title,
    String? description,
    JsonSchemaNode? items,
    int? minItems,
    int? maxItems,
    bool? uniqueItems,
    Map<String, dynamic>? extensions,
    bool clearTitle = false,
    bool clearDescription = false,
    bool clearItems = false,
    bool clearMinItems = false,
    bool clearMaxItems = false,
    bool clearUniqueItems = false,
    bool clearExtensions = false,
  }) {
    return JsonSchemaArrayNode(
      title: clearTitle ? null : (title ?? this.title),
      description: clearDescription ? null : (description ?? this.description),
      items: clearItems ? const JsonSchemaStringNode() : (items ?? this.items),
      minItems: clearMinItems ? null : (minItems ?? this.minItems),
      maxItems: clearMaxItems ? null : (maxItems ?? this.maxItems),
      uniqueItems: clearUniqueItems ? null : (uniqueItems ?? this.uniqueItems),
      extensions: clearExtensions ? const {} : (extensions ?? this.extensions),
    );
  }
}

JsonSchemaNodeType _readType(Map<String, dynamic> raw) {
  final rawType = raw['type'];
  if (rawType is String) {
    return _parseTypeString(rawType);
  }
  if (rawType is List) {
    final types = rawType.whereType<String>().map((entry) => entry.trim()).toSet();
    final hasNull = types.remove('null');
    final withoutNull = types.where((entry) => entry.isNotEmpty).toSet();
    if (hasNull && withoutNull.length == 1) {
      return _parseTypeString(withoutNull.first);
    }
    if (types.length == 1) {
      return _parseTypeString(types.first);
    }
    return _inferTypeFromShape(raw);
  }

  return _inferTypeFromShape(raw);
}

JsonSchemaNodeType _inferTypeFromShape(Map<String, dynamic> raw) {
  if (raw.containsKey('enum')) {
    final rawEnum = raw['enum'];
    if (rawEnum is List && rawEnum.isNotEmpty) {
      final allBool = rawEnum.every((value) => value is bool);
      if (allBool) {
        return JsonSchemaNodeType.boolean;
      }
    }
  }
  if (raw.containsKey('properties') || raw.containsKey('additionalProperties')) {
    return JsonSchemaNodeType.object;
  }
  if (raw.containsKey('items')) {
    return JsonSchemaNodeType.array;
  }
  if (raw.containsKey('default') && raw['default'] is bool) {
    return JsonSchemaNodeType.boolean;
  }
  if (raw.containsKey('enum')) {
    return JsonSchemaNodeType.string;
  }
  if (raw.containsKey('pattern') || raw.containsKey('minLength') || raw.containsKey('maxLength')) {
    return JsonSchemaNodeType.string;
  }
  return JsonSchemaNodeType.object;
}

JsonSchemaNodeType _parseTypeString(String rawType) {
  return switch (rawType.trim()) {
    'string' => JsonSchemaNodeType.string,
    'number' => JsonSchemaNodeType.number,
    'integer' => JsonSchemaNodeType.integer,
    'bool' => JsonSchemaNodeType.boolean,
    'boolean' => JsonSchemaNodeType.boolean,
    'object' => JsonSchemaNodeType.object,
    'array' => JsonSchemaNodeType.array,
    _ => JsonSchemaNodeType.object,
  };
}

Map<String, dynamic> _normalizeMapTypes(Map<String, dynamic> raw) {
  final converted = raw.map<String, dynamic>((key, value) {
    return MapEntry(key.toString(), value);
  });
  return _parseNestedObjects(converted);
}

Map<String, dynamic> _parseNestedObjects(Map<String, dynamic> raw) {
  return raw.map((key, value) {
    if (value is Map) {
      final valueAsMap = value.map(
        (entryKey, entryValue) => MapEntry(entryKey.toString(), entryValue),
      );
      return MapEntry(key, _parseNestedObjects(valueAsMap));
    }
    if (value is List) {
      return MapEntry(
        key,
        value
            .map(
              (entry) => entry is Map
                  ? _parseNestedObjects(
                      entry.map(
                        (entryKey, entryValue) => MapEntry(entryKey.toString(), entryValue),
                      ),
                    )
                  : entry,
            )
            .toList(),
      );
    }
    return MapEntry(key, value);
  });
}

Map<String, JsonSchemaNode> _readProperties(Object? rawProperties) {
  if (rawProperties is! Map) {
    return {};
  }
  final parsed = <String, JsonSchemaNode>{};
  for (final entry in rawProperties.entries) {
    final key = entry.key.toString().trim();
    if (key.isEmpty) {
      continue;
    }
    if (entry.value is Map<String, dynamic>) {
      parsed[key] = JsonSchemaNode.fromJson(Map<String, dynamic>.from(entry.value as Map));
    } else if (entry.value is Map) {
      parsed[key] = JsonSchemaNode.fromJson(
        Map<String, dynamic>.fromEntries(
          entry.value.entries.map((entry) => MapEntry(entry.key.toString(), entry.value)),
        ),
      );
    } else {
      parsed[key] = const JsonSchemaStringNode();
    }
  }
  return parsed;
}

List<String> _resolveJsonSchemaObjectPropertyOrder(
  Map<String, JsonSchemaNode> properties,
  Object? rawPropertyOrder,
) {
  if (properties.isEmpty) {
    return const [];
  }

  final propertyKeys = properties.keys.toList(growable: false);
  final resolved = <String>[];
  final configuredOrder = _readPropertyOrder(rawPropertyOrder);

  for (final key in configuredOrder) {
    if (!properties.containsKey(key) || resolved.contains(key)) {
      continue;
    }
    resolved.add(key);
  }

  for (final key in propertyKeys) {
    if (!resolved.contains(key)) {
      resolved.add(key);
    }
  }

  return List.unmodifiable(resolved);
}

Map<String, JsonSchemaNode> _orderJsonSchemaObjectProperties(
  Map<String, JsonSchemaNode> properties,
  Iterable<String> propertyOrder,
) {
  final ordered = <String, JsonSchemaNode>{};
  for (final key in propertyOrder) {
    final value = properties[key];
    if (value == null) {
      continue;
    }
    ordered[key] = value;
  }
  return Map.unmodifiable(ordered);
}

List<String> _readPropertyOrder(Object? rawPropertyOrder) {
  if (rawPropertyOrder == null) {
    return const [];
  }
  if (rawPropertyOrder is String) {
    return _readStringListFromText(rawPropertyOrder) ?? const [];
  }
  if (rawPropertyOrder is! List) {
    return const [];
  }

  final order = <String>[];
  for (final entry in rawPropertyOrder) {
    if (entry is! String) {
      continue;
    }
    final trimmed = entry.trim();
    if (trimmed.isEmpty || order.contains(trimmed)) {
      continue;
    }
    order.add(trimmed);
  }
  return List.unmodifiable(order);
}

Set<String> _readRequired(Object? rawRequired) {
  if (rawRequired is! List) {
    return {};
  }
  final parsed = <String>{};
  for (final entry in rawRequired) {
    if (entry is String && entry.trim().isNotEmpty) {
      parsed.add(entry.trim());
    }
  }
  return parsed;
}

String? _readOptionalString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

List<String>? _readOptionalStringList(Map<String, dynamic> map, String key) {
  final raw = map[key];
  if (raw == null) {
    return null;
  }
  if (raw is String) {
    return _readStringListFromText(raw);
  }
  if (raw is List) {
    final parsed = <String>[];
    for (final value in raw) {
      if (value is! String) {
        continue;
      }
      final trimmed = value.trim();
      if (trimmed.isNotEmpty && !parsed.contains(trimmed)) {
        parsed.add(trimmed);
      }
    }
    if (parsed.isEmpty) {
      return null;
    }
    return parsed;
  }
  return null;
}

List<String>? _readStringListFromText(String raw) {
  final entries = <String>[];
  final tokens = raw.split(RegExp(r'[\n,]'));
  for (final token in tokens) {
    final trimmed = token.trim();
    if (trimmed.isNotEmpty && !entries.contains(trimmed)) {
      entries.add(trimmed);
    }
  }
  if (entries.isEmpty) {
    return null;
  }
  return entries;
}

double? _readOptionalDouble(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

int? _readOptionalInt(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

bool? _readOptionalBool(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is bool) {
    return value;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
  }
  return null;
}

Map<String, Object?> _omitNulls(Map<String, Object?> raw) {
  final output = <String, Object?>{};
  for (final entry in raw.entries) {
    final value = entry.value;
    if (value == null) {
      continue;
    }
    if (value is String && value.trim().isEmpty) {
      continue;
    }
    output[entry.key] = value;
  }
  return output;
}

Map<String, dynamic> _readExtensions(Map<String, dynamic> raw, Set<String> reservedKeys) {
  final extensionEntries = <String, dynamic>{};
  for (final entry in raw.entries) {
    if (reservedKeys.contains(entry.key.toString())) {
      continue;
    }
    extensionEntries[entry.key.toString()] = entry.value;
  }
  return _normalizeCustomProperties(extensionEntries);
}

Map<String, dynamic> _normalizeCustomProperties(Map<String, dynamic> values) {
  if (values.isEmpty) {
    return const {};
  }
  final normalized = <String, dynamic>{};
  for (final entry in values.entries) {
    final key = entry.key.toString().trim();
    if (key.isEmpty) {
      continue;
    }
    final value = _cloneExtensionValue(entry.value);
    if (value == null) {
      continue;
    }
    normalized[key] = value;
  }
  if (normalized.isEmpty) {
    return const {};
  }
  return Map.unmodifiable(normalized);
}

Map<String, dynamic> _normalizeJsonSchemaObjectExtensions({
  required Map<String, JsonSchemaNode> properties,
  required Map<String, dynamic> extensions,
  Iterable<String>? propertyOrder,
}) {
  final normalized = Map<String, dynamic>.from(_normalizeCustomProperties(extensions));
  final resolvedPropertyOrder = propertyOrder == null
      ? _resolveJsonSchemaObjectPropertyOrder(
          properties,
          normalized[jsonSchemaObjectPropertyOrderExtensionKey],
        )
      : _resolveJsonSchemaObjectPropertyOrder(properties, propertyOrder.toList(growable: false));

  if (resolvedPropertyOrder.isEmpty) {
    normalized.remove(jsonSchemaObjectPropertyOrderExtensionKey);
  } else {
    normalized[jsonSchemaObjectPropertyOrderExtensionKey] = List.unmodifiable(
      resolvedPropertyOrder,
    );
  }

  if (normalized.isEmpty) {
    return const {};
  }
  return Map.unmodifiable(normalized);
}

Map<String, Object?> _appendExtensions(Map<String, Object?> raw, Map<String, dynamic> extensions) {
  final output = <String, Object?>{};
  output.addAll(raw);
  output.addAll(_normalizeCustomProperties(extensions));
  return _omitNulls(output);
}

Object? _cloneExtensionValue(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is Map) {
    final normalized = <String, dynamic>{};
    for (final entry in value.entries) {
      normalized[entry.key.toString()] = _cloneExtensionValue(entry.value);
    }
    return Map.unmodifiable(normalized);
  }
  if (value is List) {
    final cloned = value.map((entry) => _cloneExtensionValue(entry)).toList(growable: false);
    return List.unmodifiable(cloned);
  }
  return value;
}
