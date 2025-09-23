//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class AuthUser {
  /// Returns a new [AuthUser] instance.
  AuthUser({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.name,
    this.image,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;

  String email;

  bool emailVerified;

  String name;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? image;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? role;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthUser &&
    other.id == id &&
    other.email == email &&
    other.emailVerified == emailVerified &&
    other.name == name &&
    other.image == image &&
    other.role == role &&
    other.createdAt == createdAt &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (email.hashCode) +
    (emailVerified.hashCode) +
    (name.hashCode) +
    (image == null ? 0 : image!.hashCode) +
    (role == null ? 0 : role!.hashCode) +
    (createdAt.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'AuthUser[id=$id, email=$email, emailVerified=$emailVerified, name=$name, image=$image, role=$role, createdAt=$createdAt, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'email'] = this.email;
      json[r'emailVerified'] = this.emailVerified;
      json[r'name'] = this.name;
    if (this.image != null) {
      json[r'image'] = this.image;
    } else {
      json[r'image'] = null;
    }
    if (this.role != null) {
      json[r'role'] = this.role;
    } else {
      json[r'role'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [AuthUser] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AuthUser? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AuthUser[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AuthUser[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AuthUser(
        id: mapValueOfType<String>(json, r'id')!,
        email: mapValueOfType<String>(json, r'email')!,
        emailVerified: mapValueOfType<bool>(json, r'emailVerified')!,
        name: mapValueOfType<String>(json, r'name')!,
        image: mapValueOfType<String>(json, r'image'),
        role: mapValueOfType<String>(json, r'role'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<AuthUser> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuthUser>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuthUser.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AuthUser> mapFromJson(dynamic json) {
    final map = <String, AuthUser>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AuthUser.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AuthUser-objects as value to a dart map
  static Map<String, List<AuthUser>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AuthUser>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AuthUser.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'email',
    'emailVerified',
    'name',
    'createdAt',
    'updatedAt',
  };
}

