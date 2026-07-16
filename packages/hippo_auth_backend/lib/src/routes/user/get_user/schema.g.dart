// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$GetUserResponse implements JsonEncodable {
  const _$GetUserResponse({required this.user});

  static const schemaId = "GetUserResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody => RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final AuthUserRow user;

  @override
  Map<String, Object?> toJson() => <String, Object?>{"user": user.toJson()};

  static GetUserResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return GetUserResponse(
      user: AuthUserRow.fromJson(Map<String, Object?>.from(json["user"]! as Map)),
    );
  }
}
