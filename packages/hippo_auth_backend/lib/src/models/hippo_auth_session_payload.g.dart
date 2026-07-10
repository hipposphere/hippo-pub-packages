// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hippo_auth_session_payload.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$HippoAuthSessionPayload implements JsonEncodable {
  const _$HippoAuthSessionPayload({
    required this.sessionId,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  static const schemaId = "HippoAuthSessionPayload";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final String sessionId;

  final String token;

  final String expiresAt;

  final AuthUserRow user;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "session_id": sessionId,
    "token": token,
    "expires_at": expiresAt,
    "user": user.toJson(),
  };

  static HippoAuthSessionPayload fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return HippoAuthSessionPayload(
      sessionId: json["session_id"]! as String,
      token: json["token"]! as String,
      expiresAt: json["expires_at"]! as String,
      user: AuthUserRow.fromJson(
        Map<String, Object?>.from(json["user"]! as Map),
      ),
    );
  }
}
