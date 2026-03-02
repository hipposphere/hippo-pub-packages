/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:hippo_utils/hippo_utils.dart';
import 'models/feature_options.dart';

class JsonSchemaEditorController {
  factory JsonSchemaEditorController({
    JsonSchema? initialSchema,
    void Function(JsonSchemaNode schema, List<JsonSchemaDiagnostic> diagnostics)? onSchemaChanged,
    JsonSchemaEditorFeatureOptions featureOptions = JsonSchemaEditorFeatureOptions.allEnabled,
  }) {
    final start = _normalizeNodeWithOptions(
      initialSchema?.node ?? const JsonSchemaObjectNode(),
      featureOptions,
    );
    return JsonSchemaEditorController._(
      initialSchema: start,
      onSchemaChanged: onSchemaChanged,
      featureOptions: featureOptions,
    );
  }

  JsonSchemaEditorController._({
    required JsonSchemaNode initialSchema,
    this.onSchemaChanged,
    this.featureOptions = JsonSchemaEditorFeatureOptions.allEnabled,
  }) : schemaSubject = DataSubject.seeded(initialSchema),
       jsonSchemaSubject = DataSubject.seeded(
         JsonSchema.fromNode((initialSchema)),
       ) {
    final parsed = _normalizeNode(initialSchema);
    _initialSchema = parsed;
    _initialJsonSchema = JsonSchema.fromNode(parsed);
    _apply(parsed, notify: false);
  }

  final void Function(JsonSchemaNode schema, List<JsonSchemaDiagnostic> diagnostics)?
  onSchemaChanged;
  final JsonSchemaEditorFeatureOptions featureOptions;

  late JsonSchemaNode _initialSchema;
  late JsonSchema _initialJsonSchema;

  final DataSubject<JsonSchemaNode> schemaSubject;
  final DataSubject<JsonSchema> jsonSchemaSubject;
  final DataSubject<List<JsonSchemaDiagnostic>> diagnosticsSubject = DataSubject.seeded(const []);

  JsonSchemaNode get schema => schemaSubject.value;
  JsonSchema get jsonSchema => jsonSchemaSubject.value;

  JsonSchemaNode get initialSchema => _initialSchema;
  JsonSchema get initialJsonSchema => _initialJsonSchema;

  List<JsonSchemaDiagnostic> get diagnostics => diagnosticsSubject.value;

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

    final next = target.copyWith(properties: nextProperties);
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
      node: target.copyWith(properties: nextProperties, required: nextRequired),
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

    final nextProperties = Map<String, JsonSchemaNode>.from(target.properties);
    final node = nextProperties.remove(trimmedCurrentKey);
    if (node == null) {
      return;
    }
    nextProperties[trimmedNextKey] = node;
    final nextRequired = Set<String>.from(target.required)..remove(trimmedCurrentKey);
    if (target.required.contains(trimmedCurrentKey)) {
      nextRequired.add(trimmedNextKey);
    }
    replaceNode(
      path: objectPath,
      node: target.copyWith(properties: nextProperties, required: nextRequired),
    );
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

  void reset() {
    setRoot(_initialSchema);
  }

  void clearRootObject() {
    setRoot(const JsonSchemaObjectNode());
  }

  Map<String, dynamic> toData() {
    return jsonSchema.map;
  }

  String toJsonString({bool pretty = true}) {
    return jsonSchema.toJsonString(pretty: pretty);
  }

  void dispose() {
    schemaSubject.close();
    jsonSchemaSubject.close();
    diagnosticsSubject.close();
  }

  void _apply(JsonSchemaNode next, {bool notify = true}) {
    final normalized = _normalizeNode(next);
    final nextJsonSchema = JsonSchema.fromNode(normalized);
    final diagnostics = validateSchema(normalized);
    schemaSubject.add(normalized);
    jsonSchemaSubject.add(nextJsonSchema);
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
    return switch (node) {
      JsonSchemaObjectNode() => JsonSchemaObjectNode(
        title: _trimOrNull(node.title),
        description: _trimOrNull(node.description),
        properties: _normalizePropertiesWithOptions(node.properties, options),
        required: Set<String>.from(
          node.required,
        ).where((key) => node.properties.containsKey(key)).toSet(),
        additionalProperties: options.objectAdditionalProperties ? node.additionalProperties : true,
      ),
      JsonSchemaArrayNode() => JsonSchemaArrayNode(
        title: _trimOrNull(node.title),
        description: _trimOrNull(node.description),
        items: _normalizeNodeWithOptions(node.items, options),
        minItems: options.arrayMinItems ? node.minItems : null,
        maxItems: options.arrayMaxItems ? node.maxItems : null,
        uniqueItems: options.arrayUniqueItems ? node.uniqueItems : null,
      ),
      JsonSchemaStringNode() => JsonSchemaStringNode(
        title: _trimOrNull(node.title),
        description: _trimOrNull(node.description),
        minLength: options.stringMinLength ? node.minLength : null,
        maxLength: options.stringMaxLength ? node.maxLength : null,
        pattern: options.stringPattern ? _trimOrNull(node.pattern) : null,
        enumValues: options.stringEnum ? node.enumValues : null,
      ),
      JsonSchemaNumberNode() => JsonSchemaNumberNode(
        numberType: node.numberType,
        title: _trimOrNull(node.title),
        description: _trimOrNull(node.description),
        minimum: options.numberMinimum ? node.minimum : null,
        maximum: options.numberMaximum ? node.maximum : null,
        exclusiveMinimum: options.numberExclusiveMinimum ? node.exclusiveMinimum : null,
        exclusiveMaximum: options.numberExclusiveMaximum ? node.exclusiveMaximum : null,
        multipleOf: options.numberMultipleOf ? node.multipleOf : null,
      ),
      JsonSchemaBooleanNode() => JsonSchemaBooleanNode(
        title: _trimOrNull(node.title),
        description: _trimOrNull(node.description),
        defaultValue: node.defaultValue,
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
