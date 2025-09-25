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

V1UserConfirmMailPost$RequestBody _$V1UserConfirmMailPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1UserConfirmMailPost$RequestBody(token: json['token'] as String);

Map<String, dynamic> _$V1UserConfirmMailPost$RequestBodyToJson(
  V1UserConfirmMailPost$RequestBody instance,
) => <String, dynamic>{'token': instance.token};

V1UserRequestPasswordResetPost$RequestBody
_$V1UserRequestPasswordResetPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1UserRequestPasswordResetPost$RequestBody(email: json['email'] as String);

Map<String, dynamic> _$V1UserRequestPasswordResetPost$RequestBodyToJson(
  V1UserRequestPasswordResetPost$RequestBody instance,
) => <String, dynamic>{'email': instance.email};

V1UserResetPasswordPost$RequestBody
_$V1UserResetPasswordPost$RequestBodyFromJson(Map<String, dynamic> json) =>
    V1UserResetPasswordPost$RequestBody(
      token: json['token'] as String,
      newPassword: json['new_password'] as String,
    );

Map<String, dynamic> _$V1UserResetPasswordPost$RequestBodyToJson(
  V1UserResetPasswordPost$RequestBody instance,
) => <String, dynamic>{
  'token': instance.token,
  'new_password': instance.newPassword,
};

V1UserSignInEmailPost$RequestBody _$V1UserSignInEmailPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1UserSignInEmailPost$RequestBody(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$V1UserSignInEmailPost$RequestBodyToJson(
  V1UserSignInEmailPost$RequestBody instance,
) => <String, dynamic>{'email': instance.email, 'password': instance.password};

V1UserSignInSsoPost$RequestBody _$V1UserSignInSsoPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1UserSignInSsoPost$RequestBody(
  providerId: json['provider_id'] as String,
  successUrl: json['success_url'] as String,
);

Map<String, dynamic> _$V1UserSignInSsoPost$RequestBodyToJson(
  V1UserSignInSsoPost$RequestBody instance,
) => <String, dynamic>{
  'provider_id': instance.providerId,
  'success_url': instance.successUrl,
};

V1UserSignUpEmailPost$RequestBody _$V1UserSignUpEmailPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1UserSignUpEmailPost$RequestBody(
  name: json['name'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$V1UserSignUpEmailPost$RequestBodyToJson(
  V1UserSignUpEmailPost$RequestBody instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'password': instance.password,
};

V1UserGetUserGet$Response _$V1UserGetUserGet$ResponseFromJson(
  Map<String, dynamic> json,
) => V1UserGetUserGet$Response(
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V1UserGetUserGet$ResponseToJson(
  V1UserGetUserGet$Response instance,
) => <String, dynamic>{'user': instance.user.toJson()};

V1UserLogoutGet$Response _$V1UserLogoutGet$ResponseFromJson(
  Map<String, dynamic> json,
) => V1UserLogoutGet$Response(user: json['user']);

Map<String, dynamic> _$V1UserLogoutGet$ResponseToJson(
  V1UserLogoutGet$Response instance,
) => <String, dynamic>{'user': ?instance.user};

V1UserRefreshSessionPost$Response _$V1UserRefreshSessionPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1UserRefreshSessionPost$Response(
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$V1UserRefreshSessionPost$ResponseToJson(
  V1UserRefreshSessionPost$Response instance,
) => <String, dynamic>{'expires_at': ?instance.expiresAt?.toIso8601String()};

V1UserSignInEmailPost$Response _$V1UserSignInEmailPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1UserSignInEmailPost$Response(
  sessionId: json['session_id'] as String,
  token: json['token'] as String,
  expiresAt: DateTime.parse(json['expires_at'] as String),
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V1UserSignInEmailPost$ResponseToJson(
  V1UserSignInEmailPost$Response instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'token': instance.token,
  'expires_at': instance.expiresAt.toIso8601String(),
  'user': instance.user.toJson(),
};

V1UserSignInSsoPost$Response _$V1UserSignInSsoPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1UserSignInSsoPost$Response(
  success: json['success'] as bool,
  data: V1UserSignInSsoPost$Response$Data.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$V1UserSignInSsoPost$ResponseToJson(
  V1UserSignInSsoPost$Response instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data.toJson(),
};

V1UserSignUpEmailPost$Response _$V1UserSignUpEmailPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1UserSignUpEmailPost$Response(
  sessionId: json['session_id'] as String,
  token: json['token'] as String,
  expiresAt: DateTime.parse(json['expires_at'] as String),
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$V1UserSignUpEmailPost$ResponseToJson(
  V1UserSignUpEmailPost$Response instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'token': instance.token,
  'expires_at': instance.expiresAt.toIso8601String(),
  'user': instance.user.toJson(),
};

V1UserSignInSsoPost$Response$Data _$V1UserSignInSsoPost$Response$DataFromJson(
  Map<String, dynamic> json,
) => V1UserSignInSsoPost$Response$Data(
  redirectUrl: json['redirectUrl'] as String,
  providerId: json['providerId'] as String,
);

Map<String, dynamic> _$V1UserSignInSsoPost$Response$DataToJson(
  V1UserSignInSsoPost$Response$Data instance,
) => <String, dynamic>{
  'redirectUrl': instance.redirectUrl,
  'providerId': instance.providerId,
};
