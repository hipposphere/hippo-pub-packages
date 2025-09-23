//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SignInSSOBody {
  /// Returns a new [SignInSSOBody] instance.
  SignInSSOBody({
    required this.providerId,
    required this.successUrl,
  });

  String providerId;

  String successUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SignInSSOBody &&
    other.providerId == providerId &&
    other.successUrl == successUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (providerId.hashCode) +
    (successUrl.hashCode);

  @override
  String toString() => 'SignInSSOBody[providerId=$providerId, successUrl=$successUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'provider_id'] = this.providerId;
      json[r'success_url'] = this.successUrl;
    return json;
  }

  /// Returns a new [SignInSSOBody] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SignInSSOBody? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SignInSSOBody[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SignInSSOBody[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SignInSSOBody(
        providerId: mapValueOfType<String>(json, r'provider_id')!,
        successUrl: mapValueOfType<String>(json, r'success_url')!,
      );
    }
    return null;
  }

  static List<SignInSSOBody> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SignInSSOBody>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SignInSSOBody.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SignInSSOBody> mapFromJson(dynamic json) {
    final map = <String, SignInSSOBody>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SignInSSOBody.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SignInSSOBody-objects as value to a dart map
  static Map<String, List<SignInSSOBody>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SignInSSOBody>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SignInSSOBody.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'provider_id',
    'success_url',
  };
}

