// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$SignInEmailBody implements JsonEncodable {
  const _$SignInEmailBody({required this.email, required this.password});

  static const schemaId = "SignInEmailBody";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String email;

  final String password;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "email": email,
    "password": password,
  };

  static SignInEmailBody fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return SignInEmailBody(
      email: json["email"]! as String,
      password: json["password"]! as String,
    );
  }
}
