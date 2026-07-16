// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$SignUpEmailBody implements JsonEncodable {
  const _$SignUpEmailBody({required this.email, required this.password, required this.name});

  static const schemaId = "SignUpEmailBody";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String email;

  final String password;

  final String name;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "email": email,
    "password": password,
    "name": name,
  };

  static SignUpEmailBody fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return SignUpEmailBody(
      email: json["email"]! as String,
      password: json["password"]! as String,
      name: json["name"]! as String,
    );
  }
}
