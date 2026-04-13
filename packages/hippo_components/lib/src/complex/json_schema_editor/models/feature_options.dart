/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:flutter/widgets.dart';

import 'package:hippo_components/src/base/utils/typedefs.dart';
import 'package:hippo_utils/hippo_utils.dart';

enum JsonSchemaEditorExtensionFieldType { string, number, boolean, stringEnum }

enum JsonSchemaEditorExtensionFieldScope { root, objectProperty, arrayItem }

@immutable
class JsonSchemaEditorExtensionField {
  /// `applicableNodeTypes` allows scoping this extension to specific node kinds.
  /// Empty set means all node types.
  /// `applicableScopes` allows scoping this extension to root, object-property,
  /// or array-item node locations. Empty set means all node scopes.
  const JsonSchemaEditorExtensionField({
    required this.key,
    this.label,
    this.valueType = JsonSchemaEditorExtensionFieldType.string,
    this.description,
    this.defaultValue,
    this.enumValues = const [],
    this.minLines = 1,
    this.maxLines = 1,
    this.applicableNodeTypes = const {},
    this.applicableScopes = const {},
  }) : assert(minLines > 0, 'minLines must be greater than 0'),
       assert(maxLines >= minLines, 'maxLines must be greater than or equal to minLines');

  final String key;
  final Contextable<String>? label;
  final Contextable<String>? description;
  final JsonSchemaEditorExtensionFieldType valueType;
  final Object? defaultValue;
  final List<String> enumValues;
  final int minLines;
  final int maxLines;
  final Set<JsonSchemaNodeType> applicableNodeTypes;
  final Set<JsonSchemaEditorExtensionFieldScope> applicableScopes;

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

  bool supportsPath(JsonSchemaPath path) {
    if (applicableScopes.isEmpty) {
      return true;
    }
    return applicableScopes.contains(_extensionFieldScopeForPath(path));
  }

  String? resolveLabel(BuildContext context) {
    return _normalizedString(label?.call(context));
  }

  String? resolveDescription(BuildContext context) {
    return _normalizedString(description?.call(context));
  }

  String resolveDisplayLabel(BuildContext context) {
    final resolvedLabel = resolveLabel(context);
    if (resolvedLabel != null) {
      return resolvedLabel;
    }
    final trimmedKey = key.trim();
    return trimmedKey.isEmpty ? key : trimmedKey;
  }

  String displayLabel(BuildContext context) {
    final resolvedLabel = resolveLabel(context);
    if (resolvedLabel != null) {
      return resolvedLabel;
    }
    final trimmedKey = key.trim();
    return trimmedKey.isEmpty ? key : trimmedKey;
  }
}

