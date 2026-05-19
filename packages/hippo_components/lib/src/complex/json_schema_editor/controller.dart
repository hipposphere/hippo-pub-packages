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

import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'models/feature_options.dart';

class JsonSchemaEditorController {
  factory JsonSchemaEditorController({
    JsonSchema? initialSchema,
    void Function(JsonSchemaNode schema, List<JsonSchemaDiagnostic> diagnostics)? onSchemaChanged,
    JsonSchemaEditorFeatureOptions featureOptions = JsonSchemaEditorFeatureOptions.allEnabled,
    // Controls which extension fields are shown as editable fields per node type.
    JsonSchemaEditorExtensionOptions extensionOptions = JsonSchemaEditorExtensionOptions.none,
    Iterable<JsonSchemaValidator> customValidators = const [],
  }) {
    final start = _normalizeNodeWithOptions(
      initialSchema?.node ?? const JsonSchemaObjectNode(),
      featureOptions,
    );
    return JsonSchemaEditorController._(
      initialSchema: start,
      onSchemaChanged: onSchemaChanged,
      featureOptions: featureOptions,
      extensionOptions: extensionOptions,
      customValidators: customValidators,
    );
  }

  JsonSchemaEditorController._({
    required JsonSchemaNode initialSchema,
    this.onSchemaChanged,
    this.featureOptions = JsonSchemaEditorFeatureOptions.allEnabled,
    this.extensionOptions = JsonSchemaEditorExtensionOptions.none,
    Iterable<JsonSchemaValidator> customValidators = const [],
  }) : customValidators = List<JsonSchemaValidator>.unmodifiable(customValidators),
       schemaSubject = DataSubject.seeded(initialSchema) {
    final parsed = _normalizeNode(initialSchema);
    _initialSchema = parsed;
    _initialJsonSchema = JsonSchema.fromNode(parsed);
    _apply(parsed, notify: false);
  }

  final void Function(JsonSchemaNode schema, List<JsonSchemaDiagnostic> diagnostics)?
  onSchemaChanged;
  final JsonSchemaEditorFeatureOptions featureOptions;
  final JsonSchemaEditorExtensionOptions extensionOptions;
  final List<JsonSchemaValidator> customValidators;

  late JsonSchemaNode _initialSchema;
  late JsonSchema _initialJsonSchema;

  final DataSubject<JsonSchemaNode> schemaSubject;
  final DataSubject<List<JsonSchemaDiagnostic>> diagnosticsSubject = DataSubject.seeded(const []);

  JsonSchemaNode get schema => schemaSubject.value;

  JsonSchemaNode get initialSchema => _initialSchema;
  JsonSchema get initialJsonSchema => _initialJsonSchema;

  List<JsonSchemaDiagnostic> get diagnostics => diagnosticsSubject.value;
  List<JsonSchemaEditorExtensionField> getConfiguredExtensions(
    JsonSchemaNodeType type, {
    JsonSchemaPath? path,
  }) {
    return List.unmodifiable(extensionOptions.extensionsForNodeType(type, path: path));
  }

  List<String> getConfiguredExtensionKeys(JsonSchemaNodeType type, {JsonSchemaPath? path}) =>
      extensionOptions.extensionKeysForNodeType(type, path: path);

  void setRoot(JsonSchemaNode next) {
    _apply(_normalizeNode(next));
  }

  void replaceNode({required JsonSchemaPath path, required JsonSchemaNode node}) {
    if (path.isRoot) {
      setRoot(node);
      return;
    }

    final next = _replaceNodeAtPath(schema, path, node);
    _apply(next);
  }

  void updateNode<T extends JsonSchemaNode>({
    required JsonSchemaPath path,
    required T Function(T node) updater,
  }) {
    final current = _findNodeAtPath(schema, path);
    if (current is! T) {
      return;
    }
    replaceNode(path: path, node: updater(current));
  }

