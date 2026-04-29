// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$AdminListOAuthClientsResponse implements JsonEncodable {
  const _$AdminListOAuthClientsResponse({required this.oauthClients});

  static const schemaId = "AdminListOAuthClientsResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final List<Map<String, Object?>> oauthClients;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "oauth_clients": oauthClients.map((item) => item).toList(),
  };

  static AdminListOAuthClientsResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminListOAuthClientsResponse(
      oauthClients: (json["oauth_clients"]! as List<Object?>)
          .map((item) => Map<String, Object?>.from(item! as Map))
          .toList(),
    );
  }
}
