// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$RefreshSessionResponse implements JsonEncodable {
  const _$RefreshSessionResponse({required this.expiresAt});

  static const schemaId = "RefreshSessionResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String expiresAt;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"expires_at": expiresAt};

  static RefreshSessionResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return RefreshSessionResponse(expiresAt: json["expires_at"]! as String);
  }
}
