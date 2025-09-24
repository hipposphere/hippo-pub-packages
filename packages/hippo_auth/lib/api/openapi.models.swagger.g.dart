// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openapi.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => AuthUser(
  id: json['id'] as String,
  email: json['email'] as String,
  emailVerified: json['emailVerified'] as bool,
  name: json['name'] as String,
  image: json['image'] as String?,
  role: json['role'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'emailVerified': instance.emailVerified,
  'name': instance.name,
  'image': ?instance.image,
  'role': ?instance.role,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

Def0 _$Def0FromJson(Map<String, dynamic> json) =>
    Def0(error: json['error'] as String, message: json['message'] as String);

Map<String, dynamic> _$Def0ToJson(Def0 instance) => <String, dynamic>{
  'error': instance.error,
  'message': instance.message,
};

V1ConfirmMailPost$RequestBody _$V1ConfirmMailPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1ConfirmMailPost$RequestBody(token: json['token'] as String);

Map<String, dynamic> _$V1ConfirmMailPost$RequestBodyToJson(
  V1ConfirmMailPost$RequestBody instance,
) => <String, dynamic>{'token': instance.token};

V1RequestPasswordResetPost$RequestBody
_$V1RequestPasswordResetPost$RequestBodyFromJson(Map<String, dynamic> json) =>
    V1RequestPasswordResetPost$RequestBody(email: json['email'] as String);

Map<String, dynamic> _$V1RequestPasswordResetPost$RequestBodyToJson(
  V1RequestPasswordResetPost$RequestBody instance,
) => <String, dynamic>{'email': instance.email};

V1ResetPasswordPost$RequestBody _$V1ResetPasswordPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1ResetPasswordPost$RequestBody(
  token: json['token'] as String,
  newPassword: json['new_password'] as String,
);

Map<String, dynamic> _$V1ResetPasswordPost$RequestBodyToJson(
  V1ResetPasswordPost$RequestBody instance,
) => <String, dynamic>{
  'token': instance.token,
  'new_password': instance.newPassword,
};

V1SignInEmailPost$RequestBody _$V1SignInEmailPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1SignInEmailPost$RequestBody(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$V1SignInEmailPost$RequestBodyToJson(
  V1SignInEmailPost$RequestBody instance,
) => <String, dynamic>{'email': instance.email, 'password': instance.password};

V1SignInSsoPost$RequestBody _$V1SignInSsoPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1SignInSsoPost$RequestBody(
  providerId: json['provider_id'] as String,
  successUrl: json['success_url'] as String,
);

Map<String, dynamic> _$V1SignInSsoPost$RequestBodyToJson(
  V1SignInSsoPost$RequestBody instance,
) => <String, dynamic>{
  'provider_id': instance.providerId,
  'success_url': instance.successUrl,
};

V1SignUpEmailPost$RequestBody _$V1SignUpEmailPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1SignUpEmailPost$RequestBody(
  name: json['name'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$V1SignUpEmailPost$RequestBodyToJson(
  V1SignUpEmailPost$RequestBody instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'password': instance.password,
};

V1GetUserGet$Response _$V1GetUserGet$ResponseFromJson(
  Map<String, dynamic> json,
) => V1GetUserGet$Response(
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V1GetUserGet$ResponseToJson(
  V1GetUserGet$Response instance,
) => <String, dynamic>{'user': instance.user.toJson()};

V1RefreshSessionPost$Response _$V1RefreshSessionPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1RefreshSessionPost$Response(
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$V1RefreshSessionPost$ResponseToJson(
  V1RefreshSessionPost$Response instance,
) => <String, dynamic>{'expires_at': ?instance.expiresAt?.toIso8601String()};

V1SignInEmailPost$Response _$V1SignInEmailPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1SignInEmailPost$Response(
  sessionId: json['session_id'] as String,
  token: json['token'] as String,
  expiresAt: DateTime.parse(json['expires_at'] as String),
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V1SignInEmailPost$ResponseToJson(
  V1SignInEmailPost$Response instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'token': instance.token,
  'expires_at': instance.expiresAt.toIso8601String(),
  'user': instance.user.toJson(),
};

V1SignInSsoPost$Response _$V1SignInSsoPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1SignInSsoPost$Response(
  success: json['success'] as bool,
  data: V1SignInSsoPost$Response$Data.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$V1SignInSsoPost$ResponseToJson(
  V1SignInSsoPost$Response instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data.toJson(),
};

V1SignUpEmailPost$Response _$V1SignUpEmailPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1SignUpEmailPost$Response(
  sessionId: json['session_id'] as String,
  token: json['token'] as String,
  expiresAt: DateTime.parse(json['expires_at'] as String),
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V1SignUpEmailPost$ResponseToJson(
  V1SignUpEmailPost$Response instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'token': instance.token,
  'expires_at': instance.expiresAt.toIso8601String(),
  'user': instance.user.toJson(),
};

V1SignInSsoPost$Response$Data _$V1SignInSsoPost$Response$DataFromJson(
  Map<String, dynamic> json,
) => V1SignInSsoPost$Response$Data(
  redirectUrl: json['redirectUrl'] as String,
  providerId: json['providerId'] as String,
);

Map<String, dynamic> _$V1SignInSsoPost$Response$DataToJson(
  V1SignInSsoPost$Response$Data instance,
) => <String, dynamic>{
  'redirectUrl': instance.redirectUrl,
  'providerId': instance.providerId,
};