String? _normalizedString(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

@immutable
class JsonSchemaEditorExtensionOptions {
  /// Describes which extension keys are editable and optional default values to
  /// prefill in the editor UI.
  /// Each field can scope itself to node types and node positions via
  /// `applicableNodeTypes` and `applicableScopes`.
  const JsonSchemaEditorExtensionOptions({
    this.configurableExtensions = const [],
    this.allowAddExtensions = true,
  });

  static const JsonSchemaEditorExtensionOptions none = JsonSchemaEditorExtensionOptions();

  final List<JsonSchemaEditorExtensionField> configurableExtensions;
  final bool allowAddExtensions;

  List<JsonSchemaEditorExtensionField> extensionsForNodeType(
    JsonSchemaNodeType type, {
    JsonSchemaPath? path,
  }) {
    final merged = <String, JsonSchemaEditorExtensionField>{};
    for (final field in configurableExtensions) {
      if (!field.supportsNodeType(type) || (path != null && !field.supportsPath(path))) {
        continue;
      }
      final key = field.key.trim();
      if (key.isNotEmpty) {
        merged[key] = field;
      }
    }

    return List.unmodifiable(merged.values);
  }

  List<String> extensionKeysForNodeType(JsonSchemaNodeType type, {JsonSchemaPath? path}) {
    return extensionsForNodeType(
      type,
      path: path,
    ).map((item) => item.key).where((key) => key.isNotEmpty).toList(growable: false);
  }

  bool isConfiguredForNodeType(JsonSchemaNodeType type, String key, {JsonSchemaPath? path}) {
    return extensionKeysForNodeType(type, path: path).contains(key);
  }

  Object? defaultValueFor(JsonSchemaNodeType type, String key, {JsonSchemaPath? path}) {
    for (final field in extensionsForNodeType(type, path: path)) {
      if (field.key == key) {
        return field.defaultValue;
      }
    }
    return null;
  }
}

JsonSchemaEditorExtensionFieldScope _extensionFieldScopeForPath(JsonSchemaPath path) {
  if (path.isRoot) {
    return JsonSchemaEditorExtensionFieldScope.root;
  }
  final lastSegment = path.last;
  if (lastSegment is JsonSchemaItemsPathSegment) {
    return JsonSchemaEditorExtensionFieldScope.arrayItem;
  }
  return JsonSchemaEditorExtensionFieldScope.objectProperty;
}

@immutable
class JsonSchemaEditorStringFeatureOptions {
  const JsonSchemaEditorStringFeatureOptions({
    this.minLength = true,
    this.maxLength = true,
    this.pattern = true,
    this.enumValues = true,
  });

  static const JsonSchemaEditorStringFeatureOptions allEnabled =
      JsonSchemaEditorStringFeatureOptions();

  final bool minLength;
  final bool maxLength;
  final bool pattern;
  final bool enumValues;

  bool get hasAnyConstraint => minLength || maxLength || pattern || enumValues;

  JsonSchemaEditorStringFeatureOptions copyWith({
    bool? minLength,
    bool? maxLength,
    bool? pattern,
    bool? enumValues,
  }) {
    return JsonSchemaEditorStringFeatureOptions(
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      pattern: pattern ?? this.pattern,
      enumValues: enumValues ?? this.enumValues,
    );
  }
}

@immutable
class JsonSchemaEditorNumberFeatureOptions {
  const JsonSchemaEditorNumberFeatureOptions({
    this.minimum = true,
    this.maximum = true,
    this.exclusiveMinimum = true,
    this.exclusiveMaximum = true,
    this.multipleOf = true,
  });

  static const JsonSchemaEditorNumberFeatureOptions allEnabled =
      JsonSchemaEditorNumberFeatureOptions();

  final bool minimum;
  final bool maximum;
  final bool exclusiveMinimum;
  final bool exclusiveMaximum;
  final bool multipleOf;

  JsonSchemaEditorNumberFeatureOptions copyWith({
    bool? minimum,
    bool? maximum,
    bool? exclusiveMinimum,
    bool? exclusiveMaximum,
    bool? multipleOf,
  }) {
    return JsonSchemaEditorNumberFeatureOptions(
      minimum: minimum ?? this.minimum,
      maximum: maximum ?? this.maximum,
      exclusiveMinimum: exclusiveMinimum ?? this.exclusiveMinimum,
      exclusiveMaximum: exclusiveMaximum ?? this.exclusiveMaximum,
      multipleOf: multipleOf ?? this.multipleOf,
    );
  }
}

@immutable
class JsonSchemaEditorBooleanFeatureOptions {
  const JsonSchemaEditorBooleanFeatureOptions({this.defaultValue = true});

  static const JsonSchemaEditorBooleanFeatureOptions allEnabled =
      JsonSchemaEditorBooleanFeatureOptions();

  final bool defaultValue;

  JsonSchemaEditorBooleanFeatureOptions copyWith({bool? defaultValue}) {
    return JsonSchemaEditorBooleanFeatureOptions(defaultValue: defaultValue ?? this.defaultValue);
  }
}

@immutable
class JsonSchemaEditorArrayFeatureOptions {
  const JsonSchemaEditorArrayFeatureOptions({
    this.minItems = true,
    this.maxItems = true,
    this.uniqueItems = true,
  });

  static const JsonSchemaEditorArrayFeatureOptions allEnabled =
      JsonSchemaEditorArrayFeatureOptions();

  final bool minItems;
  final bool maxItems;
  final bool uniqueItems;

  JsonSchemaEditorArrayFeatureOptions copyWith({
    bool? minItems,
    bool? maxItems,
    bool? uniqueItems,
  }) {
    return JsonSchemaEditorArrayFeatureOptions(
      minItems: minItems ?? this.minItems,
      maxItems: maxItems ?? this.maxItems,
      uniqueItems: uniqueItems ?? this.uniqueItems,
    );
  }
}

@immutable
class JsonSchemaEditorObjectFeatureOptions {
  const JsonSchemaEditorObjectFeatureOptions({this.additionalProperties = true});

  static const JsonSchemaEditorObjectFeatureOptions allEnabled =
      JsonSchemaEditorObjectFeatureOptions();

  final bool additionalProperties;

  JsonSchemaEditorObjectFeatureOptions copyWith({bool? additionalProperties}) {
    return JsonSchemaEditorObjectFeatureOptions(
      additionalProperties: additionalProperties ?? this.additionalProperties,
    );
  }
}

@immutable
class JsonSchemaEditorFeatureOptions {
  const JsonSchemaEditorFeatureOptions({
    this.stringOptions = JsonSchemaEditorStringFeatureOptions.allEnabled,
    this.numberOptions = JsonSchemaEditorNumberFeatureOptions.allEnabled,
    this.booleanOptions = JsonSchemaEditorBooleanFeatureOptions.allEnabled,
    this.arrayOptions = JsonSchemaEditorArrayFeatureOptions.allEnabled,
    this.objectOptions = JsonSchemaEditorObjectFeatureOptions.allEnabled,
  });

  static const JsonSchemaEditorFeatureOptions allEnabled = JsonSchemaEditorFeatureOptions();

  final JsonSchemaEditorStringFeatureOptions stringOptions;
  final JsonSchemaEditorNumberFeatureOptions numberOptions;
  final JsonSchemaEditorBooleanFeatureOptions booleanOptions;
  final JsonSchemaEditorArrayFeatureOptions arrayOptions;
  final JsonSchemaEditorObjectFeatureOptions objectOptions;

  bool get hasAnyStringConstraint => stringOptions.hasAnyConstraint;

  JsonSchemaEditorFeatureOptions copyWith({
    JsonSchemaEditorStringFeatureOptions? stringOptions,
    JsonSchemaEditorNumberFeatureOptions? numberOptions,
    JsonSchemaEditorBooleanFeatureOptions? booleanOptions,
    JsonSchemaEditorArrayFeatureOptions? arrayOptions,
    JsonSchemaEditorObjectFeatureOptions? objectOptions,
  }) {
    return JsonSchemaEditorFeatureOptions(
      stringOptions: stringOptions ?? this.stringOptions,
      numberOptions: numberOptions ?? this.numberOptions,
      booleanOptions: booleanOptions ?? this.booleanOptions,
      arrayOptions: arrayOptions ?? this.arrayOptions,
      objectOptions: objectOptions ?? this.objectOptions,
    );
  }
}
