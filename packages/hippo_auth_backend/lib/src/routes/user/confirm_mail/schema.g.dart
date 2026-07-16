// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$ConfirmMailBody implements JsonEncodable {
  const _$ConfirmMailBody({required this.token});

  static const schemaId = "ConfirmMailBody";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String token;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"token": token};

  static ConfirmMailBody fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return ConfirmMailBody(token: json["token"]! as String);
  }
}

final class _$ConfirmMailResponse implements JsonEncodable {
  const _$ConfirmMailResponse({required this.success});

  static const schemaId = "ConfirmMailResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final bool success;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"success": success};

  static ConfirmMailResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return ConfirmMailResponse(success: json["success"]! as bool);
  }
}
