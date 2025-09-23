//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RefreshSessionResponse {
  /// Returns a new [RefreshSessionResponse] instance.
  RefreshSessionResponse({
    required this.expiresAt,
  });

  DateTime expiresAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RefreshSessionResponse &&
    other.expiresAt == expiresAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (expiresAt.hashCode);

  @override
  String toString() => 'RefreshSessionResponse[expiresAt=$expiresAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'expires_at'] = this.expiresAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [RefreshSessionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RefreshSessionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RefreshSessionResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RefreshSessionResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RefreshSessionResponse(
        expiresAt: mapDateTime(json, r'expires_at', r'')!,
      );
    }
    return null;
  }

  static List<RefreshSessionResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RefreshSessionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RefreshSessionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RefreshSessionResponse> mapFromJson(dynamic json) {
    final map = <String, RefreshSessionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RefreshSessionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RefreshSessionResponse-objects as value to a dart map
  static Map<String, List<RefreshSessionResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RefreshSessionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RefreshSessionResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'expires_at',
  };
}

