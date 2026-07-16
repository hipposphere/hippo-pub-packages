// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$AdminDeleteUserBody implements JsonEncodable {
  const _$AdminDeleteUserBody({required this.userId});

  static const schemaId = "AdminDeleteUserBody";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String userId;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"user_id": userId};

  static AdminDeleteUserBody fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminDeleteUserBody(userId: json["user_id"]! as String);
  }
}

final class _$AdminDeleteUserResponse implements JsonEncodable {
  const _$AdminDeleteUserResponse({required this.success, required this.userId});

  static const schemaId = "AdminDeleteUserResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final bool success;

  final String userId;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"success": success, "user_id": userId};

  static AdminDeleteUserResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminDeleteUserResponse(
      success: json["success"]! as bool,
      userId: json["user_id"]! as String,
    );
  }
}
