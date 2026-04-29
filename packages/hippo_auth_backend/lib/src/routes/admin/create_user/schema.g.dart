// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$AdminCreateUserBody implements JsonEncodable {
  const _$AdminCreateUserBody({
    required this.email,
    required this.password,
    required this.name,
    this.role,
    this.data,
  });

  static const schemaId = "AdminCreateUserBody";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String email;

  final String password;

  final String name;

  final Object? role;

  final Map<String, Object?>? data;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "email": email,
    "password": password,
    "name": name,
    "role": role,
    "data": data,
  };

  static AdminCreateUserBody fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminCreateUserBody(
      email: json["email"]! as String,
      password: json["password"]! as String,
      name: json["name"]! as String,
      role: json["role"],
      data: json["data"] == null
          ? null
          : Map<String, Object?>.from(json["data"] as Map),
    );
  }
}

final class _$AdminCreateUserResponse implements JsonEncodable {
  const _$AdminCreateUserResponse({required this.user});

  static const schemaId = "AdminCreateUserResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final DartEdgeAuthUser user;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"user": user.toJson()};

  static AdminCreateUserResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminCreateUserResponse(
      user: DartEdgeAuthUser.fromJson(
        Map<String, Object?>.from(json["user"]! as Map),
      ),
    );
  }
}
