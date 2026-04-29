// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$ResetPasswordBody implements JsonEncodable {
  const _$ResetPasswordBody({required this.token, required this.newPassword});

  static const schemaId = "ResetPasswordBody";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String token;

  final String newPassword;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "token": token,
    "new_password": newPassword,
  };

  static ResetPasswordBody fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return ResetPasswordBody(
      token: json["token"]! as String,
      newPassword: json["new_password"]! as String,
    );
  }
}

final class _$ResetPasswordResponse implements JsonEncodable {
  const _$ResetPasswordResponse({required this.success});

  static const schemaId = "ResetPasswordResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final bool success;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"success": success};

  static ResetPasswordResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return ResetPasswordResponse(success: json["success"]! as bool);
  }
}
