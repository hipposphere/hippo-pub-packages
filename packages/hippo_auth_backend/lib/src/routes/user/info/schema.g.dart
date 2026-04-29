// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$GetUserInfoResponse implements JsonEncodable {
  const _$GetUserInfoResponse({
    required this.emailSignInEnabled,
    required this.emailSignUpEnabled,
    required this.ssoProviders,
  });

  static const schemaId = "GetUserInfoResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final bool emailSignInEnabled;

  final bool emailSignUpEnabled;

  final List<Map<String, Object?>> ssoProviders;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "email_sign_in_enabled": emailSignInEnabled,
    "email_sign_up_enabled": emailSignUpEnabled,
    "sso_providers": ssoProviders.map((item) => item).toList(),
  };

  static GetUserInfoResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return GetUserInfoResponse(
      emailSignInEnabled: json["email_sign_in_enabled"]! as bool,
      emailSignUpEnabled: json["email_sign_up_enabled"]! as bool,
      ssoProviders: (json["sso_providers"]! as List<Object?>)
          .map((item) => Map<String, Object?>.from(item! as Map))
          .toList(),
    );
  }
}
