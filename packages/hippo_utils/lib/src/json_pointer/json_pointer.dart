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

/// A class representing a JSON Pointer following RFC 6901 semantics.
/// 
/// See: https://datatracker.ietf.org/doc/html/rfc6901
@immutable
class JsonPointer {
  const JsonPointer._(this.segments);

  /// Parses a string representation of a JSON Pointer.
  /// 
  /// Throws a [FormatException] if the pointer doesn't start with a "/" and is not empty.
  factory JsonPointer(String pointer) {
    if (pointer.isEmpty) {
      return const JsonPointer._([]);
    }
    if (!pointer.startsWith('/')) {
      throw FormatException('A JSON Pointer must start with a "/" or be empty.', pointer);
    }
    
    final rawSegments = pointer.substring(1).split('/');
    final parsedSegments = <String>[];
    
    for (final segment in rawSegments) {
      // RFC 6901 unescaping: ~1 becomes /, ~0 becomes ~
      parsedSegments.add(segment.replaceAll('~1', '/').replaceAll('~0', '~'));
    }
    
    return JsonPointer._(parsedSegments);
  }

  /// Creates an empty (root) JSON Pointer.
  factory JsonPointer.empty() => const JsonPointer._([]);

  final List<String> segments;

  /// Returns true if this is the root pointer (empty segments).
  bool get isRoot => segments.isEmpty;

  /// Appends a new segment to creating a new child [JsonPointer].
  JsonPointer child(String segment) {
    return JsonPointer._([...segments, segment]);
  }
  
  /// Returns the parent [JsonPointer] by removing the last segment.
  JsonPointer parent() {
    if (segments.isEmpty) return this;
    return JsonPointer._(segments.sublist(0, segments.length - 1));
  }

  @override
  String toString() {
    if (segments.isEmpty) {
      return '';
    }
    final buffer = StringBuffer();
    for (final segment in segments) {
      buffer.write('/');
      // RFC 6901 escaping: ~ becomes ~0, / becomes ~1
      buffer.write(segment.replaceAll('~', '~0').replaceAll('/', '~1'));
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (other is! JsonPointer) {
      return false;
    }
    if (segments.length != other.segments.length) {
      return false;
    }
    for (var i = 0; i < segments.length; i++) {
      if (segments[i] != other.segments[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(segments);
}
