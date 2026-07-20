/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/

import 'package:json_schema/json_schema.dart';

/// A generic map that uses [JsonPointer] as keys.
///
/// It supports exact matching, as well as simple wildcard matching
/// where a segment value of '-' in the map's key can match any value at that
/// position in the requested pointer. This is useful for matching array items.
class JsonPointerMap<T> {
  JsonPointerMap({Map<JsonPointer, T>? map}) : _map = map ?? {};

  /// Creates a [JsonPointerMap] seeded with the given string paths and values.
  factory JsonPointerMap.seeded(Map<String, T> seed) {
    final map = <JsonPointer, T>{};
    for (final entry in seed.entries) {
      map[JsonPointer(entry.key)] = entry.value;
    }
    return JsonPointerMap(map: map);
  }

  final Map<JsonPointer, T> _map;

  /// Associates the [value] with the exact [pointer].
  void set(JsonPointer pointer, T value) {
    _map[pointer] = value;
  }

  /// Associates the [value] with the exact pointer string [pointerStr].
  void setString(String pointerStr, T value) {
    _map[JsonPointer(pointerStr)] = value;
  }

  /// Retrieves the value associated with the exact [pointer], if any.
  T? get(JsonPointer pointer) {
    return _map[pointer];
  }

  /// Retrieves the value associated with the exact pointer string [pointerStr].
  T? getString(String pointerStr) {
    return _map[JsonPointer(pointerStr)];
  }

  /// Finds a value matching the [pointer].
  ///
  /// This checks for exact matches first. If no exact match is found,
  /// it iterates through the keys to find a wildcard match where the map's
  /// key has a '-' segment that matches any segment in the [pointer].
  T? match(JsonPointer pointer) {
    // Fast path: exact match
    if (_map.containsKey(pointer)) {
      return _map[pointer];
    }

    // Slow path: wildcard matching
    for (final entry in _map.entries) {
      if (_matches(entry.key, pointer)) {
        return entry.value;
      }
    }

    return null;
  }

  bool _matches(JsonPointer pattern, JsonPointer actual) {
    if (pattern.segments.length != actual.segments.length) return false;
    for (var i = 0; i < pattern.segments.length; i++) {
      final pSeg = pattern.segments[i];
      final aSeg = actual.segments[i];

      // Exact match or wildcard match '-'
      if (pSeg != aSeg && pSeg != '-') {
        return false;
      }
    }
    return true;
  }

  /// Removes the association for the given [pointer].
  void remove(JsonPointer pointer) {
    _map.remove(pointer);
  }

  bool get isEmpty => _map.isEmpty;
  bool get isNotEmpty => _map.isNotEmpty;

  Iterable<JsonPointer> get keys => _map.keys;
  Iterable<T> get values => _map.values;

  void clear() => _map.clear();
}
