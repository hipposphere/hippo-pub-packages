// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$AdminDeleteOAuthClientBody implements JsonEncodable {
  const _$AdminDeleteOAuthClientBody({required this.clientId});

  static const schemaId = "AdminDeleteOAuthClientBody";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String clientId;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"client_id": clientId};

  static AdminDeleteOAuthClientBody fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminDeleteOAuthClientBody(clientId: json["client_id"]! as String);
  }
}

final class _$AdminDeleteOAuthClientResponse implements JsonEncodable {
  const _$AdminDeleteOAuthClientResponse({required this.success, required this.clientId});

  static const schemaId = "AdminDeleteOAuthClientResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final bool success;

  final String clientId;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"success": success, "client_id": clientId};

  static AdminDeleteOAuthClientResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminDeleteOAuthClientResponse(
      success: json["success"]! as bool,
      clientId: json["client_id"]! as String,
    );
  }
}
