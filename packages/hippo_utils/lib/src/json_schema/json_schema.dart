import 'dart:convert';

import 'json_schema_nodes.dart';

class JsonSchema {
  factory JsonSchema.empty() {
    return JsonSchema({});
  }

  factory JsonSchema.fromNode(JsonSchemaNode node) {
    return JsonSchema(node.toJson());
  }

  JsonSchema(Map<String, dynamic> map) : _map = _cloneMap(map);

  final Map<String, dynamic> _map;

  Map<String, dynamic> get map => Map.unmodifiable(_map);
  JsonSchemaNode get node => JsonSchemaNode.fromJson(_map);

  String toJsonString({bool pretty = false}) {
    final encoded = jsonEncode(_map);
    if (!pretty) {
      return encoded;
    }
    return const JsonEncoder.withIndent('  ').convert(_map);
  }

  JsonSchema copyWith({Map<String, dynamic>? map}) {
    return JsonSchema(map ?? _map);
  }
}

Map<String, dynamic> _cloneMap(Map<String, dynamic> raw) {
  return Map<String, dynamic>.unmodifiable(
    raw.map(
      (key, value) {
        if (value is Map<String, dynamic>) {
          return MapEntry(key, _cloneMap(value));
        }
        if (value is Map) {
          return MapEntry(
            key,
            _cloneMap(
              value.map((entryKey, entryValue) => MapEntry(entryKey.toString(), entryValue)),
            ),
          );
        }
        if (value is List) {
          return MapEntry(key, _cloneList(value));
        }
        return MapEntry(key, value);
      },
    ),
  );
}

List<Object?> _cloneList(List list) {
  return List<Object?>.unmodifiable(
    list.map(
      (entry) {
        if (entry is Map<String, dynamic>) {
          return _cloneMap(entry);
        }
        if (entry is Map) {
          return _cloneMap(entry.map((entryKey, entryValue) => MapEntry(entryKey.toString(), entryValue)));
        }
        if (entry is List) {
          return _cloneList(entry);
        }
        return entry;
      },
    ).toList(),
  );
}
