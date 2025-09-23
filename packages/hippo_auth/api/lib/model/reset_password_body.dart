//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ResetPasswordBody {
  /// Returns a new [ResetPasswordBody] instance.
  ResetPasswordBody({
    required this.token,
    required this.newPassword,
  });

  String token;

  String newPassword;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ResetPasswordBody &&
    other.token == token &&
    other.newPassword == newPassword;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (token.hashCode) +
    (newPassword.hashCode);

  @override
  String toString() => 'ResetPasswordBody[token=$token, newPassword=$newPassword]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'token'] = this.token;
      json[r'new_password'] = this.newPassword;
    return json;
  }

  /// Returns a new [ResetPasswordBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ResetPasswordBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ResetPasswordBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ResetPasswordBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ResetPasswordBody(
        token: mapValueOfType<String>(json, r'token')!,
        newPassword: mapValueOfType<String>(json, r'new_password')!,
      );
    }
    return null;
  }

  static List<ResetPasswordBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ResetPasswordBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ResetPasswordBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ResetPasswordBody> mapFromJson(dynamic json) {
    final map = <String, ResetPasswordBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ResetPasswordBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ResetPasswordBody-objects as value to a dart map
  static Map<String, List<ResetPasswordBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ResetPasswordBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ResetPasswordBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'token',
    'new_password',
  };
}

