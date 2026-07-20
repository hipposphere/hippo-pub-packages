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

@immutable
sealed class JsonSchemaPathSegment {
  const JsonSchemaPathSegment();

  String get displayLabel;

  String? get propertyKey => null;

  bool get isItems => false;
}

@immutable
final class JsonSchemaObjectPropertyPathSegment extends JsonSchemaPathSegment {
  const JsonSchemaObjectPropertyPathSegment(this.key);

  final String key;

  @override
  String get displayLabel => '.$key';

  @override
  String? get propertyKey => key;

  @override
  bool operator ==(Object other) {
    return other is JsonSchemaObjectPropertyPathSegment && other.key == key;
  }

  @override
  int get hashCode => Object.hash('property', key);
}

@immutable
final class JsonSchemaItemsPathSegment extends JsonSchemaPathSegment {
  const JsonSchemaItemsPathSegment();

  @override
  String get displayLabel => '[]';

  @override
  bool get isItems => true;

  @override
  bool operator ==(Object other) => other is JsonSchemaItemsPathSegment;

  @override
  int get hashCode => Object.hash('items', true);
}

@immutable
class JsonSchemaPath {
  const JsonSchemaPath._(this.segments);

  const factory JsonSchemaPath.root() = _EmptyJsonSchemaPath;

  final List<JsonSchemaPathSegment> segments;

  bool get isRoot => segments.isEmpty;

  JsonSchemaPath childProperty(String key) {
    return JsonSchemaPath._([...segments, JsonSchemaObjectPropertyPathSegment(key)]);
  }

  JsonSchemaPath childItems() {
    return JsonSchemaPath._([...segments, const JsonSchemaItemsPathSegment()]);
  }

  JsonSchemaPath pop() {
    if (segments.isEmpty) {
      return this;
    }
    return JsonSchemaPath._(segments.sublist(0, segments.length - 1));
  }

  JsonSchemaPathSegment? get first {
    return segments.isNotEmpty ? segments.first : null;
  }

  JsonSchemaPathSegment? get last {
    return segments.isNotEmpty ? segments.last : null;
  }

  JsonSchemaPath get parent => pop();

  JsonSchemaPath? get rest {
    if (segments.length <= 1) {
      return null;
    }
    return JsonSchemaPath._(segments.sublist(1));
  }

  bool isPrefixOf(JsonSchemaPath other) {
    if (segments.length > other.segments.length) {
      return false;
    }
    for (var index = 0; index < segments.length; index += 1) {
      if (segments[index] != other.segments[index]) {
        return false;
      }
    }
    return true;
  }

  /// Converts this schema path into a JSON Pointer-like path.
  ///
  /// Object properties map to their property keys. Array item schema segments
  /// are encoded as [arrayItemSegment], which defaults to `-` so schema paths
  /// like `$.users[]` become `/users/-`.
  JsonPointer toJsonPointer({String arrayItemSegment = '[]'}) {
    var pointer = JsonPointer.empty();

    for (final segment in segments) {
      if (segment case JsonSchemaObjectPropertyPathSegment(:final key)) {
        pointer = pointer.child(key);
      } else if (segment case JsonSchemaItemsPathSegment()) {
        pointer = pointer.child(arrayItemSegment);
      }
    }

    return pointer;
  }

  /// Converts this schema path to a JSON Pointer string.
  String toJsonPointerString({String arrayItemSegment = '-'}) {
    return toJsonPointer(arrayItemSegment: arrayItemSegment).toString();
  }

  @override
  String toString() {
    if (segments.isEmpty) {
      return '\$';
    }
    final buffer = StringBuffer('\$');
    for (final segment in segments) {
      buffer.write(segment.displayLabel);
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (other is! JsonSchemaPath) {
      return false;
    }
    if (segments.length != other.segments.length) {
      return false;
    }
    for (var index = 0; index < segments.length; index += 1) {
      if (segments[index] != other.segments[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(segments);
}

final class _EmptyJsonSchemaPath extends JsonSchemaPath {
  const _EmptyJsonSchemaPath() : super._(const []);
}
