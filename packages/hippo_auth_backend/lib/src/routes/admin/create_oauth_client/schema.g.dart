// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$AdminCreateOAuthClientResponse implements JsonEncodable {
  const _$AdminCreateOAuthClientResponse({required this.oauthClient});

  static const schemaId = "AdminCreateOAuthClientResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final Map<String, Object?> oauthClient;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"oauth_client": oauthClient};

  static AdminCreateOAuthClientResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminCreateOAuthClientResponse(
      oauthClient: Map<String, Object?>.from(json["oauth_client"]! as Map),
    );
  }
}