  void addProperty({
    required JsonSchemaPath objectPath,
    required String key,
    JsonSchemaNode? node,
  }) {
    final target = _findNodeAtPath(schema, objectPath);
    if (target is! JsonSchemaObjectNode) {
      return;
    }

    var propertyKey = key.trim();
    if (propertyKey.isEmpty) {
      propertyKey = _nextPropertyKey(target.properties.keys.toList());
    }
    propertyKey = _ensureUniquePropertyKey(target.properties.keys.toList(), propertyKey);

    final nextProperties = Map<String, JsonSchemaNode>.from(target.properties);
    nextProperties[propertyKey] = node ?? const JsonSchemaStringNode();

    final next = target.copyWith(
      properties: nextProperties,
      extensions: _extensionsWithPropertyOrder(
        target,
        nextProperties: nextProperties,
        propertyOrder: [...target.resolvedPropertyOrder, propertyKey],
      ),
    );
    replaceNode(path: objectPath, node: next);
  }

  void removeProperty({required JsonSchemaPath objectPath, required String key}) {
    final target = _findNodeAtPath(schema, objectPath);
    if (target is! JsonSchemaObjectNode) {
      return;
    }
    if (!target.properties.containsKey(key)) {
      return;
    }
    final nextProperties = Map<String, JsonSchemaNode>.from(target.properties)..remove(key);
    final nextRequired = Set<String>.from(target.required)..remove(key);
    replaceNode(
      path: objectPath,
      node: target.copyWith(
        properties: nextProperties,
        required: nextRequired,
        extensions: _extensionsWithPropertyOrder(
          target,
          nextProperties: nextProperties,
          propertyOrder: target.resolvedPropertyOrder.where((entry) => entry != key),
        ),
      ),
    );
  }

  void renameProperty({
    required JsonSchemaPath objectPath,
    required String currentKey,
    required String nextKey,
  }) {
    final target = _findNodeAtPath(schema, objectPath);
    if (target is! JsonSchemaObjectNode) {
      return;
    }
    final trimmedNextKey = nextKey.trim();
    final trimmedCurrentKey = currentKey.trim();
    if (trimmedCurrentKey.isEmpty ||
        trimmedNextKey.isEmpty ||
        trimmedCurrentKey == trimmedNextKey ||
        !target.properties.containsKey(trimmedCurrentKey) ||
        target.properties.containsKey(trimmedNextKey)) {
      return;
    }

    final nextProperties = Map<String, JsonSchemaNode>.fromEntries(
      target.properties.entries.map((entry) {
        if (entry.key == trimmedCurrentKey) {
          return MapEntry(trimmedNextKey, entry.value);
        }
        return entry;
      }),
    );

    final nextRequired = Set<String>.from(target.required)..remove(trimmedCurrentKey);
    if (target.required.contains(trimmedCurrentKey)) {
      nextRequired.add(trimmedNextKey);
    }
    replaceNode(
      path: objectPath,
      node: target.copyWith(
        properties: nextProperties,
        required: nextRequired,
        extensions: _extensionsWithPropertyOrder(
          target,
          nextProperties: nextProperties,
          propertyOrder: target.resolvedPropertyOrder.map(
            (entry) => entry == trimmedCurrentKey ? trimmedNextKey : entry,
          ),
        ),
      ),
    );
  }

  void movePropertyUp({required JsonSchemaPath objectPath, required String key}) {
    _reorderProperty(objectPath: objectPath, key: key, offset: -1);
  }

  void movePropertyDown({required JsonSchemaPath objectPath, required String key}) {
    _reorderProperty(objectPath: objectPath, key: key, offset: 1);
  }

  void setRequired({
    required JsonSchemaPath objectPath,
    required String key,
    required bool required,
  }) {
    final target = _findNodeAtPath(schema, objectPath);
    if (target is! JsonSchemaObjectNode) {
      return;
    }
    if (!target.properties.containsKey(key)) {
      return;
    }
    final nextRequired = Set<String>.from(target.required);
    if (required) {
      nextRequired.add(key);
    } else {
      nextRequired.remove(key);
    }
    replaceNode(
      path: objectPath,
      node: target.copyWith(required: nextRequired),
    );
  }

