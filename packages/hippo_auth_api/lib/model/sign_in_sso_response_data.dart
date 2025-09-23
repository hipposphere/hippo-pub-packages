//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SignInSSOResponseData {
  /// Returns a new [SignInSSOResponseData] instance.
  SignInSSOResponseData({
    required this.redirectUrl,
    required this.providerId,
  });

  String redirectUrl;

  String providerId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SignInSSOResponseData &&
    other.redirectUrl == redirectUrl &&
    other.providerId == providerId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (redirectUrl.hashCode) +
    (providerId.hashCode);

  @override
  String toString() => 'SignInSSOResponseData[redirectUrl=$redirectUrl, providerId=$providerId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'redirectUrl'] = this.redirectUrl;
      json[r'providerId'] = this.providerId;
    return json;
  }

  /// Returns a new [SignInSSOResponseData] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SignInSSOResponseData? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SignInSSOResponseData[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SignInSSOResponseData[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SignInSSOResponseData(
        redirectUrl: mapValueOfType<String>(json, r'redirectUrl')!,
        providerId: mapValueOfType<String>(json, r'providerId')!,
      );
    }
    return null;
  }

  static List<SignInSSOResponseData> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SignInSSOResponseData>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SignInSSOResponseData.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SignInSSOResponseData> mapFromJson(dynamic json) {
    final map = <String, SignInSSOResponseData>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SignInSSOResponseData.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SignInSSOResponseData-objects as value to a dart map
  static Map<String, List<SignInSSOResponseData>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SignInSSOResponseData>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SignInSSOResponseData.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'redirectUrl',
    'providerId',
  };
}

