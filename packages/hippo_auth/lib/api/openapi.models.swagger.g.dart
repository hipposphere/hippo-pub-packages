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

HippoAuthErrorResponse _$HippoAuthErrorResponseFromJson(
  Map<String, dynamic> json,
) => HippoAuthErrorResponse(
  error: HippoAuthErrorResponse$Error.fromJson(
    json['error'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$HippoAuthErrorResponseToJson(
  HippoAuthErrorResponse instance,
) => <String, dynamic>{'error': instance.error.toJson()};

V1AdminCreateUserPost$RequestBody _$V1AdminCreateUserPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1AdminCreateUserPost$RequestBody(
  email: json['email'] as String,
  name: json['name'] as String,
  password: json['password'] as String?,
  role: json['role'],
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$V1AdminCreateUserPost$RequestBodyToJson(
  V1AdminCreateUserPost$RequestBody instance,
) => <String, dynamic>{
  'email': instance.email,
  'name': instance.name,
  'password': ?instance.password,
  'role': ?instance.role,
  'data': ?instance.data,
};

V1AdminCreateOauthClientPost$RequestBody
_$V1AdminCreateOauthClientPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1AdminCreateOauthClientPost$RequestBody(
  redirectUris:
      (json['redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  scope: json['scope'] as String?,
  clientName: json['client_name'] as String?,
  clientUri: json['client_uri'] as String?,
  logoUri: json['logo_uri'] as String?,
  contacts:
      (json['contacts'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  tosUri: json['tos_uri'] as String?,
  policyUri: json['policy_uri'] as String?,
  softwareId: json['software_id'] as String?,
  softwareVersion: json['software_version'] as String?,
  softwareStatement: json['software_statement'] as String?,
  postLogoutRedirectUris:
      (json['post_logout_redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  tokenEndpointAuthMethod:
      v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodNullableFromJson(
        json['token_endpoint_auth_method'],
      ),
  grantTypes: v1AdminCreateOauthClientPost$RequestBodyGrantTypesListFromJson(
    json['grant_types'] as List?,
  ),
  responseTypes:
      v1AdminCreateOauthClientPost$RequestBodyResponseTypesListFromJson(
        json['response_types'] as List?,
      ),
  type: v1AdminCreateOauthClientPost$RequestBodyTypeNullableFromJson(
    json['type'],
  ),
  clientSecretExpiresAt: json['client_secret_expires_at'],
  skipConsent: json['skip_consent'] as bool?,
  enableEndSession: json['enable_end_session'] as bool?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$V1AdminCreateOauthClientPost$RequestBodyToJson(
  V1AdminCreateOauthClientPost$RequestBody instance,
) => <String, dynamic>{
  'redirect_uris': instance.redirectUris,
  'scope': ?instance.scope,
  'client_name': ?instance.clientName,
  'client_uri': ?instance.clientUri,
  'logo_uri': ?instance.logoUri,
  'contacts': ?instance.contacts,
  'tos_uri': ?instance.tosUri,
  'policy_uri': ?instance.policyUri,
  'software_id': ?instance.softwareId,
  'software_version': ?instance.softwareVersion,
  'software_statement': ?instance.softwareStatement,
  'post_logout_redirect_uris': ?instance.postLogoutRedirectUris,
  'token_endpoint_auth_method':
      ?v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodNullableToJson(
        instance.tokenEndpointAuthMethod,
      ),
  'grant_types': v1AdminCreateOauthClientPost$RequestBodyGrantTypesListToJson(
    instance.grantTypes,
  ),
  'response_types':
      v1AdminCreateOauthClientPost$RequestBodyResponseTypesListToJson(
        instance.responseTypes,
      ),
  'type': ?v1AdminCreateOauthClientPost$RequestBodyTypeNullableToJson(
    instance.type,
  ),
  'client_secret_expires_at': ?instance.clientSecretExpiresAt,
  'skip_consent': ?instance.skipConsent,
  'enable_end_session': ?instance.enableEndSession,
  'metadata': ?instance.metadata,
};

V1AdminDeleteUserPost$RequestBody _$V1AdminDeleteUserPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1AdminDeleteUserPost$RequestBody(userId: json['user_id'] as String);

Map<String, dynamic> _$V1AdminDeleteUserPost$RequestBodyToJson(
  V1AdminDeleteUserPost$RequestBody instance,
) => <String, dynamic>{'user_id': instance.userId};

V1AdminDeleteOauthClientPost$RequestBody
_$V1AdminDeleteOauthClientPost$RequestBodyFromJson(Map<String, dynamic> json) =>
    V1AdminDeleteOauthClientPost$RequestBody(
      clientId: json['client_id'] as String,
    );

Map<String, dynamic> _$V1AdminDeleteOauthClientPost$RequestBodyToJson(
  V1AdminDeleteOauthClientPost$RequestBody instance,
) => <String, dynamic>{'client_id': instance.clientId};

V1AdminUpdateUserPost$RequestBody _$V1AdminUpdateUserPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1AdminUpdateUserPost$RequestBody(
  userId: json['user_id'] as String,
  role: json['role'],
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$V1AdminUpdateUserPost$RequestBodyToJson(
  V1AdminUpdateUserPost$RequestBody instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'role': ?instance.role,
  'data': ?instance.data,
};

V1AdminUpdateOauthClientPost$RequestBody
_$V1AdminUpdateOauthClientPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => V1AdminUpdateOauthClientPost$RequestBody(
  clientId: json['client_id'] as String,
  redirectUris:
      (json['redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  scope: json['scope'] as String?,
  clientName: json['client_name'] as String?,
  clientUri: json['client_uri'] as String?,
  logoUri: json['logo_uri'] as String?,
  contacts:
      (json['contacts'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  tosUri: json['tos_uri'] as String?,
  policyUri: json['policy_uri'] as String?,
  softwareId: json['software_id'] as String?,
  softwareVersion: json['software_version'] as String?,
  softwareStatement: json['software_statement'] as String?,
  postLogoutRedirectUris:
      (json['post_logout_redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  grantTypes: v1AdminUpdateOauthClientPost$RequestBodyGrantTypesListFromJson(
    json['grant_types'] as List?,
  ),
  responseTypes:
      v1AdminUpdateOauthClientPost$RequestBodyResponseTypesListFromJson(
        json['response_types'] as List?,
      ),
  type: v1AdminUpdateOauthClientPost$RequestBodyTypeNullableFromJson(
    json['type'],
  ),
  clientSecretExpiresAt: json['client_secret_expires_at'],
  skipConsent: json['skip_consent'] as bool?,
  enableEndSession: json['enable_end_session'] as bool?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$V1AdminUpdateOauthClientPost$RequestBodyToJson(
  V1AdminUpdateOauthClientPost$RequestBody instance,
) => <String, dynamic>{
  'client_id': instance.clientId,
  'redirect_uris': ?instance.redirectUris,
  'scope': ?instance.scope,
  'client_name': ?instance.clientName,
  'client_uri': ?instance.clientUri,
  'logo_uri': ?instance.logoUri,
  'contacts': ?instance.contacts,
  'tos_uri': ?instance.tosUri,
  'policy_uri': ?instance.policyUri,
  'software_id': ?instance.softwareId,
  'software_version': ?instance.softwareVersion,
  'software_statement': ?instance.softwareStatement,
  'post_logout_redirect_uris': ?instance.postLogoutRedirectUris,
  'grant_types': v1AdminUpdateOauthClientPost$RequestBodyGrantTypesListToJson(
    instance.grantTypes,
  ),
  'response_types':
      v1AdminUpdateOauthClientPost$RequestBodyResponseTypesListToJson(
        instance.responseTypes,
      ),
  'type': ?v1AdminUpdateOauthClientPost$RequestBodyTypeNullableToJson(
    instance.type,
  ),
  'client_secret_expires_at': ?instance.clientSecretExpiresAt,
  'skip_consent': ?instance.skipConsent,
  'enable_end_session': ?instance.enableEndSession,
  'metadata': ?instance.metadata,
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

V1AdminCreateUserPost$Response _$V1AdminCreateUserPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1AdminCreateUserPost$Response(
  user: V1AdminCreateUserPost$Response$User.fromJson(
    json['user'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$V1AdminCreateUserPost$ResponseToJson(
  V1AdminCreateUserPost$Response instance,
) => <String, dynamic>{'user': instance.user.toJson()};

V1AdminCreateOauthClientPost$Response
_$V1AdminCreateOauthClientPost$ResponseFromJson(Map<String, dynamic> json) =>
    V1AdminCreateOauthClientPost$Response(
      $client: json['client'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$V1AdminCreateOauthClientPost$ResponseToJson(
  V1AdminCreateOauthClientPost$Response instance,
) => <String, dynamic>{'client': instance.$client};

V1AdminDeleteUserPost$Response _$V1AdminDeleteUserPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1AdminDeleteUserPost$Response(
  success: json['success'] as bool,
  userId: json['user_id'] as String,
);

Map<String, dynamic> _$V1AdminDeleteUserPost$ResponseToJson(
  V1AdminDeleteUserPost$Response instance,
) => <String, dynamic>{'success': instance.success, 'user_id': instance.userId};

V1AdminDeleteOauthClientPost$Response
_$V1AdminDeleteOauthClientPost$ResponseFromJson(Map<String, dynamic> json) =>
    V1AdminDeleteOauthClientPost$Response(
      success: json['success'] as bool,
      clientId: json['client_id'] as String,
    );

Map<String, dynamic> _$V1AdminDeleteOauthClientPost$ResponseToJson(
  V1AdminDeleteOauthClientPost$Response instance,
) => <String, dynamic>{
  'success': instance.success,
  'client_id': instance.clientId,
};

V1AdminUpdateUserPost$Response _$V1AdminUpdateUserPost$ResponseFromJson(
  Map<String, dynamic> json,
) => V1AdminUpdateUserPost$Response(
  user: V1AdminUpdateUserPost$Response$User.fromJson(
    json['user'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$V1AdminUpdateUserPost$ResponseToJson(
  V1AdminUpdateUserPost$Response instance,
) => <String, dynamic>{'user': instance.user.toJson()};

V1AdminUpdateOauthClientPost$Response
_$V1AdminUpdateOauthClientPost$ResponseFromJson(Map<String, dynamic> json) =>
    V1AdminUpdateOauthClientPost$Response(
      $client: json['client'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$V1AdminUpdateOauthClientPost$ResponseToJson(
  V1AdminUpdateOauthClientPost$Response instance,
) => <String, dynamic>{'client': instance.$client};

V1AdminListUsersGet$Response _$V1AdminListUsersGet$ResponseFromJson(
  Map<String, dynamic> json,
) => V1AdminListUsersGet$Response(
  users: (json['users'] as List<dynamic>)
      .map(
        (e) => V1AdminListUsersGet$Response$Users$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  total: (json['total'] as num).toDouble(),
  limit: (json['limit'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['page_size'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
);

Map<String, dynamic> _$V1AdminListUsersGet$ResponseToJson(
  V1AdminListUsersGet$Response instance,
) => <String, dynamic>{
  'users': instance.users.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'limit': instance.limit,
  'offset': instance.offset,
  'page': instance.page,
  'page_size': instance.pageSize,
  'total_pages': instance.totalPages,
};

V1AdminListOauthClientsGet$Response
_$V1AdminListOauthClientsGet$ResponseFromJson(Map<String, dynamic> json) =>
    V1AdminListOauthClientsGet$Response(
      clients: (json['clients'] as List<dynamic>)
          .map(
            (e) => V1AdminListOauthClientsGet$Response$Clients$Item.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

Map<String, dynamic> _$V1AdminListOauthClientsGet$ResponseToJson(
  V1AdminListOauthClientsGet$Response instance,
) => <String, dynamic>{
  'clients': instance.clients.map((e) => e.toJson()).toList(),
};

V1UserInfoGet$Response _$V1UserInfoGet$ResponseFromJson(
  Map<String, dynamic> json,
) => V1UserInfoGet$Response(
  emailSignInEnabled: json['email_sign_in_enabled'] as bool,
  emailSignUpEnabled: json['email_sign_up_enabled'] as bool,
  ssoProviders: (json['sso_providers'] as List<dynamic>)
      .map(
        (e) => V1UserInfoGet$Response$SsoProviders$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

Map<String, dynamic> _$V1UserInfoGet$ResponseToJson(
  V1UserInfoGet$Response instance,
) => <String, dynamic>{
  'email_sign_in_enabled': instance.emailSignInEnabled,
  'email_sign_up_enabled': instance.emailSignUpEnabled,
  'sso_providers': instance.ssoProviders.map((e) => e.toJson()).toList(),
};

V1UserGetUserGet$Response _$V1UserGetUserGet$ResponseFromJson(
  Map<String, dynamic> json,
) => V1UserGetUserGet$Response(
  user: V1UserGetUserGet$Response$User.fromJson(
    json['user'] as Map<String, dynamic>,
  ),
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
  user: V1UserSignInEmailPost$Response$User.fromJson(
    json['user'] as Map<String, dynamic>,
  ),
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
  user: V1UserSignUpEmailPost$Response$User.fromJson(
    json['user'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$V1UserSignUpEmailPost$ResponseToJson(
  V1UserSignUpEmailPost$Response instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'token': instance.token,
  'expires_at': instance.expiresAt.toIso8601String(),
  'user': instance.user.toJson(),
};

HippoAuthErrorResponse$Error _$HippoAuthErrorResponse$ErrorFromJson(
  Map<String, dynamic> json,
) => HippoAuthErrorResponse$Error(
  code: json['code'] as String,
  message: json['message'] as String,
  details: json['details'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$HippoAuthErrorResponse$ErrorToJson(
  HippoAuthErrorResponse$Error instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'details': ?instance.details,
};

V1AdminCreateUserPost$Response$User
_$V1AdminCreateUserPost$Response$UserFromJson(Map<String, dynamic> json) =>
    V1AdminCreateUserPost$Response$User(
      id: json['id'] as String,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool,
      name: json['name'] as String,
      image: json['image'] as String?,
      role: json['role'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$V1AdminCreateUserPost$Response$UserToJson(
  V1AdminCreateUserPost$Response$User instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'emailVerified': instance.emailVerified,
  'name': instance.name,
  'image': ?instance.image,
  'role': ?instance.role,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

V1AdminCreateOauthClientPost$Response$Client
_$V1AdminCreateOauthClientPost$Response$ClientFromJson(
  Map<String, dynamic> json,
) => V1AdminCreateOauthClientPost$Response$Client(
  clientId: json['client_id'] as String,
  clientSecret: json['client_secret'] as String?,
  clientSecretExpiresAt: (json['client_secret_expires_at'] as num?)?.toDouble(),
  scope: json['scope'] as String?,
  userId: json['user_id'] as String?,
  clientIdIssuedAt: (json['client_id_issued_at'] as num?)?.toDouble(),
  clientName: json['client_name'] as String?,
  clientUri: json['client_uri'] as String?,
  logoUri: json['logo_uri'] as String?,
  contacts:
      (json['contacts'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  tosUri: json['tos_uri'] as String?,
  policyUri: json['policy_uri'] as String?,
  softwareId: json['software_id'] as String?,
  softwareVersion: json['software_version'] as String?,
  softwareStatement: json['software_statement'] as String?,
  redirectUris:
      (json['redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  postLogoutRedirectUris:
      (json['post_logout_redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  tokenEndpointAuthMethod:
      v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableFromJson(
        json['token_endpoint_auth_method'],
      ),
  grantTypes:
      v1AdminCreateOauthClientPost$Response$ClientGrantTypesListFromJson(
        json['grant_types'] as List?,
      ),
  responseTypes:
      v1AdminCreateOauthClientPost$Response$ClientResponseTypesListFromJson(
        json['response_types'] as List?,
      ),
  public: json['public'] as bool?,
  type: v1AdminCreateOauthClientPost$Response$ClientTypeNullableFromJson(
    json['type'],
  ),
  disabled: json['disabled'] as bool?,
  skipConsent: json['skip_consent'] as bool?,
  enableEndSession: json['enable_end_session'] as bool?,
  referenceId: json['reference_id'] as String?,
  metadata: json['metadata'],
);

Map<String, dynamic> _$V1AdminCreateOauthClientPost$Response$ClientToJson(
  V1AdminCreateOauthClientPost$Response$Client instance,
) => <String, dynamic>{
  'client_id': instance.clientId,
  'client_secret': ?instance.clientSecret,
  'client_secret_expires_at': ?instance.clientSecretExpiresAt,
  'scope': ?instance.scope,
  'user_id': ?instance.userId,
  'client_id_issued_at': ?instance.clientIdIssuedAt,
  'client_name': ?instance.clientName,
  'client_uri': ?instance.clientUri,
  'logo_uri': ?instance.logoUri,
  'contacts': ?instance.contacts,
  'tos_uri': ?instance.tosUri,
  'policy_uri': ?instance.policyUri,
  'software_id': ?instance.softwareId,
  'software_version': ?instance.softwareVersion,
  'software_statement': ?instance.softwareStatement,
  'redirect_uris': ?instance.redirectUris,
  'post_logout_redirect_uris': ?instance.postLogoutRedirectUris,
  'token_endpoint_auth_method':
      ?v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableToJson(
        instance.tokenEndpointAuthMethod,
      ),
  'grant_types':
      v1AdminCreateOauthClientPost$Response$ClientGrantTypesListToJson(
        instance.grantTypes,
      ),
  'response_types':
      v1AdminCreateOauthClientPost$Response$ClientResponseTypesListToJson(
        instance.responseTypes,
      ),
  'public': ?instance.public,
  'type': ?v1AdminCreateOauthClientPost$Response$ClientTypeNullableToJson(
    instance.type,
  ),
  'disabled': ?instance.disabled,
  'skip_consent': ?instance.skipConsent,
  'enable_end_session': ?instance.enableEndSession,
  'reference_id': ?instance.referenceId,
  'metadata': ?instance.metadata,
};

V1AdminUpdateUserPost$Response$User
_$V1AdminUpdateUserPost$Response$UserFromJson(Map<String, dynamic> json) =>
    V1AdminUpdateUserPost$Response$User(
      id: json['id'] as String,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool,
      name: json['name'] as String,
      image: json['image'] as String?,
      role: json['role'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$V1AdminUpdateUserPost$Response$UserToJson(
  V1AdminUpdateUserPost$Response$User instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'emailVerified': instance.emailVerified,
  'name': instance.name,
  'image': ?instance.image,
  'role': ?instance.role,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

V1AdminUpdateOauthClientPost$Response$Client
_$V1AdminUpdateOauthClientPost$Response$ClientFromJson(
  Map<String, dynamic> json,
) => V1AdminUpdateOauthClientPost$Response$Client(
  clientId: json['client_id'] as String,
  clientSecret: json['client_secret'] as String?,
  clientSecretExpiresAt: (json['client_secret_expires_at'] as num?)?.toDouble(),
  scope: json['scope'] as String?,
  userId: json['user_id'] as String?,
  clientIdIssuedAt: (json['client_id_issued_at'] as num?)?.toDouble(),
  clientName: json['client_name'] as String?,
  clientUri: json['client_uri'] as String?,
  logoUri: json['logo_uri'] as String?,
  contacts:
      (json['contacts'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  tosUri: json['tos_uri'] as String?,
  policyUri: json['policy_uri'] as String?,
  softwareId: json['software_id'] as String?,
  softwareVersion: json['software_version'] as String?,
  softwareStatement: json['software_statement'] as String?,
  redirectUris:
      (json['redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  postLogoutRedirectUris:
      (json['post_logout_redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  tokenEndpointAuthMethod:
      v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableFromJson(
        json['token_endpoint_auth_method'],
      ),
  grantTypes:
      v1AdminUpdateOauthClientPost$Response$ClientGrantTypesListFromJson(
        json['grant_types'] as List?,
      ),
  responseTypes:
      v1AdminUpdateOauthClientPost$Response$ClientResponseTypesListFromJson(
        json['response_types'] as List?,
      ),
  public: json['public'] as bool?,
  type: v1AdminUpdateOauthClientPost$Response$ClientTypeNullableFromJson(
    json['type'],
  ),
  disabled: json['disabled'] as bool?,
  skipConsent: json['skip_consent'] as bool?,
  enableEndSession: json['enable_end_session'] as bool?,
  referenceId: json['reference_id'] as String?,
  metadata: json['metadata'],
);

Map<String, dynamic> _$V1AdminUpdateOauthClientPost$Response$ClientToJson(
  V1AdminUpdateOauthClientPost$Response$Client instance,
) => <String, dynamic>{
  'client_id': instance.clientId,
  'client_secret': ?instance.clientSecret,
  'client_secret_expires_at': ?instance.clientSecretExpiresAt,
  'scope': ?instance.scope,
  'user_id': ?instance.userId,
  'client_id_issued_at': ?instance.clientIdIssuedAt,
  'client_name': ?instance.clientName,
  'client_uri': ?instance.clientUri,
  'logo_uri': ?instance.logoUri,
  'contacts': ?instance.contacts,
  'tos_uri': ?instance.tosUri,
  'policy_uri': ?instance.policyUri,
  'software_id': ?instance.softwareId,
  'software_version': ?instance.softwareVersion,
  'software_statement': ?instance.softwareStatement,
  'redirect_uris': ?instance.redirectUris,
  'post_logout_redirect_uris': ?instance.postLogoutRedirectUris,
  'token_endpoint_auth_method':
      ?v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableToJson(
        instance.tokenEndpointAuthMethod,
      ),
  'grant_types':
      v1AdminUpdateOauthClientPost$Response$ClientGrantTypesListToJson(
        instance.grantTypes,
      ),
  'response_types':
      v1AdminUpdateOauthClientPost$Response$ClientResponseTypesListToJson(
        instance.responseTypes,
      ),
  'public': ?instance.public,
  'type': ?v1AdminUpdateOauthClientPost$Response$ClientTypeNullableToJson(
    instance.type,
  ),
  'disabled': ?instance.disabled,
  'skip_consent': ?instance.skipConsent,
  'enable_end_session': ?instance.enableEndSession,
  'reference_id': ?instance.referenceId,
  'metadata': ?instance.metadata,
};

V1AdminListUsersGet$Response$Users$Item
_$V1AdminListUsersGet$Response$Users$ItemFromJson(Map<String, dynamic> json) =>
    V1AdminListUsersGet$Response$Users$Item(
      id: json['id'] as String,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool,
      name: json['name'] as String,
      image: json['image'] as String?,
      role: json['role'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$V1AdminListUsersGet$Response$Users$ItemToJson(
  V1AdminListUsersGet$Response$Users$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'emailVerified': instance.emailVerified,
  'name': instance.name,
  'image': ?instance.image,
  'role': ?instance.role,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

V1AdminListOauthClientsGet$Response$Clients$Item
_$V1AdminListOauthClientsGet$Response$Clients$ItemFromJson(
  Map<String, dynamic> json,
) => V1AdminListOauthClientsGet$Response$Clients$Item(
  clientId: json['client_id'] as String,
  clientSecret: json['client_secret'] as String?,
  clientSecretExpiresAt: (json['client_secret_expires_at'] as num?)?.toDouble(),
  scope: json['scope'] as String?,
  userId: json['user_id'] as String?,
  clientIdIssuedAt: (json['client_id_issued_at'] as num?)?.toDouble(),
  clientName: json['client_name'] as String?,
  clientUri: json['client_uri'] as String?,
  logoUri: json['logo_uri'] as String?,
  contacts:
      (json['contacts'] as List<dynamic>?)?.map((e) => e as Object).toList() ??
      [],
  tosUri: json['tos_uri'] as String?,
  policyUri: json['policy_uri'] as String?,
  softwareId: json['software_id'] as String?,
  softwareVersion: json['software_version'] as String?,
  softwareStatement: json['software_statement'] as String?,
  redirectUris:
      (json['redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as Object)
          .toList() ??
      [],
  postLogoutRedirectUris:
      (json['post_logout_redirect_uris'] as List<dynamic>?)
          ?.map((e) => e as Object)
          .toList() ??
      [],
  tokenEndpointAuthMethod:
      v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodNullableFromJson(
        json['token_endpoint_auth_method'],
      ),
  grantTypes:
      (json['grant_types'] as List<dynamic>?)
          ?.map((e) => e as Object)
          .toList() ??
      [],
  responseTypes:
      (json['response_types'] as List<dynamic>?)
          ?.map((e) => e as Object)
          .toList() ??
      [],
  public: json['public'] as bool?,
  type: v1AdminListOauthClientsGet$Response$Clients$ItemTypeNullableFromJson(
    json['type'],
  ),
  disabled: json['disabled'] as bool?,
  skipConsent: json['skip_consent'] as bool?,
  enableEndSession: json['enable_end_session'] as bool?,
  referenceId: json['reference_id'] as String?,
  metadata: json['metadata'],
);

Map<String, dynamic> _$V1AdminListOauthClientsGet$Response$Clients$ItemToJson(
  V1AdminListOauthClientsGet$Response$Clients$Item instance,
) => <String, dynamic>{
  'client_id': instance.clientId,
  'client_secret': ?instance.clientSecret,
  'client_secret_expires_at': ?instance.clientSecretExpiresAt,
  'scope': ?instance.scope,
  'user_id': ?instance.userId,
  'client_id_issued_at': ?instance.clientIdIssuedAt,
  'client_name': ?instance.clientName,
  'client_uri': ?instance.clientUri,
  'logo_uri': ?instance.logoUri,
  'contacts': ?instance.contacts,
  'tos_uri': ?instance.tosUri,
  'policy_uri': ?instance.policyUri,
  'software_id': ?instance.softwareId,
  'software_version': ?instance.softwareVersion,
  'software_statement': ?instance.softwareStatement,
  'redirect_uris': ?instance.redirectUris,
  'post_logout_redirect_uris': ?instance.postLogoutRedirectUris,
  'token_endpoint_auth_method':
      ?v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodNullableToJson(
        instance.tokenEndpointAuthMethod,
      ),
  'grant_types': ?instance.grantTypes,
  'response_types': ?instance.responseTypes,
  'public': ?instance.public,
  'type': ?v1AdminListOauthClientsGet$Response$Clients$ItemTypeNullableToJson(
    instance.type,
  ),
  'disabled': ?instance.disabled,
  'skip_consent': ?instance.skipConsent,
  'enable_end_session': ?instance.enableEndSession,
  'reference_id': ?instance.referenceId,
  'metadata': ?instance.metadata,
};

V1UserInfoGet$Response$SsoProviders$Item
_$V1UserInfoGet$Response$SsoProviders$ItemFromJson(Map<String, dynamic> json) =>
    V1UserInfoGet$Response$SsoProviders$Item(
      providerId: json['provider_id'] as String,
      providerType:
          v1UserInfoGet$Response$SsoProviders$ItemProviderTypeFromJson(
            json['provider_type'],
          ),
    );

Map<String, dynamic> _$V1UserInfoGet$Response$SsoProviders$ItemToJson(
  V1UserInfoGet$Response$SsoProviders$Item instance,
) => <String, dynamic>{
  'provider_id': instance.providerId,
  'provider_type': ?v1UserInfoGet$Response$SsoProviders$ItemProviderTypeToJson(
    instance.providerType,
  ),
};

V1UserGetUserGet$Response$User _$V1UserGetUserGet$Response$UserFromJson(
  Map<String, dynamic> json,
) => V1UserGetUserGet$Response$User(
  id: json['id'] as String,
  email: json['email'] as String,
  emailVerified: json['emailVerified'] as bool,
  name: json['name'] as String,
  image: json['image'] as String?,
  role: json['role'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$V1UserGetUserGet$Response$UserToJson(
  V1UserGetUserGet$Response$User instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'emailVerified': instance.emailVerified,
  'name': instance.name,
  'image': ?instance.image,
  'role': ?instance.role,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

V1UserSignInEmailPost$Response$User
_$V1UserSignInEmailPost$Response$UserFromJson(Map<String, dynamic> json) =>
    V1UserSignInEmailPost$Response$User(
      id: json['id'] as String,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool,
      name: json['name'] as String,
      image: json['image'] as String?,
      role: json['role'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$V1UserSignInEmailPost$Response$UserToJson(
  V1UserSignInEmailPost$Response$User instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'emailVerified': instance.emailVerified,
  'name': instance.name,
  'image': ?instance.image,
  'role': ?instance.role,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
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

V1UserSignUpEmailPost$Response$User
_$V1UserSignUpEmailPost$Response$UserFromJson(Map<String, dynamic> json) =>
    V1UserSignUpEmailPost$Response$User(
      id: json['id'] as String,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool,
      name: json['name'] as String,
      image: json['image'] as String?,
      role: json['role'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$V1UserSignUpEmailPost$Response$UserToJson(
  V1UserSignUpEmailPost$Response$User instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'emailVerified': instance.emailVerified,
  'name': instance.name,
  'image': ?instance.image,
  'role': ?instance.role,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