  void setRequiredForPath({required JsonSchemaPath nodePath, required bool required}) {
    if (nodePath.isRoot) {
      return;
    }
    final parent = nodePath.parent;
    final lastSegment = nodePath.last;
    if (parent == nodePath) {
      return;
    }
    if (lastSegment is! JsonSchemaObjectPropertyPathSegment) {
      return;
    }
    final propertyKey = lastSegment.propertyKey;
    if (propertyKey == null || propertyKey.isEmpty) {
      return;
    }
    setRequired(objectPath: parent, key: propertyKey, required: required);
  }

  void setArrayItems({required JsonSchemaPath arrayPath, required JsonSchemaNode items}) {
    final target = _findNodeAtPath(schema, arrayPath);
    if (target is! JsonSchemaArrayNode) {
      return;
    }
    replaceNode(
      path: arrayPath,
      node: target.copyWith(items: items),
    );
  }

  void setNodeField({required JsonSchemaPath path, required String key, required Object? value}) {
    final trimmedKey = key.trim();
    if (trimmedKey.isEmpty) {
      return;
    }
    updateNode<JsonSchemaNode>(
      path: path,
      updater: (JsonSchemaNode node) {
        final nextExtensions = Map<String, dynamic>.from(node.extensions);
        nextExtensions[trimmedKey] = value;
        return node.copyWith(extensions: nextExtensions);
      },
    );
  }

  void removeNodeField({required JsonSchemaPath path, required String key}) {
    final trimmedKey = key.trim();
    if (trimmedKey.isEmpty) {
      return;
    }
    updateNode<JsonSchemaNode>(
      path: path,
      updater: (JsonSchemaNode node) {
        if (!node.extensions.containsKey(trimmedKey)) {
          return node;
        }
        final nextExtensions = Map<String, dynamic>.from(node.extensions)..remove(trimmedKey);
        return node.copyWith(extensions: nextExtensions);
      },
    );
  }

  void clearNodeFields({required JsonSchemaPath path}) {
    updateNode<JsonSchemaNode>(
      path: path,
      updater: (JsonSchemaNode node) => node.copyWith(clearExtensions: true),
    );
  }

  void reset() {
    setRoot(_initialSchema);
  }

  void clearRootObject() {
    setRoot(const JsonSchemaObjectNode());
  }

  void setJsonSchema(JsonSchema next) {
    setRoot(next.node);
  }

  void importJsonString(String source) {
    setJsonSchema(JsonSchema(_decodeJsonSchemaString(source)));
  }

  JsonSchema toJsonSchema() {
    return JsonSchema.fromNode(schema);
  }

  Map<String, dynamic> toData() {
    return toJsonSchema().map;
  }

  String toJsonString({bool pretty = true}) {
    return toJsonSchema().toJsonString(pretty: pretty);
  }

  void dispose() {
    schemaSubject.close();
    diagnosticsSubject.close();
  }

  void _apply(JsonSchemaNode next, {bool notify = true}) {
    final normalized = _normalizeNode(next);
    final diagnostics = validateSchema(normalized, customValidators: customValidators);
    schemaSubject.add(normalized);
    diagnosticsSubject.add(List<JsonSchemaDiagnostic>.unmodifiable(diagnostics));
    if (!notify) {
      return;
    }
    onSchemaChanged?.call(normalized, diagnostics);
  }

  JsonSchemaNode _normalizeNode(JsonSchemaNode node) {
    return _normalizeNodeWithOptions(node, featureOptions);
  }

