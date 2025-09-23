//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetUserResponse {
  /// Returns a new [GetUserResponse] instance.
  GetUserResponse({
    required this.user,
  });

  AuthUser user;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetUserResponse &&
    other.user == user;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (user.hashCode);

  @override
  String toString() => 'GetUserResponse[user=$user]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'user'] = this.user;
    return json;
  }

  /// Returns a new [GetUserResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetUserResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetUserResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetUserResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetUserResponse(
        user: AuthUser.fromJson(json[r'user'])!,
      );
    }
    return null;
  }

  static List<GetUserResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetUserResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetUserResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetUserResponse> mapFromJson(dynamic json) {
    final map = <String, GetUserResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetUserResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetUserResponse-objects as value to a dart map
  static Map<String, List<GetUserResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetUserResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetUserResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'user',
  };
}

