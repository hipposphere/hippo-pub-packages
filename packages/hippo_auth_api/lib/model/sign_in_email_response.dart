//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class SignInEmailResponse {
  /// Returns a new [SignInEmailResponse] instance.
  SignInEmailResponse({
    required this.sessionId,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  String sessionId;

  String token;

  DateTime expiresAt;

  AuthUser user;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SignInEmailResponse &&
    other.sessionId == sessionId &&
    other.token == token &&
    other.expiresAt == expiresAt &&
    other.user == user;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (sessionId.hashCode) +
    (token.hashCode) +
    (expiresAt.hashCode) +
    (user.hashCode);

  @override
  String toString() => 'SignInEmailResponse[sessionId=$sessionId, token=$token, expiresAt=$expiresAt, user=$user]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'session_id'] = this.sessionId;
      json[r'token'] = this.token;
      json[r'expires_at'] = this.expiresAt.toUtc().toIso8601String();
      json[r'user'] = this.user;
    return json;
  }

  /// Returns a new [SignInEmailResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SignInEmailResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SignInEmailResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SignInEmailResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SignInEmailResponse(
        sessionId: mapValueOfType<String>(json, r'session_id')!,
        token: mapValueOfType<String>(json, r'token')!,
        expiresAt: mapDateTime(json, r'expires_at', r'')!,
        user: AuthUser.fromJson(json[r'user'])!,
      );
    }
    return null;
  }

  static List<SignInEmailResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SignInEmailResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SignInEmailResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SignInEmailResponse> mapFromJson(dynamic json) {
    final map = <String, SignInEmailResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SignInEmailResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SignInEmailResponse-objects as value to a dart map
  static Map<String, List<SignInEmailResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SignInEmailResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SignInEmailResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'session_id',
    'token',
    'expires_at',
    'user',
  };
}

