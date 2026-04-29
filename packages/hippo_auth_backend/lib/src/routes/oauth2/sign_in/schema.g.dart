// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$OAuth2SignInParams implements JsonEncodable {
  const _$OAuth2SignInParams({required this.providerId});

  static const schemaId = "OAuth2SignInParams";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String providerId;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"providerId": providerId};

  static OAuth2SignInParams fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return OAuth2SignInParams(providerId: json["providerId"]! as String);
  }
}
