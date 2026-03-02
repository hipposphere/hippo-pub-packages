/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/foundation.dart';

import 'package:hippo_utils/hippo_utils.dart';

enum JsonSchemaEditorExtensionFieldType { string, number, boolean, stringEnum }

@immutable
class JsonSchemaEditorExtensionField {
  /// `applicableNodeTypes` allows scoping this extension to specific node kinds.
  /// Empty set means all node types.
  const JsonSchemaEditorExtensionField({
    required this.key,
    this.valueType = JsonSchemaEditorExtensionFieldType.string,
    this.description,
    this.defaultValue,
    this.enumValues = const [],
    this.applicableNodeTypes = const {},
  });

  final String key;
  final String? description;
  final JsonSchemaEditorExtensionFieldType valueType;
  final Object? defaultValue;
  final List<String> enumValues;
  final Set<JsonSchemaNodeType> applicableNodeTypes;

  bool get isString => valueType == JsonSchemaEditorExtensionFieldType.string;
  bool get isStringEnum => valueType == JsonSchemaEditorExtensionFieldType.stringEnum;
  bool get isNumber => valueType == JsonSchemaEditorExtensionFieldType.number;
  bool get isBoolean => valueType == JsonSchemaEditorExtensionFieldType.boolean;

  List<String> get availableEnumValues {
    if (!isStringEnum) {
      return const [];
    }
    if (enumValues.isEmpty) {
      return const [];
    }
    return List.unmodifiable(enumValues);
  }

  bool supportsNodeType(JsonSchemaNodeType type) {
    return applicableNodeTypes.isEmpty || applicableNodeTypes.contains(type);
  }

  String? get normalizedDescription {
    final rawDescription = description;
    if (rawDescription == null) {
      return null;
    }
    final trimmed = rawDescription.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

@immutable
class JsonSchemaEditorExtensionOptions {
  /// Describes which extension keys are editable for each node type and optional
  /// default values to prefill in the editor UI.
  /// Applies recursively to all node kinds (object, string, number, boolean, array).
  const JsonSchemaEditorExtensionOptions({
    this.configurableExtensionsForAllNodeTypes = const [],
    this.configurableExtensions = const {},
    this.allowAddExtensions = true,
  });

  static const JsonSchemaEditorExtensionOptions none = JsonSchemaEditorExtensionOptions();

  final List<JsonSchemaEditorExtensionField> configurableExtensionsForAllNodeTypes;
  final Map<JsonSchemaNodeType, List<JsonSchemaEditorExtensionField>> configurableExtensions;
  final bool allowAddExtensions;

  List<JsonSchemaEditorExtensionField> extensionsForNodeType(JsonSchemaNodeType type) {
    final merged = <String, JsonSchemaEditorExtensionField>{};

    for (final field in configurableExtensionsForAllNodeTypes) {
      if (!field.supportsNodeType(type)) {
        continue;
      }
      final key = field.key.trim();
      if (key.isNotEmpty) {
        merged[key] = field;
      }
    }

    final specific = configurableExtensions[type] ?? const [];
    for (final field in specific) {
      if (!field.supportsNodeType(type)) {
        continue;
      }
      final key = field.key.trim();
      if (key.isNotEmpty) {
        merged[key] = field;
      }
    }

    return List.unmodifiable(merged.values);
  }

  List<String> extensionKeysForNodeType(JsonSchemaNodeType type) {
    return extensionsForNodeType(type)
        .map((item) => item.key)
        .where((key) => key.isNotEmpty)
        .toList(growable: false);
  }

  bool isConfiguredForNodeType(JsonSchemaNodeType type, String key) {
    return extensionKeysForNodeType(type).contains(key);
  }

  Object? defaultValueFor(JsonSchemaNodeType type, String key) {
    for (final field in extensionsForNodeType(type)) {
      if (field.key == key) {
        return field.defaultValue;
      }
    }
    return null;
  }
}

@immutable
class JsonSchemaEditorFeatureOptions {
  const JsonSchemaEditorFeatureOptions({
    this.stringMinLength = true,
    this.stringMaxLength = true,
    this.stringPattern = true,
    this.stringEnum = true,
    this.numberMinimum = true,
    this.numberMaximum = true,
    this.numberExclusiveMinimum = true,
    this.numberExclusiveMaximum = true,
    this.numberMultipleOf = true,
    this.arrayMinItems = true,
    this.arrayMaxItems = true,
    this.arrayUniqueItems = true,
    this.objectAdditionalProperties = true,
  });

  static const JsonSchemaEditorFeatureOptions allEnabled = JsonSchemaEditorFeatureOptions();

  final bool stringMinLength;
  final bool stringMaxLength;
  final bool stringPattern;
  final bool stringEnum;
  final bool numberMinimum;
  final bool numberMaximum;
  final bool numberExclusiveMinimum;
  final bool numberExclusiveMaximum;
  final bool numberMultipleOf;
  final bool arrayMinItems;
  final bool arrayMaxItems;
  final bool arrayUniqueItems;
  final bool objectAdditionalProperties;

  bool get hasAnyStringConstraint =>
      stringMinLength || stringMaxLength || stringPattern || stringEnum;

  JsonSchemaEditorFeatureOptions copyWith({
    bool? stringMinLength,
    bool? stringMaxLength,
    bool? stringPattern,
    bool? stringEnum,
    bool? numberMinimum,
    bool? numberMaximum,
    bool? numberExclusiveMinimum,
    bool? numberExclusiveMaximum,
    bool? numberMultipleOf,
    bool? arrayMinItems,
    bool? arrayMaxItems,
    bool? arrayUniqueItems,
    bool? objectAdditionalProperties,
  }) {
    return JsonSchemaEditorFeatureOptions(
      stringMinLength: stringMinLength ?? this.stringMinLength,
      stringMaxLength: stringMaxLength ?? this.stringMaxLength,
      stringPattern: stringPattern ?? this.stringPattern,
      stringEnum: stringEnum ?? this.stringEnum,
      numberMinimum: numberMinimum ?? this.numberMinimum,
      numberMaximum: numberMaximum ?? this.numberMaximum,
      numberExclusiveMinimum: numberExclusiveMinimum ?? this.numberExclusiveMinimum,
      numberExclusiveMaximum: numberExclusiveMaximum ?? this.numberExclusiveMaximum,
      numberMultipleOf: numberMultipleOf ?? this.numberMultipleOf,
      arrayMinItems: arrayMinItems ?? this.arrayMinItems,
      arrayMaxItems: arrayMaxItems ?? this.arrayMaxItems,
      arrayUniqueItems: arrayUniqueItems ?? this.arrayUniqueItems,
      objectAdditionalProperties: objectAdditionalProperties ?? this.objectAdditionalProperties,
    );
  }
}
