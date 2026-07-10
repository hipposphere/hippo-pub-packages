// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$AdminUpdateUserBody implements JsonEncodable {
  const _$AdminUpdateUserBody({required this.userId, this.role, this.data});

  static const schemaId = "AdminUpdateUserBody";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String userId;

  final Object? role;

  final Map<String, Object?>? data;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "user_id": userId,
    "role": role,
    "data": data,
  };

  static AdminUpdateUserBody fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminUpdateUserBody(
      userId: json["user_id"]! as String,
      role: json["role"],
      data: json["data"] == null
          ? null
          : Map<String, Object?>.from(json["data"] as Map),
    );
  }
}

final class _$AdminUpdateUserResponse implements JsonEncodable {
  const _$AdminUpdateUserResponse({required this.user});

  static const schemaId = "AdminUpdateUserResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final AuthUserRow user;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"user": user.toJson()};

  static AdminUpdateUserResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminUpdateUserResponse(
      user: AuthUserRow.fromJson(
        Map<String, Object?>.from(json["user"]! as Map),
      ),
    );
  }
}
