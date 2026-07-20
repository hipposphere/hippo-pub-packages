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
import 'package:json_schema/json_schema.dart';

import '../json_schema/json_schema_nodes.dart';
import '../json_pointer/json_pointer_map.dart';

/// The type of an [AnnotatedJsonNode].
enum AnnotatedJsonNodeType { object, list, value }

/// Represents a node in the parsed JSON tree, linked with an optional [schemaNode]
/// and any [metadata] matched via a JsonPointerMap.
@immutable
class AnnotatedJsonNode<T> {
  const AnnotatedJsonNode({
    required this.type,
    required this.value,
    this.schemaNode,
    required this.pointer,
    this.metadata,
    this.children,
    this.properties,
  });

  /// The type of the mapped JSON node.
  final AnnotatedJsonNodeType type;

  /// The actual JSON value parsed at this node (e.g. Map, List, String, bool, int, double).
  final dynamic value;

  /// The [JsonSchemaNode] that describes this value's schema (if provided).
  final JsonSchemaNode? schemaNode;

  /// The [JsonPointer] path pointing to this location in the JSON document.
  final JsonPointer pointer;

  /// Associated metadata mapped from a [JsonPointerMap<T>].
  final T? metadata;

  /// Parsed child nodes if this was an array.
  final List<AnnotatedJsonNode<T>>? children;

  /// Parsed property nodes if this was an object.
  final Map<String, AnnotatedJsonNode<T>>? properties;
}

/// An annotator that combines a raw JSON object with an optional [JsonSchema],
/// and an optional [JsonPointerMap<T>] containing metadata mapped by JSON Pointers.
class JsonAnnotator {
  const JsonAnnotator();

  /// Parses the [rawJson]. If a [schema] is provided, it validates the structure against it.
  /// If a [map] is provided, metadata will be bound to the respective output [AnnotatedJsonNode]
  /// by evaluating their JSON Pointer paths.
  AnnotatedJsonNode<T> parse<T>(dynamic rawJson, {JsonSchema? schema, JsonPointerMap<T>? map}) {
    return _parseNode<T>(
      value: rawJson,
      schemaNode: schema?.node,
      pointer: JsonPointer.empty(),
      map: map,
    );
  }

  AnnotatedJsonNode<T> _parseNode<T>({
    required dynamic value,
    JsonSchemaNode? schemaNode,
    required JsonPointer pointer,
    JsonPointerMap<T>? map,
  }) {
    // Attempt to match metadata via the JSON Pointer (allows for wildcards or exact paths).
    final metadata = map?.match(pointer);

    if (value is Map) {
      final properties = <String, AnnotatedJsonNode<T>>{};
      final rawProperties = <String, Object?>{};
      for (final entry in value.entries) {
        rawProperties[entry.key.toString()] = entry.value;
      }

      final orderedKeys = schemaNode is JsonSchemaObjectNode
          ? [
              ...schemaNode.resolvedPropertyOrder.where(rawProperties.containsKey),
              ...rawProperties.keys.where((key) => !schemaNode.resolvedPropertyOrder.contains(key)),
            ]
          : rawProperties.keys.toList(growable: false);

      for (final key in orderedKeys) {
        // Find the child schema for this property, or leave null.
        JsonSchemaNode? childSchema;
        if (schemaNode is JsonSchemaObjectNode) {
          childSchema = schemaNode.properties[key] ?? JsonSchemaNode.emptyRoot();
        }

        properties[key] = _parseNode<T>(
          value: rawProperties[key],
          schemaNode: childSchema,
          pointer: pointer.child(key),
          map: map,
        );
      }

      return AnnotatedJsonNode<T>(
        type: AnnotatedJsonNodeType.object,
        value: value,
        schemaNode: schemaNode,
        pointer: pointer,
        metadata: metadata,
        properties: properties,
      );
    } else if (value is List) {
      final children = <AnnotatedJsonNode<T>>[];

      for (var i = 0; i < value.length; i++) {
        JsonSchemaNode? childSchema;
        if (schemaNode is JsonSchemaArrayNode) {
          childSchema = schemaNode.items;
        }

        children.add(
          _parseNode<T>(
            value: value[i],
            schemaNode: childSchema,
            pointer: pointer.child(i.toString()),
            map: map,
          ),
        );
      }

      return AnnotatedJsonNode<T>(
        type: AnnotatedJsonNodeType.list,
        value: value,
        schemaNode: schemaNode,
        pointer: pointer,
        metadata: metadata,
        children: children,
      );
    } else {
      // Primitive schema node (e.g. string, number, boolean, null)
      return AnnotatedJsonNode<T>(
        type: AnnotatedJsonNodeType.value,
        value: value,
        schemaNode: schemaNode,
        pointer: pointer,
        metadata: metadata,
      );
    }
  }
}