  static JsonSchemaNode _normalizeNodeWithOptions(
    JsonSchemaNode node,
    JsonSchemaEditorFeatureOptions options,
  ) {
    final stringOptions = options.stringOptions;
    final numberOptions = options.numberOptions;
    final booleanOptions = options.booleanOptions;
    final arrayOptions = options.arrayOptions;

    return switch (node) {
      JsonSchemaObjectNode() => _normalizeObjectNodeWithOptions(node, options),
      JsonSchemaArrayNode() => JsonSchemaArrayNode(
        title: _trimOrNull(node.title),
        description: _trimOrNull(node.description),
        items: _normalizeNodeWithOptions(node.items, options),
        minItems: arrayOptions.minItems ? node.minItems : null,
        maxItems: arrayOptions.maxItems ? node.maxItems : null,
        uniqueItems: arrayOptions.uniqueItems ? node.uniqueItems : null,
        extensions: node.extensions,
      ),
      JsonSchemaStringNode() => JsonSchemaStringNode(
        title: _trimOrNull(node.title),
        description: _trimOrNull(node.description),
        minLength: stringOptions.minLength ? node.minLength : null,
        maxLength: stringOptions.maxLength ? node.maxLength : null,
        pattern: stringOptions.pattern ? _trimOrNull(node.pattern) : null,
        enumValues: stringOptions.enumValues ? node.enumValues : null,
        extensions: node.extensions,
      ),
      JsonSchemaNumberNode() => JsonSchemaNumberNode(
        numberType: node.numberType,
        title: _trimOrNull(node.title),
        description: _trimOrNull(node.description),
        minimum: numberOptions.minimum ? node.minimum : null,
        maximum: numberOptions.maximum ? node.maximum : null,
        exclusiveMinimum: numberOptions.exclusiveMinimum ? node.exclusiveMinimum : null,
        exclusiveMaximum: numberOptions.exclusiveMaximum ? node.exclusiveMaximum : null,
        multipleOf: numberOptions.multipleOf ? node.multipleOf : null,
        extensions: node.extensions,
      ),
      JsonSchemaBooleanNode() => JsonSchemaBooleanNode(
        title: _trimOrNull(node.title),
        description: _trimOrNull(node.description),
        extensions: node.extensions,
        defaultValue: booleanOptions.defaultValue ? node.defaultValue : null,
      ),
    };
  }

