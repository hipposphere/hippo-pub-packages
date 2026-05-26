// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$SignInSsoBody implements JsonEncodable {
  const _$SignInSsoBody({required this.providerId, required this.successUrl});

  static const schemaId = "SignInSsoBody";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String providerId;

  final String successUrl;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "provider_id": providerId,
    "success_url": successUrl,
  };

  static SignInSsoBody fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return SignInSsoBody(
      providerId: json["provider_id"]! as String,
      successUrl: json["success_url"]! as String,
    );
  }
}

final class _$SignInSsoResponse implements JsonEncodable {
  const _$SignInSsoResponse({required this.success, required this.data});

  static const schemaId = "SignInSsoResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final bool success;

  final Map<String, Object?> data;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"success": success, "data": data};

  static SignInSsoResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return SignInSsoResponse(
      success: json["success"]! as bool,
      data: json["data"]! as Map<String, Object?>,
    );
  }
}
