// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$RequestPasswordResetBody implements JsonEncodable {
  const _$RequestPasswordResetBody({required this.email});

  static const schemaId = "RequestPasswordResetBody";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String email;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"email": email};

  static RequestPasswordResetBody fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return RequestPasswordResetBody(email: json["email"]! as String);
  }
}

final class _$RequestPasswordResetResponse implements JsonEncodable {
  const _$RequestPasswordResetResponse({required this.success});

  static const schemaId = "RequestPasswordResetResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final bool success;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"success": success};

  static RequestPasswordResetResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return RequestPasswordResetResponse(success: json["success"]! as bool);
  }
}