  static Map<String, JsonSchemaNode> _normalizePropertiesWithOptions(
    Map<String, JsonSchemaNode> properties,
    JsonSchemaEditorFeatureOptions options,
  ) {
    final normalized = <String, JsonSchemaNode>{};
    for (final entry in properties.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) {
        continue;
      }
      normalized[key] = _normalizeNodeWithOptions(entry.value, options);
    }
    return normalized;
  }

  static JsonSchemaObjectNode _normalizeObjectNodeWithOptions(
    JsonSchemaObjectNode node,
    JsonSchemaEditorFeatureOptions options,
  ) {
    final normalizedProperties = _normalizePropertiesWithOptions(node.properties, options);
    final normalizedNode = JsonSchemaObjectNode(
      title: _trimOrNull(node.title),
      description: _trimOrNull(node.description),
      properties: normalizedProperties,
      required: Set<String>.from(
        node.required,
      ).where((key) => normalizedProperties.containsKey(key)).toSet(),
      additionalProperties: options.objectOptions.additionalProperties
          ? node.additionalProperties
          : true,
      extensions: node.extensions,
    );

    return normalizedNode.copyWith(
      properties: normalizedNode.orderedProperties,
      extensions: normalizedNode.normalizedExtensions,
    );
  }

  JsonSchemaNode _replaceNodeAtPath(
    JsonSchemaNode root,
    JsonSchemaPath path,
    JsonSchemaNode nextNode,
  ) {
    final node = path.first;
    final next = path.rest;
    if (node == null) {
      return nextNode;
    }

    switch (root) {
      case JsonSchemaObjectNode():
        if (node is JsonSchemaObjectPropertyPathSegment) {
          if (!root.properties.containsKey(node.propertyKey)) {
            return root;
          }
          if (next == null) {
            return root.copyWith(
              properties: Map<String, JsonSchemaNode>.from(root.properties)
                ..[node.propertyKey!] = nextNode,
            );
          }
          final nested = _replaceNodeAtPath(root.properties[node.propertyKey!]!, next, nextNode);
          return root.copyWith(
            properties: Map<String, JsonSchemaNode>.from(root.properties)
              ..[node.propertyKey!] = nested,
          );
        }
        return root;
      case JsonSchemaArrayNode():
        if (node is JsonSchemaItemsPathSegment && next != null) {
          return root.copyWith(items: _replaceNodeAtPath(root.items, next, nextNode));
        }
        if (node is JsonSchemaItemsPathSegment) {
          return root.copyWith(items: nextNode);
        }
        return root;
      default:
        return root;
    }
  }

  JsonSchemaNode _findNodeAtPath(JsonSchemaNode root, JsonSchemaPath path) {
    var current = root;
    var currentPath = path;
    while (!currentPath.isRoot) {
      final segment = currentPath.first;
      final nextPath = currentPath.rest;
      if (segment == null) {
        return current;
      }
      if (segment is JsonSchemaObjectPropertyPathSegment && current is JsonSchemaObjectNode) {
        final nextNode = current.properties[segment.propertyKey];
        if (nextNode == null) {
          return current;
        }
        current = nextNode;
      } else if (segment is JsonSchemaItemsPathSegment && current is JsonSchemaArrayNode) {
        current = current.items;
      } else {
        return current;
      }
      if (nextPath == null) {
        return current;
      }
      currentPath = nextPath;
    }
    return current;
  }

  String _nextPropertyKey(List<String> existing) {
    var index = 1;
    while (true) {
      final candidate = 'property_$index';
      if (!existing.contains(candidate)) {
        return candidate;
      }
      index += 1;
    }
  }

  String _ensureUniquePropertyKey(List<String> existing, String key) {
    if (!existing.contains(key)) {
      return key;
    }
    var index = 1;
    while (true) {
      final candidate = '${key}_$index';
      if (!existing.contains(candidate)) {
        return candidate;
      }
      index += 1;
    }
  }

  void _reorderProperty({
    required JsonSchemaPath objectPath,
    required String key,
    required int offset,
  }) {
    final target = _findNodeAtPath(schema, objectPath);
    if (target is! JsonSchemaObjectNode) {
      return;
    }

    final propertyOrder = target.resolvedPropertyOrder.toList(growable: true);
    final currentIndex = propertyOrder.indexOf(key);
    if (currentIndex == -1) {
      return;
    }

    final nextIndex = currentIndex + offset;
    if (nextIndex < 0 || nextIndex >= propertyOrder.length) {
      return;
    }

    propertyOrder.removeAt(currentIndex);
    propertyOrder.insert(nextIndex, key);
    replaceNode(
      path: objectPath,
      node: target.copyWith(
        extensions: _extensionsWithPropertyOrder(
          target,
          nextProperties: target.properties,
          propertyOrder: propertyOrder,
        ),
      ),
    );
  }

  Map<String, dynamic> _extensionsWithPropertyOrder(
    JsonSchemaObjectNode node, {
    required Map<String, JsonSchemaNode> nextProperties,
    required Iterable<String> propertyOrder,
  }) {
    final normalizedNode = JsonSchemaObjectNode(
      title: node.title,
      description: node.description,
      properties: nextProperties,
      required: node.required,
      additionalProperties: node.additionalProperties,
      extensions: node.extensions,
    ).withPropertyOrder(propertyOrder);
    return normalizedNode.normalizedExtensions;
  }

  static String? _trimOrNull(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

Map<String, dynamic> _decodeJsonSchemaString(String source) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) {
    throw const FormatException('JSON schema input is empty.');
  }

  final decoded = jsonDecode(trimmed);
  if (decoded is! Map) {
    throw const FormatException('JSON schema must be a JSON object.');
  }

  return _normalizeDecodedJsonMap(decoded);
}

Map<String, dynamic> _normalizeDecodedJsonMap(Map<Object?, Object?> raw) {
  final normalized = <String, dynamic>{};
  for (final entry in raw.entries) {
    normalized[entry.key.toString()] = _normalizeDecodedJsonValue(entry.value);
  }
  return normalized;
}

Object? _normalizeDecodedJsonValue(Object? value) {
  if (value is Map) {
    return _normalizeDecodedJsonMap(value);
  }
  if (value is List) {
    return value.map(_normalizeDecodedJsonValue).toList(growable: false);
  }
  return value;
}
