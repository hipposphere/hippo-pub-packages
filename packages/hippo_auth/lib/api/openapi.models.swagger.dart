// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';
import 'dart:convert';

import 'openapi.enums.swagger.dart' as enums;

part 'openapi.models.swagger.g.dart';

@JsonSerializable(explicitToJson: true)
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.name,
    this.image,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  static const toJsonFactory = _$AuthUserToJson;
  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'emailVerified', includeIfNull: false)
  final bool emailVerified;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'image', includeIfNull: false)
  final String? image;
  @JsonKey(name: 'role', includeIfNull: false)
  final String? role;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final DateTime updatedAt;
  static const fromJsonFactory = _$AuthUserFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AuthUser &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.image, image) ||
                const DeepCollectionEquality().equals(other.image, image)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(image) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $AuthUserExtension on AuthUser {
  AuthUser copyWith({
    String? id,
    String? email,
    bool? emailVerified,
    String? name,
    String? image,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      name: name ?? this.name,
      image: image ?? this.image,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  AuthUser copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? email,
    Wrapped<bool>? emailVerified,
    Wrapped<String>? name,
    Wrapped<String?>? image,
    Wrapped<String?>? role,
    Wrapped<DateTime>? createdAt,
    Wrapped<DateTime>? updatedAt,
  }) {
    return AuthUser(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      name: (name != null ? name.value : this.name),
      image: (image != null ? image.value : this.image),
      role: (role != null ? role.value : this.role),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class HippoAuthErrorResponse {
  const HippoAuthErrorResponse({required this.error});

  factory HippoAuthErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$HippoAuthErrorResponseFromJson(json);

  static const toJsonFactory = _$HippoAuthErrorResponseToJson;
  Map<String, dynamic> toJson() => _$HippoAuthErrorResponseToJson(this);

  @JsonKey(name: 'error', includeIfNull: false)
  final HippoAuthErrorResponse$Error error;
  static const fromJsonFactory = _$HippoAuthErrorResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HippoAuthErrorResponse &&
            (identical(other.error, error) ||
                const DeepCollectionEquality().equals(other.error, error)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(error) ^ runtimeType.hashCode;
}

extension $HippoAuthErrorResponseExtension on HippoAuthErrorResponse {
  HippoAuthErrorResponse copyWith({HippoAuthErrorResponse$Error? error}) {
    return HippoAuthErrorResponse(error: error ?? this.error);
  }

  HippoAuthErrorResponse copyWithWrapped({
    Wrapped<HippoAuthErrorResponse$Error>? error,
  }) {
    return HippoAuthErrorResponse(
      error: (error != null ? error.value : this.error),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminCreateUserPost$RequestBody {
  const V1AdminCreateUserPost$RequestBody({
    required this.email,
    required this.name,
    this.password,
    this.role,
    this.data,
  });

  factory V1AdminCreateUserPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminCreateUserPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1AdminCreateUserPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminCreateUserPost$RequestBodyToJson(this);

  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'password', includeIfNull: false)
  final String? password;
  @JsonKey(name: 'role', includeIfNull: false)
  final dynamic role;
  @JsonKey(name: 'data', includeIfNull: false)
  final Map<String, dynamic>? data;
  static const fromJsonFactory = _$V1AdminCreateUserPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminCreateUserPost$RequestBody &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality().equals(
                  other.password,
                  password,
                )) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(password) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(data) ^
      runtimeType.hashCode;
}

extension $V1AdminCreateUserPost$RequestBodyExtension
    on V1AdminCreateUserPost$RequestBody {
  V1AdminCreateUserPost$RequestBody copyWith({
    String? email,
    String? name,
    String? password,
    dynamic role,
    Map<String, dynamic>? data,
  }) {
    return V1AdminCreateUserPost$RequestBody(
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      role: role ?? this.role,
      data: data ?? this.data,
    );
  }

  V1AdminCreateUserPost$RequestBody copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String>? name,
    Wrapped<String?>? password,
    Wrapped<dynamic>? role,
    Wrapped<Map<String, dynamic>?>? data,
  }) {
    return V1AdminCreateUserPost$RequestBody(
      email: (email != null ? email.value : this.email),
      name: (name != null ? name.value : this.name),
      password: (password != null ? password.value : this.password),
      role: (role != null ? role.value : this.role),
      data: (data != null ? data.value : this.data),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminCreateOauthClientPost$RequestBody {
  const V1AdminCreateOauthClientPost$RequestBody({
    required this.redirectUris,
    this.scope,
    this.clientName,
    this.clientUri,
    this.logoUri,
    this.contacts,
    this.tosUri,
    this.policyUri,
    this.softwareId,
    this.softwareVersion,
    this.softwareStatement,
    this.postLogoutRedirectUris,
    this.tokenEndpointAuthMethod,
    this.grantTypes,
    this.responseTypes,
    this.type,
    this.clientSecretExpiresAt,
    this.skipConsent,
    this.enableEndSession,
    this.metadata,
  });

  factory V1AdminCreateOauthClientPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminCreateOauthClientPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1AdminCreateOauthClientPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminCreateOauthClientPost$RequestBodyToJson(this);

  @JsonKey(
    name: 'redirect_uris',
    includeIfNull: false,
    defaultValue: <String>[],
  )
  final List<String> redirectUris;
  @JsonKey(name: 'scope', includeIfNull: false)
  final String? scope;
  @JsonKey(name: 'client_name', includeIfNull: false)
  final String? clientName;
  @JsonKey(name: 'client_uri', includeIfNull: false)
  final String? clientUri;
  @JsonKey(name: 'logo_uri', includeIfNull: false)
  final String? logoUri;
  @JsonKey(name: 'contacts', includeIfNull: false, defaultValue: <String>[])
  final List<String>? contacts;
  @JsonKey(name: 'tos_uri', includeIfNull: false)
  final String? tosUri;
  @JsonKey(name: 'policy_uri', includeIfNull: false)
  final String? policyUri;
  @JsonKey(name: 'software_id', includeIfNull: false)
  final String? softwareId;
  @JsonKey(name: 'software_version', includeIfNull: false)
  final String? softwareVersion;
  @JsonKey(name: 'software_statement', includeIfNull: false)
  final String? softwareStatement;
  @JsonKey(
    name: 'post_logout_redirect_uris',
    includeIfNull: false,
    defaultValue: <String>[],
  )
  final List<String>? postLogoutRedirectUris;
  @JsonKey(
    name: 'token_endpoint_auth_method',
    includeIfNull: false,
    toJson:
        v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodNullableToJson,
    fromJson:
        v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodNullableFromJson,
  )
  final enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod?
  tokenEndpointAuthMethod;
  @JsonKey(
    name: 'grant_types',
    includeIfNull: false,
    toJson: v1AdminCreateOauthClientPost$RequestBodyGrantTypesListToJson,
    fromJson: v1AdminCreateOauthClientPost$RequestBodyGrantTypesListFromJson,
  )
  final List<enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes>?
  grantTypes;
  @JsonKey(
    name: 'response_types',
    includeIfNull: false,
    toJson: v1AdminCreateOauthClientPost$RequestBodyResponseTypesListToJson,
    fromJson: v1AdminCreateOauthClientPost$RequestBodyResponseTypesListFromJson,
  )
  final List<enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes>?
  responseTypes;
  @JsonKey(
    name: 'type',
    includeIfNull: false,
    toJson: v1AdminCreateOauthClientPost$RequestBodyTypeNullableToJson,
    fromJson: v1AdminCreateOauthClientPost$RequestBodyTypeNullableFromJson,
  )
  final enums.V1AdminCreateOauthClientPost$RequestBodyType? type;
  @JsonKey(name: 'client_secret_expires_at', includeIfNull: false)
  final dynamic clientSecretExpiresAt;
  @JsonKey(name: 'skip_consent', includeIfNull: false)
  final bool? skipConsent;
  @JsonKey(name: 'enable_end_session', includeIfNull: false)
  final bool? enableEndSession;
  @JsonKey(name: 'metadata', includeIfNull: false)
  final Map<String, dynamic>? metadata;
  static const fromJsonFactory =
      _$V1AdminCreateOauthClientPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminCreateOauthClientPost$RequestBody &&
            (identical(other.redirectUris, redirectUris) ||
                const DeepCollectionEquality().equals(
                  other.redirectUris,
                  redirectUris,
                )) &&
            (identical(other.scope, scope) ||
                const DeepCollectionEquality().equals(other.scope, scope)) &&
            (identical(other.clientName, clientName) ||
                const DeepCollectionEquality().equals(
                  other.clientName,
                  clientName,
                )) &&
            (identical(other.clientUri, clientUri) ||
                const DeepCollectionEquality().equals(
                  other.clientUri,
                  clientUri,
                )) &&
            (identical(other.logoUri, logoUri) ||
                const DeepCollectionEquality().equals(
                  other.logoUri,
                  logoUri,
                )) &&
            (identical(other.contacts, contacts) ||
                const DeepCollectionEquality().equals(
                  other.contacts,
                  contacts,
                )) &&
            (identical(other.tosUri, tosUri) ||
                const DeepCollectionEquality().equals(other.tosUri, tosUri)) &&
            (identical(other.policyUri, policyUri) ||
                const DeepCollectionEquality().equals(
                  other.policyUri,
                  policyUri,
                )) &&
            (identical(other.softwareId, softwareId) ||
                const DeepCollectionEquality().equals(
                  other.softwareId,
                  softwareId,
                )) &&
            (identical(other.softwareVersion, softwareVersion) ||
                const DeepCollectionEquality().equals(
                  other.softwareVersion,
                  softwareVersion,
                )) &&
            (identical(other.softwareStatement, softwareStatement) ||
                const DeepCollectionEquality().equals(
                  other.softwareStatement,
                  softwareStatement,
                )) &&
            (identical(other.postLogoutRedirectUris, postLogoutRedirectUris) ||
                const DeepCollectionEquality().equals(
                  other.postLogoutRedirectUris,
                  postLogoutRedirectUris,
                )) &&
            (identical(
                  other.tokenEndpointAuthMethod,
                  tokenEndpointAuthMethod,
                ) ||
                const DeepCollectionEquality().equals(
                  other.tokenEndpointAuthMethod,
                  tokenEndpointAuthMethod,
                )) &&
            (identical(other.grantTypes, grantTypes) ||
                const DeepCollectionEquality().equals(
                  other.grantTypes,
                  grantTypes,
                )) &&
            (identical(other.responseTypes, responseTypes) ||
                const DeepCollectionEquality().equals(
                  other.responseTypes,
                  responseTypes,
                )) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.clientSecretExpiresAt, clientSecretExpiresAt) ||
                const DeepCollectionEquality().equals(
                  other.clientSecretExpiresAt,
                  clientSecretExpiresAt,
                )) &&
            (identical(other.skipConsent, skipConsent) ||
                const DeepCollectionEquality().equals(
                  other.skipConsent,
                  skipConsent,
                )) &&
            (identical(other.enableEndSession, enableEndSession) ||
                const DeepCollectionEquality().equals(
                  other.enableEndSession,
                  enableEndSession,
                )) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality().equals(
                  other.metadata,
                  metadata,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(redirectUris) ^
      const DeepCollectionEquality().hash(scope) ^
      const DeepCollectionEquality().hash(clientName) ^
      const DeepCollectionEquality().hash(clientUri) ^
      const DeepCollectionEquality().hash(logoUri) ^
      const DeepCollectionEquality().hash(contacts) ^
      const DeepCollectionEquality().hash(tosUri) ^
      const DeepCollectionEquality().hash(policyUri) ^
      const DeepCollectionEquality().hash(softwareId) ^
      const DeepCollectionEquality().hash(softwareVersion) ^
      const DeepCollectionEquality().hash(softwareStatement) ^
      const DeepCollectionEquality().hash(postLogoutRedirectUris) ^
      const DeepCollectionEquality().hash(tokenEndpointAuthMethod) ^
      const DeepCollectionEquality().hash(grantTypes) ^
      const DeepCollectionEquality().hash(responseTypes) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(clientSecretExpiresAt) ^
      const DeepCollectionEquality().hash(skipConsent) ^
      const DeepCollectionEquality().hash(enableEndSession) ^
      const DeepCollectionEquality().hash(metadata) ^
      runtimeType.hashCode;
}

extension $V1AdminCreateOauthClientPost$RequestBodyExtension
    on V1AdminCreateOauthClientPost$RequestBody {
  V1AdminCreateOauthClientPost$RequestBody copyWith({
    List<String>? redirectUris,
    String? scope,
    String? clientName,
    String? clientUri,
    String? logoUri,
    List<String>? contacts,
    String? tosUri,
    String? policyUri,
    String? softwareId,
    String? softwareVersion,
    String? softwareStatement,
    List<String>? postLogoutRedirectUris,
    enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod?
    tokenEndpointAuthMethod,
    List<enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes>? grantTypes,
    List<enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes>?
    responseTypes,
    enums.V1AdminCreateOauthClientPost$RequestBodyType? type,
    dynamic clientSecretExpiresAt,
    bool? skipConsent,
    bool? enableEndSession,
    Map<String, dynamic>? metadata,
  }) {
    return V1AdminCreateOauthClientPost$RequestBody(
      redirectUris: redirectUris ?? this.redirectUris,
      scope: scope ?? this.scope,
      clientName: clientName ?? this.clientName,
      clientUri: clientUri ?? this.clientUri,
      logoUri: logoUri ?? this.logoUri,
      contacts: contacts ?? this.contacts,
      tosUri: tosUri ?? this.tosUri,
      policyUri: policyUri ?? this.policyUri,
      softwareId: softwareId ?? this.softwareId,
      softwareVersion: softwareVersion ?? this.softwareVersion,
      softwareStatement: softwareStatement ?? this.softwareStatement,
      postLogoutRedirectUris:
          postLogoutRedirectUris ?? this.postLogoutRedirectUris,
      tokenEndpointAuthMethod:
          tokenEndpointAuthMethod ?? this.tokenEndpointAuthMethod,
      grantTypes: grantTypes ?? this.grantTypes,
      responseTypes: responseTypes ?? this.responseTypes,
      type: type ?? this.type,
      clientSecretExpiresAt:
          clientSecretExpiresAt ?? this.clientSecretExpiresAt,
      skipConsent: skipConsent ?? this.skipConsent,
      enableEndSession: enableEndSession ?? this.enableEndSession,
      metadata: metadata ?? this.metadata,
    );
  }

  V1AdminCreateOauthClientPost$RequestBody copyWithWrapped({
    Wrapped<List<String>>? redirectUris,
    Wrapped<String?>? scope,
    Wrapped<String?>? clientName,
    Wrapped<String?>? clientUri,
    Wrapped<String?>? logoUri,
    Wrapped<List<String>?>? contacts,
    Wrapped<String?>? tosUri,
    Wrapped<String?>? policyUri,
    Wrapped<String?>? softwareId,
    Wrapped<String?>? softwareVersion,
    Wrapped<String?>? softwareStatement,
    Wrapped<List<String>?>? postLogoutRedirectUris,
    Wrapped<
      enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod?
    >?
    tokenEndpointAuthMethod,
    Wrapped<List<enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes>?>?
    grantTypes,
    Wrapped<List<enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes>?>?
    responseTypes,
    Wrapped<enums.V1AdminCreateOauthClientPost$RequestBodyType?>? type,
    Wrapped<dynamic>? clientSecretExpiresAt,
    Wrapped<bool?>? skipConsent,
    Wrapped<bool?>? enableEndSession,
    Wrapped<Map<String, dynamic>?>? metadata,
  }) {
    return V1AdminCreateOauthClientPost$RequestBody(
      redirectUris: (redirectUris != null
          ? redirectUris.value
          : this.redirectUris),
      scope: (scope != null ? scope.value : this.scope),
      clientName: (clientName != null ? clientName.value : this.clientName),
      clientUri: (clientUri != null ? clientUri.value : this.clientUri),
      logoUri: (logoUri != null ? logoUri.value : this.logoUri),
      contacts: (contacts != null ? contacts.value : this.contacts),
      tosUri: (tosUri != null ? tosUri.value : this.tosUri),
      policyUri: (policyUri != null ? policyUri.value : this.policyUri),
      softwareId: (softwareId != null ? softwareId.value : this.softwareId),
      softwareVersion: (softwareVersion != null
          ? softwareVersion.value
          : this.softwareVersion),
      softwareStatement: (softwareStatement != null
          ? softwareStatement.value
          : this.softwareStatement),
      postLogoutRedirectUris: (postLogoutRedirectUris != null
          ? postLogoutRedirectUris.value
          : this.postLogoutRedirectUris),
      tokenEndpointAuthMethod: (tokenEndpointAuthMethod != null
          ? tokenEndpointAuthMethod.value
          : this.tokenEndpointAuthMethod),
      grantTypes: (grantTypes != null ? grantTypes.value : this.grantTypes),
      responseTypes: (responseTypes != null
          ? responseTypes.value
          : this.responseTypes),
      type: (type != null ? type.value : this.type),
      clientSecretExpiresAt: (clientSecretExpiresAt != null
          ? clientSecretExpiresAt.value
          : this.clientSecretExpiresAt),
      skipConsent: (skipConsent != null ? skipConsent.value : this.skipConsent),
      enableEndSession: (enableEndSession != null
          ? enableEndSession.value
          : this.enableEndSession),
      metadata: (metadata != null ? metadata.value : this.metadata),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminDeleteUserPost$RequestBody {
  const V1AdminDeleteUserPost$RequestBody({required this.userId});

  factory V1AdminDeleteUserPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminDeleteUserPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1AdminDeleteUserPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminDeleteUserPost$RequestBodyToJson(this);

  @JsonKey(name: 'user_id', includeIfNull: false)
  final String userId;
  static const fromJsonFactory = _$V1AdminDeleteUserPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminDeleteUserPost$RequestBody &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(userId) ^ runtimeType.hashCode;
}

extension $V1AdminDeleteUserPost$RequestBodyExtension
    on V1AdminDeleteUserPost$RequestBody {
  V1AdminDeleteUserPost$RequestBody copyWith({String? userId}) {
    return V1AdminDeleteUserPost$RequestBody(userId: userId ?? this.userId);
  }

  V1AdminDeleteUserPost$RequestBody copyWithWrapped({Wrapped<String>? userId}) {
    return V1AdminDeleteUserPost$RequestBody(
      userId: (userId != null ? userId.value : this.userId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminDeleteOauthClientPost$RequestBody {
  const V1AdminDeleteOauthClientPost$RequestBody({required this.clientId});

  factory V1AdminDeleteOauthClientPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminDeleteOauthClientPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1AdminDeleteOauthClientPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminDeleteOauthClientPost$RequestBodyToJson(this);

  @JsonKey(name: 'client_id', includeIfNull: false)
  final String clientId;
  static const fromJsonFactory =
      _$V1AdminDeleteOauthClientPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminDeleteOauthClientPost$RequestBody &&
            (identical(other.clientId, clientId) ||
                const DeepCollectionEquality().equals(
                  other.clientId,
                  clientId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(clientId) ^ runtimeType.hashCode;
}

extension $V1AdminDeleteOauthClientPost$RequestBodyExtension
    on V1AdminDeleteOauthClientPost$RequestBody {
  V1AdminDeleteOauthClientPost$RequestBody copyWith({String? clientId}) {
    return V1AdminDeleteOauthClientPost$RequestBody(
      clientId: clientId ?? this.clientId,
    );
  }

  V1AdminDeleteOauthClientPost$RequestBody copyWithWrapped({
    Wrapped<String>? clientId,
  }) {
    return V1AdminDeleteOauthClientPost$RequestBody(
      clientId: (clientId != null ? clientId.value : this.clientId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminUpdateUserPost$RequestBody {
  const V1AdminUpdateUserPost$RequestBody({
    required this.userId,
    this.role,
    this.data,
  });

  factory V1AdminUpdateUserPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminUpdateUserPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1AdminUpdateUserPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminUpdateUserPost$RequestBodyToJson(this);

  @JsonKey(name: 'user_id', includeIfNull: false)
  final String userId;
  @JsonKey(name: 'role', includeIfNull: false)
  final dynamic role;
  @JsonKey(name: 'data', includeIfNull: false)
  final Map<String, dynamic>? data;
  static const fromJsonFactory = _$V1AdminUpdateUserPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminUpdateUserPost$RequestBody &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(data) ^
      runtimeType.hashCode;
}

extension $V1AdminUpdateUserPost$RequestBodyExtension
    on V1AdminUpdateUserPost$RequestBody {
  V1AdminUpdateUserPost$RequestBody copyWith({
    String? userId,
    dynamic role,
    Map<String, dynamic>? data,
  }) {
    return V1AdminUpdateUserPost$RequestBody(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      data: data ?? this.data,
    );
  }

  V1AdminUpdateUserPost$RequestBody copyWithWrapped({
    Wrapped<String>? userId,
    Wrapped<dynamic>? role,
    Wrapped<Map<String, dynamic>?>? data,
  }) {
    return V1AdminUpdateUserPost$RequestBody(
      userId: (userId != null ? userId.value : this.userId),
      role: (role != null ? role.value : this.role),
      data: (data != null ? data.value : this.data),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminUpdateOauthClientPost$RequestBody {
  const V1AdminUpdateOauthClientPost$RequestBody({
    required this.clientId,
    this.redirectUris,
    this.scope,
    this.clientName,
    this.clientUri,
    this.logoUri,
    this.contacts,
    this.tosUri,
    this.policyUri,
    this.softwareId,
    this.softwareVersion,
    this.softwareStatement,
    this.postLogoutRedirectUris,
    this.grantTypes,
    this.responseTypes,
    this.type,
    this.clientSecretExpiresAt,
    this.skipConsent,
    this.enableEndSession,
    this.metadata,
  });

  factory V1AdminUpdateOauthClientPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminUpdateOauthClientPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1AdminUpdateOauthClientPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminUpdateOauthClientPost$RequestBodyToJson(this);

  @JsonKey(name: 'client_id', includeIfNull: false)
  final String clientId;
  @JsonKey(
    name: 'redirect_uris',
    includeIfNull: false,
    defaultValue: <String>[],
  )
  final List<String>? redirectUris;
  @JsonKey(name: 'scope', includeIfNull: false)
  final String? scope;
  @JsonKey(name: 'client_name', includeIfNull: false)
  final String? clientName;
  @JsonKey(name: 'client_uri', includeIfNull: false)
  final String? clientUri;
  @JsonKey(name: 'logo_uri', includeIfNull: false)
  final String? logoUri;
  @JsonKey(name: 'contacts', includeIfNull: false, defaultValue: <String>[])
  final List<String>? contacts;
  @JsonKey(name: 'tos_uri', includeIfNull: false)
  final String? tosUri;
  @JsonKey(name: 'policy_uri', includeIfNull: false)
  final String? policyUri;
  @JsonKey(name: 'software_id', includeIfNull: false)
  final String? softwareId;
  @JsonKey(name: 'software_version', includeIfNull: false)
  final String? softwareVersion;
  @JsonKey(name: 'software_statement', includeIfNull: false)
  final String? softwareStatement;
  @JsonKey(
    name: 'post_logout_redirect_uris',
    includeIfNull: false,
    defaultValue: <String>[],
  )
  final List<String>? postLogoutRedirectUris;
  @JsonKey(
    name: 'grant_types',
    includeIfNull: false,
    toJson: v1AdminUpdateOauthClientPost$RequestBodyGrantTypesListToJson,
    fromJson: v1AdminUpdateOauthClientPost$RequestBodyGrantTypesListFromJson,
  )
  final List<enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes>?
  grantTypes;
  @JsonKey(
    name: 'response_types',
    includeIfNull: false,
    toJson: v1AdminUpdateOauthClientPost$RequestBodyResponseTypesListToJson,
    fromJson: v1AdminUpdateOauthClientPost$RequestBodyResponseTypesListFromJson,
  )
  final List<enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes>?
  responseTypes;
  @JsonKey(
    name: 'type',
    includeIfNull: false,
    toJson: v1AdminUpdateOauthClientPost$RequestBodyTypeNullableToJson,
    fromJson: v1AdminUpdateOauthClientPost$RequestBodyTypeNullableFromJson,
  )
  final enums.V1AdminUpdateOauthClientPost$RequestBodyType? type;
  @JsonKey(name: 'client_secret_expires_at', includeIfNull: false)
  final dynamic clientSecretExpiresAt;
  @JsonKey(name: 'skip_consent', includeIfNull: false)
  final bool? skipConsent;
  @JsonKey(name: 'enable_end_session', includeIfNull: false)
  final bool? enableEndSession;
  @JsonKey(name: 'metadata', includeIfNull: false)
  final Map<String, dynamic>? metadata;
  static const fromJsonFactory =
      _$V1AdminUpdateOauthClientPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminUpdateOauthClientPost$RequestBody &&
            (identical(other.clientId, clientId) ||
                const DeepCollectionEquality().equals(
                  other.clientId,
                  clientId,
                )) &&
            (identical(other.redirectUris, redirectUris) ||
                const DeepCollectionEquality().equals(
                  other.redirectUris,
                  redirectUris,
                )) &&
            (identical(other.scope, scope) ||
                const DeepCollectionEquality().equals(other.scope, scope)) &&
            (identical(other.clientName, clientName) ||
                const DeepCollectionEquality().equals(
                  other.clientName,
                  clientName,
                )) &&
            (identical(other.clientUri, clientUri) ||
                const DeepCollectionEquality().equals(
                  other.clientUri,
                  clientUri,
                )) &&
            (identical(other.logoUri, logoUri) ||
                const DeepCollectionEquality().equals(
                  other.logoUri,
                  logoUri,
                )) &&
            (identical(other.contacts, contacts) ||
                const DeepCollectionEquality().equals(
                  other.contacts,
                  contacts,
                )) &&
            (identical(other.tosUri, tosUri) ||
                const DeepCollectionEquality().equals(other.tosUri, tosUri)) &&
            (identical(other.policyUri, policyUri) ||
                const DeepCollectionEquality().equals(
                  other.policyUri,
                  policyUri,
                )) &&
            (identical(other.softwareId, softwareId) ||
                const DeepCollectionEquality().equals(
                  other.softwareId,
                  softwareId,
                )) &&
            (identical(other.softwareVersion, softwareVersion) ||
                const DeepCollectionEquality().equals(
                  other.softwareVersion,
                  softwareVersion,
                )) &&
            (identical(other.softwareStatement, softwareStatement) ||
                const DeepCollectionEquality().equals(
                  other.softwareStatement,
                  softwareStatement,
                )) &&
            (identical(other.postLogoutRedirectUris, postLogoutRedirectUris) ||
                const DeepCollectionEquality().equals(
                  other.postLogoutRedirectUris,
                  postLogoutRedirectUris,
                )) &&
            (identical(other.grantTypes, grantTypes) ||
                const DeepCollectionEquality().equals(
                  other.grantTypes,
                  grantTypes,
                )) &&
            (identical(other.responseTypes, responseTypes) ||
                const DeepCollectionEquality().equals(
                  other.responseTypes,
                  responseTypes,
                )) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.clientSecretExpiresAt, clientSecretExpiresAt) ||
                const DeepCollectionEquality().equals(
                  other.clientSecretExpiresAt,
                  clientSecretExpiresAt,
                )) &&
            (identical(other.skipConsent, skipConsent) ||
                const DeepCollectionEquality().equals(
                  other.skipConsent,
                  skipConsent,
                )) &&
            (identical(other.enableEndSession, enableEndSession) ||
                const DeepCollectionEquality().equals(
                  other.enableEndSession,
                  enableEndSession,
                )) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality().equals(
                  other.metadata,
                  metadata,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(clientId) ^
      const DeepCollectionEquality().hash(redirectUris) ^
      const DeepCollectionEquality().hash(scope) ^
      const DeepCollectionEquality().hash(clientName) ^
      const DeepCollectionEquality().hash(clientUri) ^
      const DeepCollectionEquality().hash(logoUri) ^
      const DeepCollectionEquality().hash(contacts) ^
      const DeepCollectionEquality().hash(tosUri) ^
      const DeepCollectionEquality().hash(policyUri) ^
      const DeepCollectionEquality().hash(softwareId) ^
      const DeepCollectionEquality().hash(softwareVersion) ^
      const DeepCollectionEquality().hash(softwareStatement) ^
      const DeepCollectionEquality().hash(postLogoutRedirectUris) ^
      const DeepCollectionEquality().hash(grantTypes) ^
      const DeepCollectionEquality().hash(responseTypes) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(clientSecretExpiresAt) ^
      const DeepCollectionEquality().hash(skipConsent) ^
      const DeepCollectionEquality().hash(enableEndSession) ^
      const DeepCollectionEquality().hash(metadata) ^
      runtimeType.hashCode;
}

extension $V1AdminUpdateOauthClientPost$RequestBodyExtension
    on V1AdminUpdateOauthClientPost$RequestBody {
  V1AdminUpdateOauthClientPost$RequestBody copyWith({
    String? clientId,
    List<String>? redirectUris,
    String? scope,
    String? clientName,
    String? clientUri,
    String? logoUri,
    List<String>? contacts,
    String? tosUri,
    String? policyUri,
    String? softwareId,
    String? softwareVersion,
    String? softwareStatement,
    List<String>? postLogoutRedirectUris,
    List<enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes>? grantTypes,
    List<enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes>?
    responseTypes,
    enums.V1AdminUpdateOauthClientPost$RequestBodyType? type,
    dynamic clientSecretExpiresAt,
    bool? skipConsent,
    bool? enableEndSession,
    Map<String, dynamic>? metadata,
  }) {
    return V1AdminUpdateOauthClientPost$RequestBody(
      clientId: clientId ?? this.clientId,
      redirectUris: redirectUris ?? this.redirectUris,
      scope: scope ?? this.scope,
      clientName: clientName ?? this.clientName,
      clientUri: clientUri ?? this.clientUri,
      logoUri: logoUri ?? this.logoUri,
      contacts: contacts ?? this.contacts,
      tosUri: tosUri ?? this.tosUri,
      policyUri: policyUri ?? this.policyUri,
      softwareId: softwareId ?? this.softwareId,
      softwareVersion: softwareVersion ?? this.softwareVersion,
      softwareStatement: softwareStatement ?? this.softwareStatement,
      postLogoutRedirectUris:
          postLogoutRedirectUris ?? this.postLogoutRedirectUris,
      grantTypes: grantTypes ?? this.grantTypes,
      responseTypes: responseTypes ?? this.responseTypes,
      type: type ?? this.type,
      clientSecretExpiresAt:
          clientSecretExpiresAt ?? this.clientSecretExpiresAt,
      skipConsent: skipConsent ?? this.skipConsent,
      enableEndSession: enableEndSession ?? this.enableEndSession,
      metadata: metadata ?? this.metadata,
    );
  }

  V1AdminUpdateOauthClientPost$RequestBody copyWithWrapped({
    Wrapped<String>? clientId,
    Wrapped<List<String>?>? redirectUris,
    Wrapped<String?>? scope,
    Wrapped<String?>? clientName,
    Wrapped<String?>? clientUri,
    Wrapped<String?>? logoUri,
    Wrapped<List<String>?>? contacts,
    Wrapped<String?>? tosUri,
    Wrapped<String?>? policyUri,
    Wrapped<String?>? softwareId,
    Wrapped<String?>? softwareVersion,
    Wrapped<String?>? softwareStatement,
    Wrapped<List<String>?>? postLogoutRedirectUris,
    Wrapped<List<enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes>?>?
    grantTypes,
    Wrapped<List<enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes>?>?
    responseTypes,
    Wrapped<enums.V1AdminUpdateOauthClientPost$RequestBodyType?>? type,
    Wrapped<dynamic>? clientSecretExpiresAt,
    Wrapped<bool?>? skipConsent,
    Wrapped<bool?>? enableEndSession,
    Wrapped<Map<String, dynamic>?>? metadata,
  }) {
    return V1AdminUpdateOauthClientPost$RequestBody(
      clientId: (clientId != null ? clientId.value : this.clientId),
      redirectUris: (redirectUris != null
          ? redirectUris.value
          : this.redirectUris),
      scope: (scope != null ? scope.value : this.scope),
      clientName: (clientName != null ? clientName.value : this.clientName),
      clientUri: (clientUri != null ? clientUri.value : this.clientUri),
      logoUri: (logoUri != null ? logoUri.value : this.logoUri),
      contacts: (contacts != null ? contacts.value : this.contacts),
      tosUri: (tosUri != null ? tosUri.value : this.tosUri),
      policyUri: (policyUri != null ? policyUri.value : this.policyUri),
      softwareId: (softwareId != null ? softwareId.value : this.softwareId),
      softwareVersion: (softwareVersion != null
          ? softwareVersion.value
          : this.softwareVersion),
      softwareStatement: (softwareStatement != null
          ? softwareStatement.value
          : this.softwareStatement),
      postLogoutRedirectUris: (postLogoutRedirectUris != null
          ? postLogoutRedirectUris.value
          : this.postLogoutRedirectUris),
      grantTypes: (grantTypes != null ? grantTypes.value : this.grantTypes),
      responseTypes: (responseTypes != null
          ? responseTypes.value
          : this.responseTypes),
      type: (type != null ? type.value : this.type),
      clientSecretExpiresAt: (clientSecretExpiresAt != null
          ? clientSecretExpiresAt.value
          : this.clientSecretExpiresAt),
      skipConsent: (skipConsent != null ? skipConsent.value : this.skipConsent),
      enableEndSession: (enableEndSession != null
          ? enableEndSession.value
          : this.enableEndSession),
      metadata: (metadata != null ? metadata.value : this.metadata),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserConfirmMailPost$RequestBody {
  const V1UserConfirmMailPost$RequestBody({required this.token});

  factory V1UserConfirmMailPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserConfirmMailPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1UserConfirmMailPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserConfirmMailPost$RequestBodyToJson(this);

  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  static const fromJsonFactory = _$V1UserConfirmMailPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserConfirmMailPost$RequestBody &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(token) ^ runtimeType.hashCode;
}

extension $V1UserConfirmMailPost$RequestBodyExtension
    on V1UserConfirmMailPost$RequestBody {
  V1UserConfirmMailPost$RequestBody copyWith({String? token}) {
    return V1UserConfirmMailPost$RequestBody(token: token ?? this.token);
  }

  V1UserConfirmMailPost$RequestBody copyWithWrapped({Wrapped<String>? token}) {
    return V1UserConfirmMailPost$RequestBody(
      token: (token != null ? token.value : this.token),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserRequestPasswordResetPost$RequestBody {
  const V1UserRequestPasswordResetPost$RequestBody({required this.email});

  factory V1UserRequestPasswordResetPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserRequestPasswordResetPost$RequestBodyFromJson(json);

  static const toJsonFactory =
      _$V1UserRequestPasswordResetPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserRequestPasswordResetPost$RequestBodyToJson(this);

  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  static const fromJsonFactory =
      _$V1UserRequestPasswordResetPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserRequestPasswordResetPost$RequestBody &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^ runtimeType.hashCode;
}

extension $V1UserRequestPasswordResetPost$RequestBodyExtension
    on V1UserRequestPasswordResetPost$RequestBody {
  V1UserRequestPasswordResetPost$RequestBody copyWith({String? email}) {
    return V1UserRequestPasswordResetPost$RequestBody(
      email: email ?? this.email,
    );
  }

  V1UserRequestPasswordResetPost$RequestBody copyWithWrapped({
    Wrapped<String>? email,
  }) {
    return V1UserRequestPasswordResetPost$RequestBody(
      email: (email != null ? email.value : this.email),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserResetPasswordPost$RequestBody {
  const V1UserResetPasswordPost$RequestBody({
    required this.token,
    required this.newPassword,
  });

  factory V1UserResetPasswordPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserResetPasswordPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1UserResetPasswordPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserResetPasswordPost$RequestBodyToJson(this);

  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  @JsonKey(name: 'new_password', includeIfNull: false)
  final String newPassword;
  static const fromJsonFactory = _$V1UserResetPasswordPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserResetPasswordPost$RequestBody &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)) &&
            (identical(other.newPassword, newPassword) ||
                const DeepCollectionEquality().equals(
                  other.newPassword,
                  newPassword,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(token) ^
      const DeepCollectionEquality().hash(newPassword) ^
      runtimeType.hashCode;
}

extension $V1UserResetPasswordPost$RequestBodyExtension
    on V1UserResetPasswordPost$RequestBody {
  V1UserResetPasswordPost$RequestBody copyWith({
    String? token,
    String? newPassword,
  }) {
    return V1UserResetPasswordPost$RequestBody(
      token: token ?? this.token,
      newPassword: newPassword ?? this.newPassword,
    );
  }

  V1UserResetPasswordPost$RequestBody copyWithWrapped({
    Wrapped<String>? token,
    Wrapped<String>? newPassword,
  }) {
    return V1UserResetPasswordPost$RequestBody(
      token: (token != null ? token.value : this.token),
      newPassword: (newPassword != null ? newPassword.value : this.newPassword),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInEmailPost$RequestBody {
  const V1UserSignInEmailPost$RequestBody({
    required this.email,
    required this.password,
  });

  factory V1UserSignInEmailPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserSignInEmailPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1UserSignInEmailPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserSignInEmailPost$RequestBodyToJson(this);

  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'password', includeIfNull: false)
  final String password;
  static const fromJsonFactory = _$V1UserSignInEmailPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInEmailPost$RequestBody &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality().equals(
                  other.password,
                  password,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(password) ^
      runtimeType.hashCode;
}

extension $V1UserSignInEmailPost$RequestBodyExtension
    on V1UserSignInEmailPost$RequestBody {
  V1UserSignInEmailPost$RequestBody copyWith({
    String? email,
    String? password,
  }) {
    return V1UserSignInEmailPost$RequestBody(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  V1UserSignInEmailPost$RequestBody copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String>? password,
  }) {
    return V1UserSignInEmailPost$RequestBody(
      email: (email != null ? email.value : this.email),
      password: (password != null ? password.value : this.password),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInSsoPost$RequestBody {
  const V1UserSignInSsoPost$RequestBody({
    required this.providerId,
    required this.successUrl,
  });

  factory V1UserSignInSsoPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$V1UserSignInSsoPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1UserSignInSsoPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserSignInSsoPost$RequestBodyToJson(this);

  @JsonKey(name: 'provider_id', includeIfNull: false)
  final String providerId;
  @JsonKey(name: 'success_url', includeIfNull: false)
  final String successUrl;
  static const fromJsonFactory = _$V1UserSignInSsoPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInSsoPost$RequestBody &&
            (identical(other.providerId, providerId) ||
                const DeepCollectionEquality().equals(
                  other.providerId,
                  providerId,
                )) &&
            (identical(other.successUrl, successUrl) ||
                const DeepCollectionEquality().equals(
                  other.successUrl,
                  successUrl,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(providerId) ^
      const DeepCollectionEquality().hash(successUrl) ^
      runtimeType.hashCode;
}

extension $V1UserSignInSsoPost$RequestBodyExtension
    on V1UserSignInSsoPost$RequestBody {
  V1UserSignInSsoPost$RequestBody copyWith({
    String? providerId,
    String? successUrl,
  }) {
    return V1UserSignInSsoPost$RequestBody(
      providerId: providerId ?? this.providerId,
      successUrl: successUrl ?? this.successUrl,
    );
  }

  V1UserSignInSsoPost$RequestBody copyWithWrapped({
    Wrapped<String>? providerId,
    Wrapped<String>? successUrl,
  }) {
    return V1UserSignInSsoPost$RequestBody(
      providerId: (providerId != null ? providerId.value : this.providerId),
      successUrl: (successUrl != null ? successUrl.value : this.successUrl),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignUpEmailPost$RequestBody {
  const V1UserSignUpEmailPost$RequestBody({
    required this.name,
    required this.email,
    required this.password,
  });

  factory V1UserSignUpEmailPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserSignUpEmailPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$V1UserSignUpEmailPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserSignUpEmailPost$RequestBodyToJson(this);

  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'password', includeIfNull: false)
  final String password;
  static const fromJsonFactory = _$V1UserSignUpEmailPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignUpEmailPost$RequestBody &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality().equals(
                  other.password,
                  password,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(password) ^
      runtimeType.hashCode;
}

extension $V1UserSignUpEmailPost$RequestBodyExtension
    on V1UserSignUpEmailPost$RequestBody {
  V1UserSignUpEmailPost$RequestBody copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return V1UserSignUpEmailPost$RequestBody(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  V1UserSignUpEmailPost$RequestBody copyWithWrapped({
    Wrapped<String>? name,
    Wrapped<String>? email,
    Wrapped<String>? password,
  }) {
    return V1UserSignUpEmailPost$RequestBody(
      name: (name != null ? name.value : this.name),
      email: (email != null ? email.value : this.email),
      password: (password != null ? password.value : this.password),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminCreateUserPost$Response {
  const V1AdminCreateUserPost$Response({required this.user});

  factory V1AdminCreateUserPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1AdminCreateUserPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1AdminCreateUserPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1AdminCreateUserPost$ResponseToJson(this);

  @JsonKey(name: 'user', includeIfNull: false)
  final V1AdminCreateUserPost$Response$User user;
  static const fromJsonFactory = _$V1AdminCreateUserPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminCreateUserPost$Response &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^ runtimeType.hashCode;
}

extension $V1AdminCreateUserPost$ResponseExtension
    on V1AdminCreateUserPost$Response {
  V1AdminCreateUserPost$Response copyWith({
    V1AdminCreateUserPost$Response$User? user,
  }) {
    return V1AdminCreateUserPost$Response(user: user ?? this.user);
  }

  V1AdminCreateUserPost$Response copyWithWrapped({
    Wrapped<V1AdminCreateUserPost$Response$User>? user,
  }) {
    return V1AdminCreateUserPost$Response(
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminCreateOauthClientPost$Response {
  const V1AdminCreateOauthClientPost$Response({required this.$client});

  factory V1AdminCreateOauthClientPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminCreateOauthClientPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1AdminCreateOauthClientPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminCreateOauthClientPost$ResponseToJson(this);

  @JsonKey(name: 'client', includeIfNull: false)
  final Map<String, dynamic> $client;
  static const fromJsonFactory =
      _$V1AdminCreateOauthClientPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminCreateOauthClientPost$Response &&
            (identical(other.$client, $client) ||
                const DeepCollectionEquality().equals(other.$client, $client)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($client) ^ runtimeType.hashCode;
}

extension $V1AdminCreateOauthClientPost$ResponseExtension
    on V1AdminCreateOauthClientPost$Response {
  V1AdminCreateOauthClientPost$Response copyWith({
    Map<String, dynamic>? $client,
  }) {
    return V1AdminCreateOauthClientPost$Response(
      $client: $client ?? this.$client,
    );
  }

  V1AdminCreateOauthClientPost$Response copyWithWrapped({
    Wrapped<Map<String, dynamic>>? $client,
  }) {
    return V1AdminCreateOauthClientPost$Response(
      $client: ($client != null ? $client.value : this.$client),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminDeleteUserPost$Response {
  const V1AdminDeleteUserPost$Response({
    required this.success,
    required this.userId,
  });

  factory V1AdminDeleteUserPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1AdminDeleteUserPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1AdminDeleteUserPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1AdminDeleteUserPost$ResponseToJson(this);

  @JsonKey(name: 'success', includeIfNull: false)
  final bool success;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String userId;
  static const fromJsonFactory = _$V1AdminDeleteUserPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminDeleteUserPost$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(userId) ^
      runtimeType.hashCode;
}

extension $V1AdminDeleteUserPost$ResponseExtension
    on V1AdminDeleteUserPost$Response {
  V1AdminDeleteUserPost$Response copyWith({bool? success, String? userId}) {
    return V1AdminDeleteUserPost$Response(
      success: success ?? this.success,
      userId: userId ?? this.userId,
    );
  }

  V1AdminDeleteUserPost$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<String>? userId,
  }) {
    return V1AdminDeleteUserPost$Response(
      success: (success != null ? success.value : this.success),
      userId: (userId != null ? userId.value : this.userId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminDeleteOauthClientPost$Response {
  const V1AdminDeleteOauthClientPost$Response({
    required this.success,
    required this.clientId,
  });

  factory V1AdminDeleteOauthClientPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminDeleteOauthClientPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1AdminDeleteOauthClientPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminDeleteOauthClientPost$ResponseToJson(this);

  @JsonKey(name: 'success', includeIfNull: false)
  final bool success;
  @JsonKey(name: 'client_id', includeIfNull: false)
  final String clientId;
  static const fromJsonFactory =
      _$V1AdminDeleteOauthClientPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminDeleteOauthClientPost$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.clientId, clientId) ||
                const DeepCollectionEquality().equals(
                  other.clientId,
                  clientId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(clientId) ^
      runtimeType.hashCode;
}

extension $V1AdminDeleteOauthClientPost$ResponseExtension
    on V1AdminDeleteOauthClientPost$Response {
  V1AdminDeleteOauthClientPost$Response copyWith({
    bool? success,
    String? clientId,
  }) {
    return V1AdminDeleteOauthClientPost$Response(
      success: success ?? this.success,
      clientId: clientId ?? this.clientId,
    );
  }

  V1AdminDeleteOauthClientPost$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<String>? clientId,
  }) {
    return V1AdminDeleteOauthClientPost$Response(
      success: (success != null ? success.value : this.success),
      clientId: (clientId != null ? clientId.value : this.clientId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminUpdateUserPost$Response {
  const V1AdminUpdateUserPost$Response({required this.user});

  factory V1AdminUpdateUserPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1AdminUpdateUserPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1AdminUpdateUserPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1AdminUpdateUserPost$ResponseToJson(this);

  @JsonKey(name: 'user', includeIfNull: false)
  final V1AdminUpdateUserPost$Response$User user;
  static const fromJsonFactory = _$V1AdminUpdateUserPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminUpdateUserPost$Response &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^ runtimeType.hashCode;
}

extension $V1AdminUpdateUserPost$ResponseExtension
    on V1AdminUpdateUserPost$Response {
  V1AdminUpdateUserPost$Response copyWith({
    V1AdminUpdateUserPost$Response$User? user,
  }) {
    return V1AdminUpdateUserPost$Response(user: user ?? this.user);
  }

  V1AdminUpdateUserPost$Response copyWithWrapped({
    Wrapped<V1AdminUpdateUserPost$Response$User>? user,
  }) {
    return V1AdminUpdateUserPost$Response(
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminUpdateOauthClientPost$Response {
  const V1AdminUpdateOauthClientPost$Response({required this.$client});

  factory V1AdminUpdateOauthClientPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminUpdateOauthClientPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1AdminUpdateOauthClientPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminUpdateOauthClientPost$ResponseToJson(this);

  @JsonKey(name: 'client', includeIfNull: false)
  final Map<String, dynamic> $client;
  static const fromJsonFactory =
      _$V1AdminUpdateOauthClientPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminUpdateOauthClientPost$Response &&
            (identical(other.$client, $client) ||
                const DeepCollectionEquality().equals(other.$client, $client)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash($client) ^ runtimeType.hashCode;
}

extension $V1AdminUpdateOauthClientPost$ResponseExtension
    on V1AdminUpdateOauthClientPost$Response {
  V1AdminUpdateOauthClientPost$Response copyWith({
    Map<String, dynamic>? $client,
  }) {
    return V1AdminUpdateOauthClientPost$Response(
      $client: $client ?? this.$client,
    );
  }

  V1AdminUpdateOauthClientPost$Response copyWithWrapped({
    Wrapped<Map<String, dynamic>>? $client,
  }) {
    return V1AdminUpdateOauthClientPost$Response(
      $client: ($client != null ? $client.value : this.$client),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminListUsersGet$Response {
  const V1AdminListUsersGet$Response({
    required this.users,
    required this.total,
    required this.limit,
    required this.offset,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory V1AdminListUsersGet$Response.fromJson(Map<String, dynamic> json) =>
      _$V1AdminListUsersGet$ResponseFromJson(json);

  static const toJsonFactory = _$V1AdminListUsersGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1AdminListUsersGet$ResponseToJson(this);

  @JsonKey(name: 'users', includeIfNull: false)
  final List<V1AdminListUsersGet$Response$Users$Item> users;
  @JsonKey(name: 'total', includeIfNull: false)
  final double total;
  @JsonKey(name: 'limit', includeIfNull: false)
  final int limit;
  @JsonKey(name: 'offset', includeIfNull: false)
  final int offset;
  @JsonKey(name: 'page', includeIfNull: false)
  final int page;
  @JsonKey(name: 'page_size', includeIfNull: false)
  final int pageSize;
  @JsonKey(name: 'total_pages', includeIfNull: false)
  final int totalPages;
  static const fromJsonFactory = _$V1AdminListUsersGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminListUsersGet$Response &&
            (identical(other.users, users) ||
                const DeepCollectionEquality().equals(other.users, users)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.page, page) ||
                const DeepCollectionEquality().equals(other.page, page)) &&
            (identical(other.pageSize, pageSize) ||
                const DeepCollectionEquality().equals(
                  other.pageSize,
                  pageSize,
                )) &&
            (identical(other.totalPages, totalPages) ||
                const DeepCollectionEquality().equals(
                  other.totalPages,
                  totalPages,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(users) ^
      const DeepCollectionEquality().hash(total) ^
      const DeepCollectionEquality().hash(limit) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(page) ^
      const DeepCollectionEquality().hash(pageSize) ^
      const DeepCollectionEquality().hash(totalPages) ^
      runtimeType.hashCode;
}

extension $V1AdminListUsersGet$ResponseExtension
    on V1AdminListUsersGet$Response {
  V1AdminListUsersGet$Response copyWith({
    List<V1AdminListUsersGet$Response$Users$Item>? users,
    double? total,
    int? limit,
    int? offset,
    int? page,
    int? pageSize,
    int? totalPages,
  }) {
    return V1AdminListUsersGet$Response(
      users: users ?? this.users,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  V1AdminListUsersGet$Response copyWithWrapped({
    Wrapped<List<V1AdminListUsersGet$Response$Users$Item>>? users,
    Wrapped<double>? total,
    Wrapped<int>? limit,
    Wrapped<int>? offset,
    Wrapped<int>? page,
    Wrapped<int>? pageSize,
    Wrapped<int>? totalPages,
  }) {
    return V1AdminListUsersGet$Response(
      users: (users != null ? users.value : this.users),
      total: (total != null ? total.value : this.total),
      limit: (limit != null ? limit.value : this.limit),
      offset: (offset != null ? offset.value : this.offset),
      page: (page != null ? page.value : this.page),
      pageSize: (pageSize != null ? pageSize.value : this.pageSize),
      totalPages: (totalPages != null ? totalPages.value : this.totalPages),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminListOauthClientsGet$Response {
  const V1AdminListOauthClientsGet$Response({required this.clients});

  factory V1AdminListOauthClientsGet$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminListOauthClientsGet$ResponseFromJson(json);

  static const toJsonFactory = _$V1AdminListOauthClientsGet$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminListOauthClientsGet$ResponseToJson(this);

  @JsonKey(name: 'clients', includeIfNull: false)
  final List<V1AdminListOauthClientsGet$Response$Clients$Item> clients;
  static const fromJsonFactory = _$V1AdminListOauthClientsGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminListOauthClientsGet$Response &&
            (identical(other.clients, clients) ||
                const DeepCollectionEquality().equals(other.clients, clients)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(clients) ^ runtimeType.hashCode;
}

extension $V1AdminListOauthClientsGet$ResponseExtension
    on V1AdminListOauthClientsGet$Response {
  V1AdminListOauthClientsGet$Response copyWith({
    List<V1AdminListOauthClientsGet$Response$Clients$Item>? clients,
  }) {
    return V1AdminListOauthClientsGet$Response(
      clients: clients ?? this.clients,
    );
  }

  V1AdminListOauthClientsGet$Response copyWithWrapped({
    Wrapped<List<V1AdminListOauthClientsGet$Response$Clients$Item>>? clients,
  }) {
    return V1AdminListOauthClientsGet$Response(
      clients: (clients != null ? clients.value : this.clients),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserInfoGet$Response {
  const V1UserInfoGet$Response({
    required this.emailSignInEnabled,
    required this.emailSignUpEnabled,
    required this.ssoProviders,
  });

  factory V1UserInfoGet$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserInfoGet$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserInfoGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserInfoGet$ResponseToJson(this);

  @JsonKey(name: 'email_sign_in_enabled', includeIfNull: false)
  final bool emailSignInEnabled;
  @JsonKey(name: 'email_sign_up_enabled', includeIfNull: false)
  final bool emailSignUpEnabled;
  @JsonKey(name: 'sso_providers', includeIfNull: false)
  final List<V1UserInfoGet$Response$SsoProviders$Item> ssoProviders;
  static const fromJsonFactory = _$V1UserInfoGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserInfoGet$Response &&
            (identical(other.emailSignInEnabled, emailSignInEnabled) ||
                const DeepCollectionEquality().equals(
                  other.emailSignInEnabled,
                  emailSignInEnabled,
                )) &&
            (identical(other.emailSignUpEnabled, emailSignUpEnabled) ||
                const DeepCollectionEquality().equals(
                  other.emailSignUpEnabled,
                  emailSignUpEnabled,
                )) &&
            (identical(other.ssoProviders, ssoProviders) ||
                const DeepCollectionEquality().equals(
                  other.ssoProviders,
                  ssoProviders,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(emailSignInEnabled) ^
      const DeepCollectionEquality().hash(emailSignUpEnabled) ^
      const DeepCollectionEquality().hash(ssoProviders) ^
      runtimeType.hashCode;
}

extension $V1UserInfoGet$ResponseExtension on V1UserInfoGet$Response {
  V1UserInfoGet$Response copyWith({
    bool? emailSignInEnabled,
    bool? emailSignUpEnabled,
    List<V1UserInfoGet$Response$SsoProviders$Item>? ssoProviders,
  }) {
    return V1UserInfoGet$Response(
      emailSignInEnabled: emailSignInEnabled ?? this.emailSignInEnabled,
      emailSignUpEnabled: emailSignUpEnabled ?? this.emailSignUpEnabled,
      ssoProviders: ssoProviders ?? this.ssoProviders,
    );
  }

  V1UserInfoGet$Response copyWithWrapped({
    Wrapped<bool>? emailSignInEnabled,
    Wrapped<bool>? emailSignUpEnabled,
    Wrapped<List<V1UserInfoGet$Response$SsoProviders$Item>>? ssoProviders,
  }) {
    return V1UserInfoGet$Response(
      emailSignInEnabled: (emailSignInEnabled != null
          ? emailSignInEnabled.value
          : this.emailSignInEnabled),
      emailSignUpEnabled: (emailSignUpEnabled != null
          ? emailSignUpEnabled.value
          : this.emailSignUpEnabled),
      ssoProviders: (ssoProviders != null
          ? ssoProviders.value
          : this.ssoProviders),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserGetUserGet$Response {
  const V1UserGetUserGet$Response({required this.user});

  factory V1UserGetUserGet$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserGetUserGet$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserGetUserGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserGetUserGet$ResponseToJson(this);

  @JsonKey(name: 'user', includeIfNull: false)
  final V1UserGetUserGet$Response$User user;
  static const fromJsonFactory = _$V1UserGetUserGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserGetUserGet$Response &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^ runtimeType.hashCode;
}

extension $V1UserGetUserGet$ResponseExtension on V1UserGetUserGet$Response {
  V1UserGetUserGet$Response copyWith({V1UserGetUserGet$Response$User? user}) {
    return V1UserGetUserGet$Response(user: user ?? this.user);
  }

  V1UserGetUserGet$Response copyWithWrapped({
    Wrapped<V1UserGetUserGet$Response$User>? user,
  }) {
    return V1UserGetUserGet$Response(
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserLogoutGet$Response {
  const V1UserLogoutGet$Response({required this.user});

  factory V1UserLogoutGet$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserLogoutGet$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserLogoutGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserLogoutGet$ResponseToJson(this);

  @JsonKey(name: 'user', includeIfNull: false)
  final dynamic user;
  static const fromJsonFactory = _$V1UserLogoutGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserLogoutGet$Response &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(user) ^ runtimeType.hashCode;
}

extension $V1UserLogoutGet$ResponseExtension on V1UserLogoutGet$Response {
  V1UserLogoutGet$Response copyWith({dynamic user}) {
    return V1UserLogoutGet$Response(user: user ?? this.user);
  }

  V1UserLogoutGet$Response copyWithWrapped({Wrapped<dynamic>? user}) {
    return V1UserLogoutGet$Response(
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserRefreshSessionPost$Response {
  const V1UserRefreshSessionPost$Response({required this.expiresAt});

  factory V1UserRefreshSessionPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserRefreshSessionPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserRefreshSessionPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserRefreshSessionPost$ResponseToJson(this);

  @JsonKey(name: 'expires_at', includeIfNull: false)
  final DateTime? expiresAt;
  static const fromJsonFactory = _$V1UserRefreshSessionPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserRefreshSessionPost$Response &&
            (identical(other.expiresAt, expiresAt) ||
                const DeepCollectionEquality().equals(
                  other.expiresAt,
                  expiresAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(expiresAt) ^ runtimeType.hashCode;
}

extension $V1UserRefreshSessionPost$ResponseExtension
    on V1UserRefreshSessionPost$Response {
  V1UserRefreshSessionPost$Response copyWith({DateTime? expiresAt}) {
    return V1UserRefreshSessionPost$Response(
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  V1UserRefreshSessionPost$Response copyWithWrapped({
    Wrapped<DateTime?>? expiresAt,
  }) {
    return V1UserRefreshSessionPost$Response(
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInEmailPost$Response {
  const V1UserSignInEmailPost$Response({
    required this.sessionId,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory V1UserSignInEmailPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserSignInEmailPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserSignInEmailPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserSignInEmailPost$ResponseToJson(this);

  @JsonKey(name: 'session_id', includeIfNull: false)
  final String sessionId;
  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  @JsonKey(name: 'expires_at', includeIfNull: false)
  final DateTime expiresAt;
  @JsonKey(name: 'user', includeIfNull: false)
  final V1UserSignInEmailPost$Response$User user;
  static const fromJsonFactory = _$V1UserSignInEmailPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInEmailPost$Response &&
            (identical(other.sessionId, sessionId) ||
                const DeepCollectionEquality().equals(
                  other.sessionId,
                  sessionId,
                )) &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)) &&
            (identical(other.expiresAt, expiresAt) ||
                const DeepCollectionEquality().equals(
                  other.expiresAt,
                  expiresAt,
                )) &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(sessionId) ^
      const DeepCollectionEquality().hash(token) ^
      const DeepCollectionEquality().hash(expiresAt) ^
      const DeepCollectionEquality().hash(user) ^
      runtimeType.hashCode;
}

extension $V1UserSignInEmailPost$ResponseExtension
    on V1UserSignInEmailPost$Response {
  V1UserSignInEmailPost$Response copyWith({
    String? sessionId,
    String? token,
    DateTime? expiresAt,
    V1UserSignInEmailPost$Response$User? user,
  }) {
    return V1UserSignInEmailPost$Response(
      sessionId: sessionId ?? this.sessionId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }

  V1UserSignInEmailPost$Response copyWithWrapped({
    Wrapped<String>? sessionId,
    Wrapped<String>? token,
    Wrapped<DateTime>? expiresAt,
    Wrapped<V1UserSignInEmailPost$Response$User>? user,
  }) {
    return V1UserSignInEmailPost$Response(
      sessionId: (sessionId != null ? sessionId.value : this.sessionId),
      token: (token != null ? token.value : this.token),
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInSsoPost$Response {
  const V1UserSignInSsoPost$Response({
    required this.success,
    required this.data,
  });

  factory V1UserSignInSsoPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserSignInSsoPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserSignInSsoPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserSignInSsoPost$ResponseToJson(this);

  @JsonKey(name: 'success', includeIfNull: false)
  final bool success;
  @JsonKey(name: 'data', includeIfNull: false)
  final V1UserSignInSsoPost$Response$Data data;
  static const fromJsonFactory = _$V1UserSignInSsoPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInSsoPost$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(data) ^
      runtimeType.hashCode;
}

extension $V1UserSignInSsoPost$ResponseExtension
    on V1UserSignInSsoPost$Response {
  V1UserSignInSsoPost$Response copyWith({
    bool? success,
    V1UserSignInSsoPost$Response$Data? data,
  }) {
    return V1UserSignInSsoPost$Response(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  V1UserSignInSsoPost$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<V1UserSignInSsoPost$Response$Data>? data,
  }) {
    return V1UserSignInSsoPost$Response(
      success: (success != null ? success.value : this.success),
      data: (data != null ? data.value : this.data),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignUpEmailPost$Response {
  const V1UserSignUpEmailPost$Response({
    required this.sessionId,
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory V1UserSignUpEmailPost$Response.fromJson(Map<String, dynamic> json) =>
      _$V1UserSignUpEmailPost$ResponseFromJson(json);

  static const toJsonFactory = _$V1UserSignUpEmailPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$V1UserSignUpEmailPost$ResponseToJson(this);

  @JsonKey(name: 'session_id', includeIfNull: false)
  final String sessionId;
  @JsonKey(name: 'token', includeIfNull: false)
  final String token;
  @JsonKey(name: 'expires_at', includeIfNull: false)
  final DateTime expiresAt;
  @JsonKey(name: 'user', includeIfNull: false)
  final V1UserSignUpEmailPost$Response$User user;
  static const fromJsonFactory = _$V1UserSignUpEmailPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignUpEmailPost$Response &&
            (identical(other.sessionId, sessionId) ||
                const DeepCollectionEquality().equals(
                  other.sessionId,
                  sessionId,
                )) &&
            (identical(other.token, token) ||
                const DeepCollectionEquality().equals(other.token, token)) &&
            (identical(other.expiresAt, expiresAt) ||
                const DeepCollectionEquality().equals(
                  other.expiresAt,
                  expiresAt,
                )) &&
            (identical(other.user, user) ||
                const DeepCollectionEquality().equals(other.user, user)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(sessionId) ^
      const DeepCollectionEquality().hash(token) ^
      const DeepCollectionEquality().hash(expiresAt) ^
      const DeepCollectionEquality().hash(user) ^
      runtimeType.hashCode;
}

extension $V1UserSignUpEmailPost$ResponseExtension
    on V1UserSignUpEmailPost$Response {
  V1UserSignUpEmailPost$Response copyWith({
    String? sessionId,
    String? token,
    DateTime? expiresAt,
    V1UserSignUpEmailPost$Response$User? user,
  }) {
    return V1UserSignUpEmailPost$Response(
      sessionId: sessionId ?? this.sessionId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }

  V1UserSignUpEmailPost$Response copyWithWrapped({
    Wrapped<String>? sessionId,
    Wrapped<String>? token,
    Wrapped<DateTime>? expiresAt,
    Wrapped<V1UserSignUpEmailPost$Response$User>? user,
  }) {
    return V1UserSignUpEmailPost$Response(
      sessionId: (sessionId != null ? sessionId.value : this.sessionId),
      token: (token != null ? token.value : this.token),
      expiresAt: (expiresAt != null ? expiresAt.value : this.expiresAt),
      user: (user != null ? user.value : this.user),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class HippoAuthErrorResponse$Error {
  const HippoAuthErrorResponse$Error({
    required this.code,
    required this.message,
    this.details,
  });

  factory HippoAuthErrorResponse$Error.fromJson(Map<String, dynamic> json) =>
      _$HippoAuthErrorResponse$ErrorFromJson(json);

  static const toJsonFactory = _$HippoAuthErrorResponse$ErrorToJson;
  Map<String, dynamic> toJson() => _$HippoAuthErrorResponse$ErrorToJson(this);

  @JsonKey(name: 'code', includeIfNull: false)
  final String code;
  @JsonKey(name: 'message', includeIfNull: false)
  final String message;
  @JsonKey(name: 'details', includeIfNull: false)
  final Map<String, dynamic>? details;
  static const fromJsonFactory = _$HippoAuthErrorResponse$ErrorFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HippoAuthErrorResponse$Error &&
            (identical(other.code, code) ||
                const DeepCollectionEquality().equals(other.code, code)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.details, details) ||
                const DeepCollectionEquality().equals(other.details, details)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(code) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(details) ^
      runtimeType.hashCode;
}

extension $HippoAuthErrorResponse$ErrorExtension
    on HippoAuthErrorResponse$Error {
  HippoAuthErrorResponse$Error copyWith({
    String? code,
    String? message,
    Map<String, dynamic>? details,
  }) {
    return HippoAuthErrorResponse$Error(
      code: code ?? this.code,
      message: message ?? this.message,
      details: details ?? this.details,
    );
  }

  HippoAuthErrorResponse$Error copyWithWrapped({
    Wrapped<String>? code,
    Wrapped<String>? message,
    Wrapped<Map<String, dynamic>?>? details,
  }) {
    return HippoAuthErrorResponse$Error(
      code: (code != null ? code.value : this.code),
      message: (message != null ? message.value : this.message),
      details: (details != null ? details.value : this.details),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminCreateUserPost$Response$User {
  const V1AdminCreateUserPost$Response$User({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.name,
    this.image,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory V1AdminCreateUserPost$Response$User.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminCreateUserPost$Response$UserFromJson(json);

  static const toJsonFactory = _$V1AdminCreateUserPost$Response$UserToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminCreateUserPost$Response$UserToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'emailVerified', includeIfNull: false)
  final bool emailVerified;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'image', includeIfNull: false)
  final String? image;
  @JsonKey(name: 'role', includeIfNull: false)
  final String? role;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final DateTime updatedAt;
  static const fromJsonFactory = _$V1AdminCreateUserPost$Response$UserFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminCreateUserPost$Response$User &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.image, image) ||
                const DeepCollectionEquality().equals(other.image, image)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(image) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $V1AdminCreateUserPost$Response$UserExtension
    on V1AdminCreateUserPost$Response$User {
  V1AdminCreateUserPost$Response$User copyWith({
    String? id,
    String? email,
    bool? emailVerified,
    String? name,
    String? image,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return V1AdminCreateUserPost$Response$User(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      name: name ?? this.name,
      image: image ?? this.image,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  V1AdminCreateUserPost$Response$User copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? email,
    Wrapped<bool>? emailVerified,
    Wrapped<String>? name,
    Wrapped<String?>? image,
    Wrapped<String?>? role,
    Wrapped<DateTime>? createdAt,
    Wrapped<DateTime>? updatedAt,
  }) {
    return V1AdminCreateUserPost$Response$User(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      name: (name != null ? name.value : this.name),
      image: (image != null ? image.value : this.image),
      role: (role != null ? role.value : this.role),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminCreateOauthClientPost$Response$Client {
  const V1AdminCreateOauthClientPost$Response$Client({
    required this.clientId,
    this.clientSecret,
    this.clientSecretExpiresAt,
    this.scope,
    this.userId,
    this.clientIdIssuedAt,
    this.clientName,
    this.clientUri,
    this.logoUri,
    this.contacts,
    this.tosUri,
    this.policyUri,
    this.softwareId,
    this.softwareVersion,
    this.softwareStatement,
    this.redirectUris,
    this.postLogoutRedirectUris,
    this.tokenEndpointAuthMethod,
    this.grantTypes,
    this.responseTypes,
    this.public,
    this.type,
    this.disabled,
    this.skipConsent,
    this.enableEndSession,
    this.referenceId,
    this.metadata,
  });

  factory V1AdminCreateOauthClientPost$Response$Client.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminCreateOauthClientPost$Response$ClientFromJson(json);

  static const toJsonFactory =
      _$V1AdminCreateOauthClientPost$Response$ClientToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminCreateOauthClientPost$Response$ClientToJson(this);

  @JsonKey(name: 'client_id', includeIfNull: false)
  final String clientId;
  @JsonKey(name: 'client_secret', includeIfNull: false)
  final String? clientSecret;
  @JsonKey(name: 'client_secret_expires_at', includeIfNull: false)
  final double? clientSecretExpiresAt;
  @JsonKey(name: 'scope', includeIfNull: false)
  final String? scope;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'client_id_issued_at', includeIfNull: false)
  final double? clientIdIssuedAt;
  @JsonKey(name: 'client_name', includeIfNull: false)
  final String? clientName;
  @JsonKey(name: 'client_uri', includeIfNull: false)
  final String? clientUri;
  @JsonKey(name: 'logo_uri', includeIfNull: false)
  final String? logoUri;
  @JsonKey(name: 'contacts', includeIfNull: false, defaultValue: <String>[])
  final List<String>? contacts;
  @JsonKey(name: 'tos_uri', includeIfNull: false)
  final String? tosUri;
  @JsonKey(name: 'policy_uri', includeIfNull: false)
  final String? policyUri;
  @JsonKey(name: 'software_id', includeIfNull: false)
  final String? softwareId;
  @JsonKey(name: 'software_version', includeIfNull: false)
  final String? softwareVersion;
  @JsonKey(name: 'software_statement', includeIfNull: false)
  final String? softwareStatement;
  @JsonKey(
    name: 'redirect_uris',
    includeIfNull: false,
    defaultValue: <String>[],
  )
  final List<String>? redirectUris;
  @JsonKey(
    name: 'post_logout_redirect_uris',
    includeIfNull: false,
    defaultValue: <String>[],
  )
  final List<String>? postLogoutRedirectUris;
  @JsonKey(
    name: 'token_endpoint_auth_method',
    includeIfNull: false,
    toJson:
        v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableToJson,
    fromJson:
        v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableFromJson,
  )
  final enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
  tokenEndpointAuthMethod;
  @JsonKey(
    name: 'grant_types',
    includeIfNull: false,
    toJson: v1AdminCreateOauthClientPost$Response$ClientGrantTypesListToJson,
    fromJson:
        v1AdminCreateOauthClientPost$Response$ClientGrantTypesListFromJson,
  )
  final List<enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes>?
  grantTypes;
  @JsonKey(
    name: 'response_types',
    includeIfNull: false,
    toJson: v1AdminCreateOauthClientPost$Response$ClientResponseTypesListToJson,
    fromJson:
        v1AdminCreateOauthClientPost$Response$ClientResponseTypesListFromJson,
  )
  final List<enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes>?
  responseTypes;
  @JsonKey(name: 'public', includeIfNull: false)
  final bool? public;
  @JsonKey(
    name: 'type',
    includeIfNull: false,
    toJson: v1AdminCreateOauthClientPost$Response$ClientTypeNullableToJson,
    fromJson: v1AdminCreateOauthClientPost$Response$ClientTypeNullableFromJson,
  )
  final enums.V1AdminCreateOauthClientPost$Response$ClientType? type;
  @JsonKey(name: 'disabled', includeIfNull: false)
  final bool? disabled;
  @JsonKey(name: 'skip_consent', includeIfNull: false)
  final bool? skipConsent;
  @JsonKey(name: 'enable_end_session', includeIfNull: false)
  final bool? enableEndSession;
  @JsonKey(name: 'reference_id', includeIfNull: false)
  final String? referenceId;
  @JsonKey(name: 'metadata', includeIfNull: false)
  final Object? metadata;
  static const fromJsonFactory =
      _$V1AdminCreateOauthClientPost$Response$ClientFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminCreateOauthClientPost$Response$Client &&
            (identical(other.clientId, clientId) ||
                const DeepCollectionEquality().equals(
                  other.clientId,
                  clientId,
                )) &&
            (identical(other.clientSecret, clientSecret) ||
                const DeepCollectionEquality().equals(
                  other.clientSecret,
                  clientSecret,
                )) &&
            (identical(other.clientSecretExpiresAt, clientSecretExpiresAt) ||
                const DeepCollectionEquality().equals(
                  other.clientSecretExpiresAt,
                  clientSecretExpiresAt,
                )) &&
            (identical(other.scope, scope) ||
                const DeepCollectionEquality().equals(other.scope, scope)) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.clientIdIssuedAt, clientIdIssuedAt) ||
                const DeepCollectionEquality().equals(
                  other.clientIdIssuedAt,
                  clientIdIssuedAt,
                )) &&
            (identical(other.clientName, clientName) ||
                const DeepCollectionEquality().equals(
                  other.clientName,
                  clientName,
                )) &&
            (identical(other.clientUri, clientUri) ||
                const DeepCollectionEquality().equals(
                  other.clientUri,
                  clientUri,
                )) &&
            (identical(other.logoUri, logoUri) ||
                const DeepCollectionEquality().equals(
                  other.logoUri,
                  logoUri,
                )) &&
            (identical(other.contacts, contacts) ||
                const DeepCollectionEquality().equals(
                  other.contacts,
                  contacts,
                )) &&
            (identical(other.tosUri, tosUri) ||
                const DeepCollectionEquality().equals(other.tosUri, tosUri)) &&
            (identical(other.policyUri, policyUri) ||
                const DeepCollectionEquality().equals(
                  other.policyUri,
                  policyUri,
                )) &&
            (identical(other.softwareId, softwareId) ||
                const DeepCollectionEquality().equals(
                  other.softwareId,
                  softwareId,
                )) &&
            (identical(other.softwareVersion, softwareVersion) ||
                const DeepCollectionEquality().equals(
                  other.softwareVersion,
                  softwareVersion,
                )) &&
            (identical(other.softwareStatement, softwareStatement) ||
                const DeepCollectionEquality().equals(
                  other.softwareStatement,
                  softwareStatement,
                )) &&
            (identical(other.redirectUris, redirectUris) ||
                const DeepCollectionEquality().equals(
                  other.redirectUris,
                  redirectUris,
                )) &&
            (identical(other.postLogoutRedirectUris, postLogoutRedirectUris) ||
                const DeepCollectionEquality().equals(
                  other.postLogoutRedirectUris,
                  postLogoutRedirectUris,
                )) &&
            (identical(
                  other.tokenEndpointAuthMethod,
                  tokenEndpointAuthMethod,
                ) ||
                const DeepCollectionEquality().equals(
                  other.tokenEndpointAuthMethod,
                  tokenEndpointAuthMethod,
                )) &&
            (identical(other.grantTypes, grantTypes) ||
                const DeepCollectionEquality().equals(
                  other.grantTypes,
                  grantTypes,
                )) &&
            (identical(other.responseTypes, responseTypes) ||
                const DeepCollectionEquality().equals(
                  other.responseTypes,
                  responseTypes,
                )) &&
            (identical(other.public, public) ||
                const DeepCollectionEquality().equals(other.public, public)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.disabled, disabled) ||
                const DeepCollectionEquality().equals(
                  other.disabled,
                  disabled,
                )) &&
            (identical(other.skipConsent, skipConsent) ||
                const DeepCollectionEquality().equals(
                  other.skipConsent,
                  skipConsent,
                )) &&
            (identical(other.enableEndSession, enableEndSession) ||
                const DeepCollectionEquality().equals(
                  other.enableEndSession,
                  enableEndSession,
                )) &&
            (identical(other.referenceId, referenceId) ||
                const DeepCollectionEquality().equals(
                  other.referenceId,
                  referenceId,
                )) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality().equals(
                  other.metadata,
                  metadata,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(clientId) ^
      const DeepCollectionEquality().hash(clientSecret) ^
      const DeepCollectionEquality().hash(clientSecretExpiresAt) ^
      const DeepCollectionEquality().hash(scope) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(clientIdIssuedAt) ^
      const DeepCollectionEquality().hash(clientName) ^
      const DeepCollectionEquality().hash(clientUri) ^
      const DeepCollectionEquality().hash(logoUri) ^
      const DeepCollectionEquality().hash(contacts) ^
      const DeepCollectionEquality().hash(tosUri) ^
      const DeepCollectionEquality().hash(policyUri) ^
      const DeepCollectionEquality().hash(softwareId) ^
      const DeepCollectionEquality().hash(softwareVersion) ^
      const DeepCollectionEquality().hash(softwareStatement) ^
      const DeepCollectionEquality().hash(redirectUris) ^
      const DeepCollectionEquality().hash(postLogoutRedirectUris) ^
      const DeepCollectionEquality().hash(tokenEndpointAuthMethod) ^
      const DeepCollectionEquality().hash(grantTypes) ^
      const DeepCollectionEquality().hash(responseTypes) ^
      const DeepCollectionEquality().hash(public) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(disabled) ^
      const DeepCollectionEquality().hash(skipConsent) ^
      const DeepCollectionEquality().hash(enableEndSession) ^
      const DeepCollectionEquality().hash(referenceId) ^
      const DeepCollectionEquality().hash(metadata) ^
      runtimeType.hashCode;
}

extension $V1AdminCreateOauthClientPost$Response$ClientExtension
    on V1AdminCreateOauthClientPost$Response$Client {
  V1AdminCreateOauthClientPost$Response$Client copyWith({
    String? clientId,
    String? clientSecret,
    double? clientSecretExpiresAt,
    String? scope,
    String? userId,
    double? clientIdIssuedAt,
    String? clientName,
    String? clientUri,
    String? logoUri,
    List<String>? contacts,
    String? tosUri,
    String? policyUri,
    String? softwareId,
    String? softwareVersion,
    String? softwareStatement,
    List<String>? redirectUris,
    List<String>? postLogoutRedirectUris,
    enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
    tokenEndpointAuthMethod,
    List<enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes>?
    grantTypes,
    List<enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes>?
    responseTypes,
    bool? public,
    enums.V1AdminCreateOauthClientPost$Response$ClientType? type,
    bool? disabled,
    bool? skipConsent,
    bool? enableEndSession,
    String? referenceId,
    Object? metadata,
  }) {
    return V1AdminCreateOauthClientPost$Response$Client(
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      clientSecretExpiresAt:
          clientSecretExpiresAt ?? this.clientSecretExpiresAt,
      scope: scope ?? this.scope,
      userId: userId ?? this.userId,
      clientIdIssuedAt: clientIdIssuedAt ?? this.clientIdIssuedAt,
      clientName: clientName ?? this.clientName,
      clientUri: clientUri ?? this.clientUri,
      logoUri: logoUri ?? this.logoUri,
      contacts: contacts ?? this.contacts,
      tosUri: tosUri ?? this.tosUri,
      policyUri: policyUri ?? this.policyUri,
      softwareId: softwareId ?? this.softwareId,
      softwareVersion: softwareVersion ?? this.softwareVersion,
      softwareStatement: softwareStatement ?? this.softwareStatement,
      redirectUris: redirectUris ?? this.redirectUris,
      postLogoutRedirectUris:
          postLogoutRedirectUris ?? this.postLogoutRedirectUris,
      tokenEndpointAuthMethod:
          tokenEndpointAuthMethod ?? this.tokenEndpointAuthMethod,
      grantTypes: grantTypes ?? this.grantTypes,
      responseTypes: responseTypes ?? this.responseTypes,
      public: public ?? this.public,
      type: type ?? this.type,
      disabled: disabled ?? this.disabled,
      skipConsent: skipConsent ?? this.skipConsent,
      enableEndSession: enableEndSession ?? this.enableEndSession,
      referenceId: referenceId ?? this.referenceId,
      metadata: metadata ?? this.metadata,
    );
  }

  V1AdminCreateOauthClientPost$Response$Client copyWithWrapped({
    Wrapped<String>? clientId,
    Wrapped<String?>? clientSecret,
    Wrapped<double?>? clientSecretExpiresAt,
    Wrapped<String?>? scope,
    Wrapped<String?>? userId,
    Wrapped<double?>? clientIdIssuedAt,
    Wrapped<String?>? clientName,
    Wrapped<String?>? clientUri,
    Wrapped<String?>? logoUri,
    Wrapped<List<String>?>? contacts,
    Wrapped<String?>? tosUri,
    Wrapped<String?>? policyUri,
    Wrapped<String?>? softwareId,
    Wrapped<String?>? softwareVersion,
    Wrapped<String?>? softwareStatement,
    Wrapped<List<String>?>? redirectUris,
    Wrapped<List<String>?>? postLogoutRedirectUris,
    Wrapped<
      enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
    >?
    tokenEndpointAuthMethod,
    Wrapped<
      List<enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes>?
    >?
    grantTypes,
    Wrapped<
      List<enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes>?
    >?
    responseTypes,
    Wrapped<bool?>? public,
    Wrapped<enums.V1AdminCreateOauthClientPost$Response$ClientType?>? type,
    Wrapped<bool?>? disabled,
    Wrapped<bool?>? skipConsent,
    Wrapped<bool?>? enableEndSession,
    Wrapped<String?>? referenceId,
    Wrapped<Object?>? metadata,
  }) {
    return V1AdminCreateOauthClientPost$Response$Client(
      clientId: (clientId != null ? clientId.value : this.clientId),
      clientSecret: (clientSecret != null
          ? clientSecret.value
          : this.clientSecret),
      clientSecretExpiresAt: (clientSecretExpiresAt != null
          ? clientSecretExpiresAt.value
          : this.clientSecretExpiresAt),
      scope: (scope != null ? scope.value : this.scope),
      userId: (userId != null ? userId.value : this.userId),
      clientIdIssuedAt: (clientIdIssuedAt != null
          ? clientIdIssuedAt.value
          : this.clientIdIssuedAt),
      clientName: (clientName != null ? clientName.value : this.clientName),
      clientUri: (clientUri != null ? clientUri.value : this.clientUri),
      logoUri: (logoUri != null ? logoUri.value : this.logoUri),
      contacts: (contacts != null ? contacts.value : this.contacts),
      tosUri: (tosUri != null ? tosUri.value : this.tosUri),
      policyUri: (policyUri != null ? policyUri.value : this.policyUri),
      softwareId: (softwareId != null ? softwareId.value : this.softwareId),
      softwareVersion: (softwareVersion != null
          ? softwareVersion.value
          : this.softwareVersion),
      softwareStatement: (softwareStatement != null
          ? softwareStatement.value
          : this.softwareStatement),
      redirectUris: (redirectUris != null
          ? redirectUris.value
          : this.redirectUris),
      postLogoutRedirectUris: (postLogoutRedirectUris != null
          ? postLogoutRedirectUris.value
          : this.postLogoutRedirectUris),
      tokenEndpointAuthMethod: (tokenEndpointAuthMethod != null
          ? tokenEndpointAuthMethod.value
          : this.tokenEndpointAuthMethod),
      grantTypes: (grantTypes != null ? grantTypes.value : this.grantTypes),
      responseTypes: (responseTypes != null
          ? responseTypes.value
          : this.responseTypes),
      public: (public != null ? public.value : this.public),
      type: (type != null ? type.value : this.type),
      disabled: (disabled != null ? disabled.value : this.disabled),
      skipConsent: (skipConsent != null ? skipConsent.value : this.skipConsent),
      enableEndSession: (enableEndSession != null
          ? enableEndSession.value
          : this.enableEndSession),
      referenceId: (referenceId != null ? referenceId.value : this.referenceId),
      metadata: (metadata != null ? metadata.value : this.metadata),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminUpdateUserPost$Response$User {
  const V1AdminUpdateUserPost$Response$User({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.name,
    this.image,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory V1AdminUpdateUserPost$Response$User.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminUpdateUserPost$Response$UserFromJson(json);

  static const toJsonFactory = _$V1AdminUpdateUserPost$Response$UserToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminUpdateUserPost$Response$UserToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'emailVerified', includeIfNull: false)
  final bool emailVerified;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'image', includeIfNull: false)
  final String? image;
  @JsonKey(name: 'role', includeIfNull: false)
  final String? role;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final DateTime updatedAt;
  static const fromJsonFactory = _$V1AdminUpdateUserPost$Response$UserFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminUpdateUserPost$Response$User &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.image, image) ||
                const DeepCollectionEquality().equals(other.image, image)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(image) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $V1AdminUpdateUserPost$Response$UserExtension
    on V1AdminUpdateUserPost$Response$User {
  V1AdminUpdateUserPost$Response$User copyWith({
    String? id,
    String? email,
    bool? emailVerified,
    String? name,
    String? image,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return V1AdminUpdateUserPost$Response$User(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      name: name ?? this.name,
      image: image ?? this.image,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  V1AdminUpdateUserPost$Response$User copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? email,
    Wrapped<bool>? emailVerified,
    Wrapped<String>? name,
    Wrapped<String?>? image,
    Wrapped<String?>? role,
    Wrapped<DateTime>? createdAt,
    Wrapped<DateTime>? updatedAt,
  }) {
    return V1AdminUpdateUserPost$Response$User(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      name: (name != null ? name.value : this.name),
      image: (image != null ? image.value : this.image),
      role: (role != null ? role.value : this.role),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminUpdateOauthClientPost$Response$Client {
  const V1AdminUpdateOauthClientPost$Response$Client({
    required this.clientId,
    this.clientSecret,
    this.clientSecretExpiresAt,
    this.scope,
    this.userId,
    this.clientIdIssuedAt,
    this.clientName,
    this.clientUri,
    this.logoUri,
    this.contacts,
    this.tosUri,
    this.policyUri,
    this.softwareId,
    this.softwareVersion,
    this.softwareStatement,
    this.redirectUris,
    this.postLogoutRedirectUris,
    this.tokenEndpointAuthMethod,
    this.grantTypes,
    this.responseTypes,
    this.public,
    this.type,
    this.disabled,
    this.skipConsent,
    this.enableEndSession,
    this.referenceId,
    this.metadata,
  });

  factory V1AdminUpdateOauthClientPost$Response$Client.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminUpdateOauthClientPost$Response$ClientFromJson(json);

  static const toJsonFactory =
      _$V1AdminUpdateOauthClientPost$Response$ClientToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminUpdateOauthClientPost$Response$ClientToJson(this);

  @JsonKey(name: 'client_id', includeIfNull: false)
  final String clientId;
  @JsonKey(name: 'client_secret', includeIfNull: false)
  final String? clientSecret;
  @JsonKey(name: 'client_secret_expires_at', includeIfNull: false)
  final double? clientSecretExpiresAt;
  @JsonKey(name: 'scope', includeIfNull: false)
  final String? scope;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'client_id_issued_at', includeIfNull: false)
  final double? clientIdIssuedAt;
  @JsonKey(name: 'client_name', includeIfNull: false)
  final String? clientName;
  @JsonKey(name: 'client_uri', includeIfNull: false)
  final String? clientUri;
  @JsonKey(name: 'logo_uri', includeIfNull: false)
  final String? logoUri;
  @JsonKey(name: 'contacts', includeIfNull: false, defaultValue: <String>[])
  final List<String>? contacts;
  @JsonKey(name: 'tos_uri', includeIfNull: false)
  final String? tosUri;
  @JsonKey(name: 'policy_uri', includeIfNull: false)
  final String? policyUri;
  @JsonKey(name: 'software_id', includeIfNull: false)
  final String? softwareId;
  @JsonKey(name: 'software_version', includeIfNull: false)
  final String? softwareVersion;
  @JsonKey(name: 'software_statement', includeIfNull: false)
  final String? softwareStatement;
  @JsonKey(
    name: 'redirect_uris',
    includeIfNull: false,
    defaultValue: <String>[],
  )
  final List<String>? redirectUris;
  @JsonKey(
    name: 'post_logout_redirect_uris',
    includeIfNull: false,
    defaultValue: <String>[],
  )
  final List<String>? postLogoutRedirectUris;
  @JsonKey(
    name: 'token_endpoint_auth_method',
    includeIfNull: false,
    toJson:
        v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableToJson,
    fromJson:
        v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableFromJson,
  )
  final enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
  tokenEndpointAuthMethod;
  @JsonKey(
    name: 'grant_types',
    includeIfNull: false,
    toJson: v1AdminUpdateOauthClientPost$Response$ClientGrantTypesListToJson,
    fromJson:
        v1AdminUpdateOauthClientPost$Response$ClientGrantTypesListFromJson,
  )
  final List<enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes>?
  grantTypes;
  @JsonKey(
    name: 'response_types',
    includeIfNull: false,
    toJson: v1AdminUpdateOauthClientPost$Response$ClientResponseTypesListToJson,
    fromJson:
        v1AdminUpdateOauthClientPost$Response$ClientResponseTypesListFromJson,
  )
  final List<enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes>?
  responseTypes;
  @JsonKey(name: 'public', includeIfNull: false)
  final bool? public;
  @JsonKey(
    name: 'type',
    includeIfNull: false,
    toJson: v1AdminUpdateOauthClientPost$Response$ClientTypeNullableToJson,
    fromJson: v1AdminUpdateOauthClientPost$Response$ClientTypeNullableFromJson,
  )
  final enums.V1AdminUpdateOauthClientPost$Response$ClientType? type;
  @JsonKey(name: 'disabled', includeIfNull: false)
  final bool? disabled;
  @JsonKey(name: 'skip_consent', includeIfNull: false)
  final bool? skipConsent;
  @JsonKey(name: 'enable_end_session', includeIfNull: false)
  final bool? enableEndSession;
  @JsonKey(name: 'reference_id', includeIfNull: false)
  final String? referenceId;
  @JsonKey(name: 'metadata', includeIfNull: false)
  final Object? metadata;
  static const fromJsonFactory =
      _$V1AdminUpdateOauthClientPost$Response$ClientFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminUpdateOauthClientPost$Response$Client &&
            (identical(other.clientId, clientId) ||
                const DeepCollectionEquality().equals(
                  other.clientId,
                  clientId,
                )) &&
            (identical(other.clientSecret, clientSecret) ||
                const DeepCollectionEquality().equals(
                  other.clientSecret,
                  clientSecret,
                )) &&
            (identical(other.clientSecretExpiresAt, clientSecretExpiresAt) ||
                const DeepCollectionEquality().equals(
                  other.clientSecretExpiresAt,
                  clientSecretExpiresAt,
                )) &&
            (identical(other.scope, scope) ||
                const DeepCollectionEquality().equals(other.scope, scope)) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.clientIdIssuedAt, clientIdIssuedAt) ||
                const DeepCollectionEquality().equals(
                  other.clientIdIssuedAt,
                  clientIdIssuedAt,
                )) &&
            (identical(other.clientName, clientName) ||
                const DeepCollectionEquality().equals(
                  other.clientName,
                  clientName,
                )) &&
            (identical(other.clientUri, clientUri) ||
                const DeepCollectionEquality().equals(
                  other.clientUri,
                  clientUri,
                )) &&
            (identical(other.logoUri, logoUri) ||
                const DeepCollectionEquality().equals(
                  other.logoUri,
                  logoUri,
                )) &&
            (identical(other.contacts, contacts) ||
                const DeepCollectionEquality().equals(
                  other.contacts,
                  contacts,
                )) &&
            (identical(other.tosUri, tosUri) ||
                const DeepCollectionEquality().equals(other.tosUri, tosUri)) &&
            (identical(other.policyUri, policyUri) ||
                const DeepCollectionEquality().equals(
                  other.policyUri,
                  policyUri,
                )) &&
            (identical(other.softwareId, softwareId) ||
                const DeepCollectionEquality().equals(
                  other.softwareId,
                  softwareId,
                )) &&
            (identical(other.softwareVersion, softwareVersion) ||
                const DeepCollectionEquality().equals(
                  other.softwareVersion,
                  softwareVersion,
                )) &&
            (identical(other.softwareStatement, softwareStatement) ||
                const DeepCollectionEquality().equals(
                  other.softwareStatement,
                  softwareStatement,
                )) &&
            (identical(other.redirectUris, redirectUris) ||
                const DeepCollectionEquality().equals(
                  other.redirectUris,
                  redirectUris,
                )) &&
            (identical(other.postLogoutRedirectUris, postLogoutRedirectUris) ||
                const DeepCollectionEquality().equals(
                  other.postLogoutRedirectUris,
                  postLogoutRedirectUris,
                )) &&
            (identical(
                  other.tokenEndpointAuthMethod,
                  tokenEndpointAuthMethod,
                ) ||
                const DeepCollectionEquality().equals(
                  other.tokenEndpointAuthMethod,
                  tokenEndpointAuthMethod,
                )) &&
            (identical(other.grantTypes, grantTypes) ||
                const DeepCollectionEquality().equals(
                  other.grantTypes,
                  grantTypes,
                )) &&
            (identical(other.responseTypes, responseTypes) ||
                const DeepCollectionEquality().equals(
                  other.responseTypes,
                  responseTypes,
                )) &&
            (identical(other.public, public) ||
                const DeepCollectionEquality().equals(other.public, public)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.disabled, disabled) ||
                const DeepCollectionEquality().equals(
                  other.disabled,
                  disabled,
                )) &&
            (identical(other.skipConsent, skipConsent) ||
                const DeepCollectionEquality().equals(
                  other.skipConsent,
                  skipConsent,
                )) &&
            (identical(other.enableEndSession, enableEndSession) ||
                const DeepCollectionEquality().equals(
                  other.enableEndSession,
                  enableEndSession,
                )) &&
            (identical(other.referenceId, referenceId) ||
                const DeepCollectionEquality().equals(
                  other.referenceId,
                  referenceId,
                )) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality().equals(
                  other.metadata,
                  metadata,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(clientId) ^
      const DeepCollectionEquality().hash(clientSecret) ^
      const DeepCollectionEquality().hash(clientSecretExpiresAt) ^
      const DeepCollectionEquality().hash(scope) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(clientIdIssuedAt) ^
      const DeepCollectionEquality().hash(clientName) ^
      const DeepCollectionEquality().hash(clientUri) ^
      const DeepCollectionEquality().hash(logoUri) ^
      const DeepCollectionEquality().hash(contacts) ^
      const DeepCollectionEquality().hash(tosUri) ^
      const DeepCollectionEquality().hash(policyUri) ^
      const DeepCollectionEquality().hash(softwareId) ^
      const DeepCollectionEquality().hash(softwareVersion) ^
      const DeepCollectionEquality().hash(softwareStatement) ^
      const DeepCollectionEquality().hash(redirectUris) ^
      const DeepCollectionEquality().hash(postLogoutRedirectUris) ^
      const DeepCollectionEquality().hash(tokenEndpointAuthMethod) ^
      const DeepCollectionEquality().hash(grantTypes) ^
      const DeepCollectionEquality().hash(responseTypes) ^
      const DeepCollectionEquality().hash(public) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(disabled) ^
      const DeepCollectionEquality().hash(skipConsent) ^
      const DeepCollectionEquality().hash(enableEndSession) ^
      const DeepCollectionEquality().hash(referenceId) ^
      const DeepCollectionEquality().hash(metadata) ^
      runtimeType.hashCode;
}

extension $V1AdminUpdateOauthClientPost$Response$ClientExtension
    on V1AdminUpdateOauthClientPost$Response$Client {
  V1AdminUpdateOauthClientPost$Response$Client copyWith({
    String? clientId,
    String? clientSecret,
    double? clientSecretExpiresAt,
    String? scope,
    String? userId,
    double? clientIdIssuedAt,
    String? clientName,
    String? clientUri,
    String? logoUri,
    List<String>? contacts,
    String? tosUri,
    String? policyUri,
    String? softwareId,
    String? softwareVersion,
    String? softwareStatement,
    List<String>? redirectUris,
    List<String>? postLogoutRedirectUris,
    enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
    tokenEndpointAuthMethod,
    List<enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes>?
    grantTypes,
    List<enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes>?
    responseTypes,
    bool? public,
    enums.V1AdminUpdateOauthClientPost$Response$ClientType? type,
    bool? disabled,
    bool? skipConsent,
    bool? enableEndSession,
    String? referenceId,
    Object? metadata,
  }) {
    return V1AdminUpdateOauthClientPost$Response$Client(
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      clientSecretExpiresAt:
          clientSecretExpiresAt ?? this.clientSecretExpiresAt,
      scope: scope ?? this.scope,
      userId: userId ?? this.userId,
      clientIdIssuedAt: clientIdIssuedAt ?? this.clientIdIssuedAt,
      clientName: clientName ?? this.clientName,
      clientUri: clientUri ?? this.clientUri,
      logoUri: logoUri ?? this.logoUri,
      contacts: contacts ?? this.contacts,
      tosUri: tosUri ?? this.tosUri,
      policyUri: policyUri ?? this.policyUri,
      softwareId: softwareId ?? this.softwareId,
      softwareVersion: softwareVersion ?? this.softwareVersion,
      softwareStatement: softwareStatement ?? this.softwareStatement,
      redirectUris: redirectUris ?? this.redirectUris,
      postLogoutRedirectUris:
          postLogoutRedirectUris ?? this.postLogoutRedirectUris,
      tokenEndpointAuthMethod:
          tokenEndpointAuthMethod ?? this.tokenEndpointAuthMethod,
      grantTypes: grantTypes ?? this.grantTypes,
      responseTypes: responseTypes ?? this.responseTypes,
      public: public ?? this.public,
      type: type ?? this.type,
      disabled: disabled ?? this.disabled,
      skipConsent: skipConsent ?? this.skipConsent,
      enableEndSession: enableEndSession ?? this.enableEndSession,
      referenceId: referenceId ?? this.referenceId,
      metadata: metadata ?? this.metadata,
    );
  }

  V1AdminUpdateOauthClientPost$Response$Client copyWithWrapped({
    Wrapped<String>? clientId,
    Wrapped<String?>? clientSecret,
    Wrapped<double?>? clientSecretExpiresAt,
    Wrapped<String?>? scope,
    Wrapped<String?>? userId,
    Wrapped<double?>? clientIdIssuedAt,
    Wrapped<String?>? clientName,
    Wrapped<String?>? clientUri,
    Wrapped<String?>? logoUri,
    Wrapped<List<String>?>? contacts,
    Wrapped<String?>? tosUri,
    Wrapped<String?>? policyUri,
    Wrapped<String?>? softwareId,
    Wrapped<String?>? softwareVersion,
    Wrapped<String?>? softwareStatement,
    Wrapped<List<String>?>? redirectUris,
    Wrapped<List<String>?>? postLogoutRedirectUris,
    Wrapped<
      enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
    >?
    tokenEndpointAuthMethod,
    Wrapped<
      List<enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes>?
    >?
    grantTypes,
    Wrapped<
      List<enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes>?
    >?
    responseTypes,
    Wrapped<bool?>? public,
    Wrapped<enums.V1AdminUpdateOauthClientPost$Response$ClientType?>? type,
    Wrapped<bool?>? disabled,
    Wrapped<bool?>? skipConsent,
    Wrapped<bool?>? enableEndSession,
    Wrapped<String?>? referenceId,
    Wrapped<Object?>? metadata,
  }) {
    return V1AdminUpdateOauthClientPost$Response$Client(
      clientId: (clientId != null ? clientId.value : this.clientId),
      clientSecret: (clientSecret != null
          ? clientSecret.value
          : this.clientSecret),
      clientSecretExpiresAt: (clientSecretExpiresAt != null
          ? clientSecretExpiresAt.value
          : this.clientSecretExpiresAt),
      scope: (scope != null ? scope.value : this.scope),
      userId: (userId != null ? userId.value : this.userId),
      clientIdIssuedAt: (clientIdIssuedAt != null
          ? clientIdIssuedAt.value
          : this.clientIdIssuedAt),
      clientName: (clientName != null ? clientName.value : this.clientName),
      clientUri: (clientUri != null ? clientUri.value : this.clientUri),
      logoUri: (logoUri != null ? logoUri.value : this.logoUri),
      contacts: (contacts != null ? contacts.value : this.contacts),
      tosUri: (tosUri != null ? tosUri.value : this.tosUri),
      policyUri: (policyUri != null ? policyUri.value : this.policyUri),
      softwareId: (softwareId != null ? softwareId.value : this.softwareId),
      softwareVersion: (softwareVersion != null
          ? softwareVersion.value
          : this.softwareVersion),
      softwareStatement: (softwareStatement != null
          ? softwareStatement.value
          : this.softwareStatement),
      redirectUris: (redirectUris != null
          ? redirectUris.value
          : this.redirectUris),
      postLogoutRedirectUris: (postLogoutRedirectUris != null
          ? postLogoutRedirectUris.value
          : this.postLogoutRedirectUris),
      tokenEndpointAuthMethod: (tokenEndpointAuthMethod != null
          ? tokenEndpointAuthMethod.value
          : this.tokenEndpointAuthMethod),
      grantTypes: (grantTypes != null ? grantTypes.value : this.grantTypes),
      responseTypes: (responseTypes != null
          ? responseTypes.value
          : this.responseTypes),
      public: (public != null ? public.value : this.public),
      type: (type != null ? type.value : this.type),
      disabled: (disabled != null ? disabled.value : this.disabled),
      skipConsent: (skipConsent != null ? skipConsent.value : this.skipConsent),
      enableEndSession: (enableEndSession != null
          ? enableEndSession.value
          : this.enableEndSession),
      referenceId: (referenceId != null ? referenceId.value : this.referenceId),
      metadata: (metadata != null ? metadata.value : this.metadata),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminListUsersGet$Response$Users$Item {
  const V1AdminListUsersGet$Response$Users$Item({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.name,
    this.image,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory V1AdminListUsersGet$Response$Users$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminListUsersGet$Response$Users$ItemFromJson(json);

  static const toJsonFactory = _$V1AdminListUsersGet$Response$Users$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminListUsersGet$Response$Users$ItemToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'emailVerified', includeIfNull: false)
  final bool emailVerified;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'image', includeIfNull: false)
  final String? image;
  @JsonKey(name: 'role', includeIfNull: false)
  final String? role;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final DateTime updatedAt;
  static const fromJsonFactory =
      _$V1AdminListUsersGet$Response$Users$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminListUsersGet$Response$Users$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.image, image) ||
                const DeepCollectionEquality().equals(other.image, image)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(image) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $V1AdminListUsersGet$Response$Users$ItemExtension
    on V1AdminListUsersGet$Response$Users$Item {
  V1AdminListUsersGet$Response$Users$Item copyWith({
    String? id,
    String? email,
    bool? emailVerified,
    String? name,
    String? image,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return V1AdminListUsersGet$Response$Users$Item(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      name: name ?? this.name,
      image: image ?? this.image,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  V1AdminListUsersGet$Response$Users$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? email,
    Wrapped<bool>? emailVerified,
    Wrapped<String>? name,
    Wrapped<String?>? image,
    Wrapped<String?>? role,
    Wrapped<DateTime>? createdAt,
    Wrapped<DateTime>? updatedAt,
  }) {
    return V1AdminListUsersGet$Response$Users$Item(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      name: (name != null ? name.value : this.name),
      image: (image != null ? image.value : this.image),
      role: (role != null ? role.value : this.role),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1AdminListOauthClientsGet$Response$Clients$Item {
  const V1AdminListOauthClientsGet$Response$Clients$Item({
    required this.clientId,
    this.clientSecret,
    this.clientSecretExpiresAt,
    this.scope,
    this.userId,
    this.clientIdIssuedAt,
    this.clientName,
    this.clientUri,
    this.logoUri,
    this.contacts,
    this.tosUri,
    this.policyUri,
    this.softwareId,
    this.softwareVersion,
    this.softwareStatement,
    this.redirectUris,
    this.postLogoutRedirectUris,
    this.tokenEndpointAuthMethod,
    this.grantTypes,
    this.responseTypes,
    this.public,
    this.type,
    this.disabled,
    this.skipConsent,
    this.enableEndSession,
    this.referenceId,
    this.metadata,
  });

  factory V1AdminListOauthClientsGet$Response$Clients$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$V1AdminListOauthClientsGet$Response$Clients$ItemFromJson(json);

  static const toJsonFactory =
      _$V1AdminListOauthClientsGet$Response$Clients$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$V1AdminListOauthClientsGet$Response$Clients$ItemToJson(this);

  @JsonKey(name: 'client_id', includeIfNull: false)
  final String clientId;
  @JsonKey(name: 'client_secret', includeIfNull: false)
  final String? clientSecret;
  @JsonKey(name: 'client_secret_expires_at', includeIfNull: false)
  final double? clientSecretExpiresAt;
  @JsonKey(name: 'scope', includeIfNull: false)
  final String? scope;
  @JsonKey(name: 'user_id', includeIfNull: false)
  final String? userId;
  @JsonKey(name: 'client_id_issued_at', includeIfNull: false)
  final double? clientIdIssuedAt;
  @JsonKey(name: 'client_name', includeIfNull: false)
  final String? clientName;
  @JsonKey(name: 'client_uri', includeIfNull: false)
  final String? clientUri;
  @JsonKey(name: 'logo_uri', includeIfNull: false)
  final String? logoUri;
  @JsonKey(name: 'contacts', includeIfNull: false, defaultValue: <Object>[])
  final List<Object>? contacts;
  @JsonKey(name: 'tos_uri', includeIfNull: false)
  final String? tosUri;
  @JsonKey(name: 'policy_uri', includeIfNull: false)
  final String? policyUri;
  @JsonKey(name: 'software_id', includeIfNull: false)
  final String? softwareId;
  @JsonKey(name: 'software_version', includeIfNull: false)
  final String? softwareVersion;
  @JsonKey(name: 'software_statement', includeIfNull: false)
  final String? softwareStatement;
  @JsonKey(
    name: 'redirect_uris',
    includeIfNull: false,
    defaultValue: <Object>[],
  )
  final List<Object>? redirectUris;
  @JsonKey(
    name: 'post_logout_redirect_uris',
    includeIfNull: false,
    defaultValue: <Object>[],
  )
  final List<Object>? postLogoutRedirectUris;
  @JsonKey(
    name: 'token_endpoint_auth_method',
    includeIfNull: false,
    toJson:
        v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodNullableToJson,
    fromJson:
        v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodNullableFromJson,
  )
  final enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod?
  tokenEndpointAuthMethod;
  @JsonKey(name: 'grant_types', includeIfNull: false, defaultValue: <Object>[])
  final List<Object>? grantTypes;
  @JsonKey(
    name: 'response_types',
    includeIfNull: false,
    defaultValue: <Object>[],
  )
  final List<Object>? responseTypes;
  @JsonKey(name: 'public', includeIfNull: false)
  final bool? public;
  @JsonKey(
    name: 'type',
    includeIfNull: false,
    toJson: v1AdminListOauthClientsGet$Response$Clients$ItemTypeNullableToJson,
    fromJson:
        v1AdminListOauthClientsGet$Response$Clients$ItemTypeNullableFromJson,
  )
  final enums.V1AdminListOauthClientsGet$Response$Clients$ItemType? type;
  @JsonKey(name: 'disabled', includeIfNull: false)
  final bool? disabled;
  @JsonKey(name: 'skip_consent', includeIfNull: false)
  final bool? skipConsent;
  @JsonKey(name: 'enable_end_session', includeIfNull: false)
  final bool? enableEndSession;
  @JsonKey(name: 'reference_id', includeIfNull: false)
  final String? referenceId;
  @JsonKey(name: 'metadata', includeIfNull: false)
  final Object? metadata;
  static const fromJsonFactory =
      _$V1AdminListOauthClientsGet$Response$Clients$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1AdminListOauthClientsGet$Response$Clients$Item &&
            (identical(other.clientId, clientId) ||
                const DeepCollectionEquality().equals(
                  other.clientId,
                  clientId,
                )) &&
            (identical(other.clientSecret, clientSecret) ||
                const DeepCollectionEquality().equals(
                  other.clientSecret,
                  clientSecret,
                )) &&
            (identical(other.clientSecretExpiresAt, clientSecretExpiresAt) ||
                const DeepCollectionEquality().equals(
                  other.clientSecretExpiresAt,
                  clientSecretExpiresAt,
                )) &&
            (identical(other.scope, scope) ||
                const DeepCollectionEquality().equals(other.scope, scope)) &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.clientIdIssuedAt, clientIdIssuedAt) ||
                const DeepCollectionEquality().equals(
                  other.clientIdIssuedAt,
                  clientIdIssuedAt,
                )) &&
            (identical(other.clientName, clientName) ||
                const DeepCollectionEquality().equals(
                  other.clientName,
                  clientName,
                )) &&
            (identical(other.clientUri, clientUri) ||
                const DeepCollectionEquality().equals(
                  other.clientUri,
                  clientUri,
                )) &&
            (identical(other.logoUri, logoUri) ||
                const DeepCollectionEquality().equals(
                  other.logoUri,
                  logoUri,
                )) &&
            (identical(other.contacts, contacts) ||
                const DeepCollectionEquality().equals(
                  other.contacts,
                  contacts,
                )) &&
            (identical(other.tosUri, tosUri) ||
                const DeepCollectionEquality().equals(other.tosUri, tosUri)) &&
            (identical(other.policyUri, policyUri) ||
                const DeepCollectionEquality().equals(
                  other.policyUri,
                  policyUri,
                )) &&
            (identical(other.softwareId, softwareId) ||
                const DeepCollectionEquality().equals(
                  other.softwareId,
                  softwareId,
                )) &&
            (identical(other.softwareVersion, softwareVersion) ||
                const DeepCollectionEquality().equals(
                  other.softwareVersion,
                  softwareVersion,
                )) &&
            (identical(other.softwareStatement, softwareStatement) ||
                const DeepCollectionEquality().equals(
                  other.softwareStatement,
                  softwareStatement,
                )) &&
            (identical(other.redirectUris, redirectUris) ||
                const DeepCollectionEquality().equals(
                  other.redirectUris,
                  redirectUris,
                )) &&
            (identical(other.postLogoutRedirectUris, postLogoutRedirectUris) ||
                const DeepCollectionEquality().equals(
                  other.postLogoutRedirectUris,
                  postLogoutRedirectUris,
                )) &&
            (identical(
                  other.tokenEndpointAuthMethod,
                  tokenEndpointAuthMethod,
                ) ||
                const DeepCollectionEquality().equals(
                  other.tokenEndpointAuthMethod,
                  tokenEndpointAuthMethod,
                )) &&
            (identical(other.grantTypes, grantTypes) ||
                const DeepCollectionEquality().equals(
                  other.grantTypes,
                  grantTypes,
                )) &&
            (identical(other.responseTypes, responseTypes) ||
                const DeepCollectionEquality().equals(
                  other.responseTypes,
                  responseTypes,
                )) &&
            (identical(other.public, public) ||
                const DeepCollectionEquality().equals(other.public, public)) &&
            (identical(other.type, type) ||
                const DeepCollectionEquality().equals(other.type, type)) &&
            (identical(other.disabled, disabled) ||
                const DeepCollectionEquality().equals(
                  other.disabled,
                  disabled,
                )) &&
            (identical(other.skipConsent, skipConsent) ||
                const DeepCollectionEquality().equals(
                  other.skipConsent,
                  skipConsent,
                )) &&
            (identical(other.enableEndSession, enableEndSession) ||
                const DeepCollectionEquality().equals(
                  other.enableEndSession,
                  enableEndSession,
                )) &&
            (identical(other.referenceId, referenceId) ||
                const DeepCollectionEquality().equals(
                  other.referenceId,
                  referenceId,
                )) &&
            (identical(other.metadata, metadata) ||
                const DeepCollectionEquality().equals(
                  other.metadata,
                  metadata,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(clientId) ^
      const DeepCollectionEquality().hash(clientSecret) ^
      const DeepCollectionEquality().hash(clientSecretExpiresAt) ^
      const DeepCollectionEquality().hash(scope) ^
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(clientIdIssuedAt) ^
      const DeepCollectionEquality().hash(clientName) ^
      const DeepCollectionEquality().hash(clientUri) ^
      const DeepCollectionEquality().hash(logoUri) ^
      const DeepCollectionEquality().hash(contacts) ^
      const DeepCollectionEquality().hash(tosUri) ^
      const DeepCollectionEquality().hash(policyUri) ^
      const DeepCollectionEquality().hash(softwareId) ^
      const DeepCollectionEquality().hash(softwareVersion) ^
      const DeepCollectionEquality().hash(softwareStatement) ^
      const DeepCollectionEquality().hash(redirectUris) ^
      const DeepCollectionEquality().hash(postLogoutRedirectUris) ^
      const DeepCollectionEquality().hash(tokenEndpointAuthMethod) ^
      const DeepCollectionEquality().hash(grantTypes) ^
      const DeepCollectionEquality().hash(responseTypes) ^
      const DeepCollectionEquality().hash(public) ^
      const DeepCollectionEquality().hash(type) ^
      const DeepCollectionEquality().hash(disabled) ^
      const DeepCollectionEquality().hash(skipConsent) ^
      const DeepCollectionEquality().hash(enableEndSession) ^
      const DeepCollectionEquality().hash(referenceId) ^
      const DeepCollectionEquality().hash(metadata) ^
      runtimeType.hashCode;
}

extension $V1AdminListOauthClientsGet$Response$Clients$ItemExtension
    on V1AdminListOauthClientsGet$Response$Clients$Item {
  V1AdminListOauthClientsGet$Response$Clients$Item copyWith({
    String? clientId,
    String? clientSecret,
    double? clientSecretExpiresAt,
    String? scope,
    String? userId,
    double? clientIdIssuedAt,
    String? clientName,
    String? clientUri,
    String? logoUri,
    List<Object>? contacts,
    String? tosUri,
    String? policyUri,
    String? softwareId,
    String? softwareVersion,
    String? softwareStatement,
    List<Object>? redirectUris,
    List<Object>? postLogoutRedirectUris,
    enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod?
    tokenEndpointAuthMethod,
    List<Object>? grantTypes,
    List<Object>? responseTypes,
    bool? public,
    enums.V1AdminListOauthClientsGet$Response$Clients$ItemType? type,
    bool? disabled,
    bool? skipConsent,
    bool? enableEndSession,
    String? referenceId,
    Object? metadata,
  }) {
    return V1AdminListOauthClientsGet$Response$Clients$Item(
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      clientSecretExpiresAt:
          clientSecretExpiresAt ?? this.clientSecretExpiresAt,
      scope: scope ?? this.scope,
      userId: userId ?? this.userId,
      clientIdIssuedAt: clientIdIssuedAt ?? this.clientIdIssuedAt,
      clientName: clientName ?? this.clientName,
      clientUri: clientUri ?? this.clientUri,
      logoUri: logoUri ?? this.logoUri,
      contacts: contacts ?? this.contacts,
      tosUri: tosUri ?? this.tosUri,
      policyUri: policyUri ?? this.policyUri,
      softwareId: softwareId ?? this.softwareId,
      softwareVersion: softwareVersion ?? this.softwareVersion,
      softwareStatement: softwareStatement ?? this.softwareStatement,
      redirectUris: redirectUris ?? this.redirectUris,
      postLogoutRedirectUris:
          postLogoutRedirectUris ?? this.postLogoutRedirectUris,
      tokenEndpointAuthMethod:
          tokenEndpointAuthMethod ?? this.tokenEndpointAuthMethod,
      grantTypes: grantTypes ?? this.grantTypes,
      responseTypes: responseTypes ?? this.responseTypes,
      public: public ?? this.public,
      type: type ?? this.type,
      disabled: disabled ?? this.disabled,
      skipConsent: skipConsent ?? this.skipConsent,
      enableEndSession: enableEndSession ?? this.enableEndSession,
      referenceId: referenceId ?? this.referenceId,
      metadata: metadata ?? this.metadata,
    );
  }

  V1AdminListOauthClientsGet$Response$Clients$Item copyWithWrapped({
    Wrapped<String>? clientId,
    Wrapped<String?>? clientSecret,
    Wrapped<double?>? clientSecretExpiresAt,
    Wrapped<String?>? scope,
    Wrapped<String?>? userId,
    Wrapped<double?>? clientIdIssuedAt,
    Wrapped<String?>? clientName,
    Wrapped<String?>? clientUri,
    Wrapped<String?>? logoUri,
    Wrapped<List<Object>?>? contacts,
    Wrapped<String?>? tosUri,
    Wrapped<String?>? policyUri,
    Wrapped<String?>? softwareId,
    Wrapped<String?>? softwareVersion,
    Wrapped<String?>? softwareStatement,
    Wrapped<List<Object>?>? redirectUris,
    Wrapped<List<Object>?>? postLogoutRedirectUris,
    Wrapped<
      enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod?
    >?
    tokenEndpointAuthMethod,
    Wrapped<List<Object>?>? grantTypes,
    Wrapped<List<Object>?>? responseTypes,
    Wrapped<bool?>? public,
    Wrapped<enums.V1AdminListOauthClientsGet$Response$Clients$ItemType?>? type,
    Wrapped<bool?>? disabled,
    Wrapped<bool?>? skipConsent,
    Wrapped<bool?>? enableEndSession,
    Wrapped<String?>? referenceId,
    Wrapped<Object?>? metadata,
  }) {
    return V1AdminListOauthClientsGet$Response$Clients$Item(
      clientId: (clientId != null ? clientId.value : this.clientId),
      clientSecret: (clientSecret != null
          ? clientSecret.value
          : this.clientSecret),
      clientSecretExpiresAt: (clientSecretExpiresAt != null
          ? clientSecretExpiresAt.value
          : this.clientSecretExpiresAt),
      scope: (scope != null ? scope.value : this.scope),
      userId: (userId != null ? userId.value : this.userId),
      clientIdIssuedAt: (clientIdIssuedAt != null
          ? clientIdIssuedAt.value
          : this.clientIdIssuedAt),
      clientName: (clientName != null ? clientName.value : this.clientName),
      clientUri: (clientUri != null ? clientUri.value : this.clientUri),
      logoUri: (logoUri != null ? logoUri.value : this.logoUri),
      contacts: (contacts != null ? contacts.value : this.contacts),
      tosUri: (tosUri != null ? tosUri.value : this.tosUri),
      policyUri: (policyUri != null ? policyUri.value : this.policyUri),
      softwareId: (softwareId != null ? softwareId.value : this.softwareId),
      softwareVersion: (softwareVersion != null
          ? softwareVersion.value
          : this.softwareVersion),
      softwareStatement: (softwareStatement != null
          ? softwareStatement.value
          : this.softwareStatement),
      redirectUris: (redirectUris != null
          ? redirectUris.value
          : this.redirectUris),
      postLogoutRedirectUris: (postLogoutRedirectUris != null
          ? postLogoutRedirectUris.value
          : this.postLogoutRedirectUris),
      tokenEndpointAuthMethod: (tokenEndpointAuthMethod != null
          ? tokenEndpointAuthMethod.value
          : this.tokenEndpointAuthMethod),
      grantTypes: (grantTypes != null ? grantTypes.value : this.grantTypes),
      responseTypes: (responseTypes != null
          ? responseTypes.value
          : this.responseTypes),
      public: (public != null ? public.value : this.public),
      type: (type != null ? type.value : this.type),
      disabled: (disabled != null ? disabled.value : this.disabled),
      skipConsent: (skipConsent != null ? skipConsent.value : this.skipConsent),
      enableEndSession: (enableEndSession != null
          ? enableEndSession.value
          : this.enableEndSession),
      referenceId: (referenceId != null ? referenceId.value : this.referenceId),
      metadata: (metadata != null ? metadata.value : this.metadata),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserInfoGet$Response$SsoProviders$Item {
  const V1UserInfoGet$Response$SsoProviders$Item({
    required this.providerId,
    required this.providerType,
  });

  factory V1UserInfoGet$Response$SsoProviders$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserInfoGet$Response$SsoProviders$ItemFromJson(json);

  static const toJsonFactory = _$V1UserInfoGet$Response$SsoProviders$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserInfoGet$Response$SsoProviders$ItemToJson(this);

  @JsonKey(name: 'provider_id', includeIfNull: false)
  final String providerId;
  @JsonKey(
    name: 'provider_type',
    includeIfNull: false,
    toJson: v1UserInfoGet$Response$SsoProviders$ItemProviderTypeToJson,
    fromJson: v1UserInfoGet$Response$SsoProviders$ItemProviderTypeFromJson,
  )
  final enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType providerType;
  static const fromJsonFactory =
      _$V1UserInfoGet$Response$SsoProviders$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserInfoGet$Response$SsoProviders$Item &&
            (identical(other.providerId, providerId) ||
                const DeepCollectionEquality().equals(
                  other.providerId,
                  providerId,
                )) &&
            (identical(other.providerType, providerType) ||
                const DeepCollectionEquality().equals(
                  other.providerType,
                  providerType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(providerId) ^
      const DeepCollectionEquality().hash(providerType) ^
      runtimeType.hashCode;
}

extension $V1UserInfoGet$Response$SsoProviders$ItemExtension
    on V1UserInfoGet$Response$SsoProviders$Item {
  V1UserInfoGet$Response$SsoProviders$Item copyWith({
    String? providerId,
    enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType? providerType,
  }) {
    return V1UserInfoGet$Response$SsoProviders$Item(
      providerId: providerId ?? this.providerId,
      providerType: providerType ?? this.providerType,
    );
  }

  V1UserInfoGet$Response$SsoProviders$Item copyWithWrapped({
    Wrapped<String>? providerId,
    Wrapped<enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType>?
    providerType,
  }) {
    return V1UserInfoGet$Response$SsoProviders$Item(
      providerId: (providerId != null ? providerId.value : this.providerId),
      providerType: (providerType != null
          ? providerType.value
          : this.providerType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserGetUserGet$Response$User {
  const V1UserGetUserGet$Response$User({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.name,
    this.image,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory V1UserGetUserGet$Response$User.fromJson(Map<String, dynamic> json) =>
      _$V1UserGetUserGet$Response$UserFromJson(json);

  static const toJsonFactory = _$V1UserGetUserGet$Response$UserToJson;
  Map<String, dynamic> toJson() => _$V1UserGetUserGet$Response$UserToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'emailVerified', includeIfNull: false)
  final bool emailVerified;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'image', includeIfNull: false)
  final String? image;
  @JsonKey(name: 'role', includeIfNull: false)
  final String? role;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final DateTime updatedAt;
  static const fromJsonFactory = _$V1UserGetUserGet$Response$UserFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserGetUserGet$Response$User &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.image, image) ||
                const DeepCollectionEquality().equals(other.image, image)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(image) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $V1UserGetUserGet$Response$UserExtension
    on V1UserGetUserGet$Response$User {
  V1UserGetUserGet$Response$User copyWith({
    String? id,
    String? email,
    bool? emailVerified,
    String? name,
    String? image,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return V1UserGetUserGet$Response$User(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      name: name ?? this.name,
      image: image ?? this.image,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  V1UserGetUserGet$Response$User copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? email,
    Wrapped<bool>? emailVerified,
    Wrapped<String>? name,
    Wrapped<String?>? image,
    Wrapped<String?>? role,
    Wrapped<DateTime>? createdAt,
    Wrapped<DateTime>? updatedAt,
  }) {
    return V1UserGetUserGet$Response$User(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      name: (name != null ? name.value : this.name),
      image: (image != null ? image.value : this.image),
      role: (role != null ? role.value : this.role),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInEmailPost$Response$User {
  const V1UserSignInEmailPost$Response$User({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.name,
    this.image,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory V1UserSignInEmailPost$Response$User.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserSignInEmailPost$Response$UserFromJson(json);

  static const toJsonFactory = _$V1UserSignInEmailPost$Response$UserToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserSignInEmailPost$Response$UserToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'emailVerified', includeIfNull: false)
  final bool emailVerified;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'image', includeIfNull: false)
  final String? image;
  @JsonKey(name: 'role', includeIfNull: false)
  final String? role;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final DateTime updatedAt;
  static const fromJsonFactory = _$V1UserSignInEmailPost$Response$UserFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInEmailPost$Response$User &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.image, image) ||
                const DeepCollectionEquality().equals(other.image, image)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(image) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $V1UserSignInEmailPost$Response$UserExtension
    on V1UserSignInEmailPost$Response$User {
  V1UserSignInEmailPost$Response$User copyWith({
    String? id,
    String? email,
    bool? emailVerified,
    String? name,
    String? image,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return V1UserSignInEmailPost$Response$User(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      name: name ?? this.name,
      image: image ?? this.image,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  V1UserSignInEmailPost$Response$User copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? email,
    Wrapped<bool>? emailVerified,
    Wrapped<String>? name,
    Wrapped<String?>? image,
    Wrapped<String?>? role,
    Wrapped<DateTime>? createdAt,
    Wrapped<DateTime>? updatedAt,
  }) {
    return V1UserSignInEmailPost$Response$User(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      name: (name != null ? name.value : this.name),
      image: (image != null ? image.value : this.image),
      role: (role != null ? role.value : this.role),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignInSsoPost$Response$Data {
  const V1UserSignInSsoPost$Response$Data({
    required this.redirectUrl,
    required this.providerId,
  });

  factory V1UserSignInSsoPost$Response$Data.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserSignInSsoPost$Response$DataFromJson(json);

  static const toJsonFactory = _$V1UserSignInSsoPost$Response$DataToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserSignInSsoPost$Response$DataToJson(this);

  @JsonKey(name: 'redirectUrl', includeIfNull: false)
  final String redirectUrl;
  @JsonKey(name: 'providerId', includeIfNull: false)
  final String providerId;
  static const fromJsonFactory = _$V1UserSignInSsoPost$Response$DataFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignInSsoPost$Response$Data &&
            (identical(other.redirectUrl, redirectUrl) ||
                const DeepCollectionEquality().equals(
                  other.redirectUrl,
                  redirectUrl,
                )) &&
            (identical(other.providerId, providerId) ||
                const DeepCollectionEquality().equals(
                  other.providerId,
                  providerId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(redirectUrl) ^
      const DeepCollectionEquality().hash(providerId) ^
      runtimeType.hashCode;
}

extension $V1UserSignInSsoPost$Response$DataExtension
    on V1UserSignInSsoPost$Response$Data {
  V1UserSignInSsoPost$Response$Data copyWith({
    String? redirectUrl,
    String? providerId,
  }) {
    return V1UserSignInSsoPost$Response$Data(
      redirectUrl: redirectUrl ?? this.redirectUrl,
      providerId: providerId ?? this.providerId,
    );
  }

  V1UserSignInSsoPost$Response$Data copyWithWrapped({
    Wrapped<String>? redirectUrl,
    Wrapped<String>? providerId,
  }) {
    return V1UserSignInSsoPost$Response$Data(
      redirectUrl: (redirectUrl != null ? redirectUrl.value : this.redirectUrl),
      providerId: (providerId != null ? providerId.value : this.providerId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class V1UserSignUpEmailPost$Response$User {
  const V1UserSignUpEmailPost$Response$User({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.name,
    this.image,
    this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory V1UserSignUpEmailPost$Response$User.fromJson(
    Map<String, dynamic> json,
  ) => _$V1UserSignUpEmailPost$Response$UserFromJson(json);

  static const toJsonFactory = _$V1UserSignUpEmailPost$Response$UserToJson;
  Map<String, dynamic> toJson() =>
      _$V1UserSignUpEmailPost$Response$UserToJson(this);

  @JsonKey(name: 'id', includeIfNull: false)
  final String id;
  @JsonKey(name: 'email', includeIfNull: false)
  final String email;
  @JsonKey(name: 'emailVerified', includeIfNull: false)
  final bool emailVerified;
  @JsonKey(name: 'name', includeIfNull: false)
  final String name;
  @JsonKey(name: 'image', includeIfNull: false)
  final String? image;
  @JsonKey(name: 'role', includeIfNull: false)
  final String? role;
  @JsonKey(name: 'createdAt', includeIfNull: false)
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  final DateTime updatedAt;
  static const fromJsonFactory = _$V1UserSignUpEmailPost$Response$UserFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is V1UserSignUpEmailPost$Response$User &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.emailVerified, emailVerified) ||
                const DeepCollectionEquality().equals(
                  other.emailVerified,
                  emailVerified,
                )) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.image, image) ||
                const DeepCollectionEquality().equals(other.image, image)) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(emailVerified) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(image) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $V1UserSignUpEmailPost$Response$UserExtension
    on V1UserSignUpEmailPost$Response$User {
  V1UserSignUpEmailPost$Response$User copyWith({
    String? id,
    String? email,
    bool? emailVerified,
    String? name,
    String? image,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return V1UserSignUpEmailPost$Response$User(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      name: name ?? this.name,
      image: image ?? this.image,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  V1UserSignUpEmailPost$Response$User copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? email,
    Wrapped<bool>? emailVerified,
    Wrapped<String>? name,
    Wrapped<String?>? image,
    Wrapped<String?>? role,
    Wrapped<DateTime>? createdAt,
    Wrapped<DateTime>? updatedAt,
  }) {
    return V1UserSignUpEmailPost$Response$User(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
      emailVerified: (emailVerified != null
          ? emailVerified.value
          : this.emailVerified),
      name: (name != null ? name.value : this.name),
      image: (image != null ? image.value : this.image),
      role: (role != null ? role.value : this.role),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

String?
v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableToJson(
  enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
  v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
) {
  return v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
      ?.value;
}

String?
v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodToJson(
  enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
  v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
) {
  return v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
      .value;
}

enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodFromJson(
  Object? v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod, [
  enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
  defaultValue,
]) {
  return enums
          .V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
          ) ??
      defaultValue ??
      enums
          .V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
          .swaggerGeneratedUnknown;
}

enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableFromJson(
  Object? v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod, [
  enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod ==
      null) {
    return null;
  }
  return enums
          .V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
          ) ??
      defaultValue;
}

String
v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodExplodedListToJson(
  List<
    enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
  >?
  v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
) {
  return v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodListToJson(
  List<
    enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
  >?
  v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
) {
  if (v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod ==
      null) {
    return [];
  }

  return v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod>
v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodListFromJson(
  List? v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod, [
  List<
    enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
  >?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod ==
      null) {
    return defaultValue ?? [];
  }

  return v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
      .map(
        (e) =>
            v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod>?
v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableListFromJson(
  List? v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod, [
  List<
    enums.V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
  >?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod ==
      null) {
    return defaultValue;
  }

  return v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod
      .map(
        (e) =>
            v1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethodFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? v1AdminCreateOauthClientPost$Response$ClientGrantTypesNullableToJson(
  enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes?
  v1AdminCreateOauthClientPost$Response$ClientGrantTypes,
) {
  return v1AdminCreateOauthClientPost$Response$ClientGrantTypes?.value;
}

String? v1AdminCreateOauthClientPost$Response$ClientGrantTypesToJson(
  enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes
  v1AdminCreateOauthClientPost$Response$ClientGrantTypes,
) {
  return v1AdminCreateOauthClientPost$Response$ClientGrantTypes.value;
}

enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes
v1AdminCreateOauthClientPost$Response$ClientGrantTypesFromJson(
  Object? v1AdminCreateOauthClientPost$Response$ClientGrantTypes, [
  enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes? defaultValue,
]) {
  return enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminCreateOauthClientPost$Response$ClientGrantTypes,
          ) ??
      defaultValue ??
      enums
          .V1AdminCreateOauthClientPost$Response$ClientGrantTypes
          .swaggerGeneratedUnknown;
}

enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes?
v1AdminCreateOauthClientPost$Response$ClientGrantTypesNullableFromJson(
  Object? v1AdminCreateOauthClientPost$Response$ClientGrantTypes, [
  enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientGrantTypes == null) {
    return null;
  }
  return enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminCreateOauthClientPost$Response$ClientGrantTypes,
          ) ??
      defaultValue;
}

String v1AdminCreateOauthClientPost$Response$ClientGrantTypesExplodedListToJson(
  List<enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes>?
  v1AdminCreateOauthClientPost$Response$ClientGrantTypes,
) {
  return v1AdminCreateOauthClientPost$Response$ClientGrantTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminCreateOauthClientPost$Response$ClientGrantTypesListToJson(
  List<enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes>?
  v1AdminCreateOauthClientPost$Response$ClientGrantTypes,
) {
  if (v1AdminCreateOauthClientPost$Response$ClientGrantTypes == null) {
    return [];
  }

  return v1AdminCreateOauthClientPost$Response$ClientGrantTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes>
v1AdminCreateOauthClientPost$Response$ClientGrantTypesListFromJson(
  List? v1AdminCreateOauthClientPost$Response$ClientGrantTypes, [
  List<enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes>?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientGrantTypes == null) {
    return defaultValue ?? [];
  }

  return v1AdminCreateOauthClientPost$Response$ClientGrantTypes
      .map(
        (e) => v1AdminCreateOauthClientPost$Response$ClientGrantTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes>?
v1AdminCreateOauthClientPost$Response$ClientGrantTypesNullableListFromJson(
  List? v1AdminCreateOauthClientPost$Response$ClientGrantTypes, [
  List<enums.V1AdminCreateOauthClientPost$Response$ClientGrantTypes>?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientGrantTypes == null) {
    return defaultValue;
  }

  return v1AdminCreateOauthClientPost$Response$ClientGrantTypes
      .map(
        (e) => v1AdminCreateOauthClientPost$Response$ClientGrantTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? v1AdminCreateOauthClientPost$Response$ClientResponseTypesNullableToJson(
  enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes?
  v1AdminCreateOauthClientPost$Response$ClientResponseTypes,
) {
  return v1AdminCreateOauthClientPost$Response$ClientResponseTypes?.value;
}

String? v1AdminCreateOauthClientPost$Response$ClientResponseTypesToJson(
  enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes
  v1AdminCreateOauthClientPost$Response$ClientResponseTypes,
) {
  return v1AdminCreateOauthClientPost$Response$ClientResponseTypes.value;
}

enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes
v1AdminCreateOauthClientPost$Response$ClientResponseTypesFromJson(
  Object? v1AdminCreateOauthClientPost$Response$ClientResponseTypes, [
  enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes? defaultValue,
]) {
  return enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminCreateOauthClientPost$Response$ClientResponseTypes,
          ) ??
      defaultValue ??
      enums
          .V1AdminCreateOauthClientPost$Response$ClientResponseTypes
          .swaggerGeneratedUnknown;
}

enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes?
v1AdminCreateOauthClientPost$Response$ClientResponseTypesNullableFromJson(
  Object? v1AdminCreateOauthClientPost$Response$ClientResponseTypes, [
  enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientResponseTypes == null) {
    return null;
  }
  return enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminCreateOauthClientPost$Response$ClientResponseTypes,
          ) ??
      defaultValue;
}

String
v1AdminCreateOauthClientPost$Response$ClientResponseTypesExplodedListToJson(
  List<enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes>?
  v1AdminCreateOauthClientPost$Response$ClientResponseTypes,
) {
  return v1AdminCreateOauthClientPost$Response$ClientResponseTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
v1AdminCreateOauthClientPost$Response$ClientResponseTypesListToJson(
  List<enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes>?
  v1AdminCreateOauthClientPost$Response$ClientResponseTypes,
) {
  if (v1AdminCreateOauthClientPost$Response$ClientResponseTypes == null) {
    return [];
  }

  return v1AdminCreateOauthClientPost$Response$ClientResponseTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes>
v1AdminCreateOauthClientPost$Response$ClientResponseTypesListFromJson(
  List? v1AdminCreateOauthClientPost$Response$ClientResponseTypes, [
  List<enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes>?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientResponseTypes == null) {
    return defaultValue ?? [];
  }

  return v1AdminCreateOauthClientPost$Response$ClientResponseTypes
      .map(
        (e) =>
            v1AdminCreateOauthClientPost$Response$ClientResponseTypesFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes>?
v1AdminCreateOauthClientPost$Response$ClientResponseTypesNullableListFromJson(
  List? v1AdminCreateOauthClientPost$Response$ClientResponseTypes, [
  List<enums.V1AdminCreateOauthClientPost$Response$ClientResponseTypes>?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientResponseTypes == null) {
    return defaultValue;
  }

  return v1AdminCreateOauthClientPost$Response$ClientResponseTypes
      .map(
        (e) =>
            v1AdminCreateOauthClientPost$Response$ClientResponseTypesFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? v1AdminCreateOauthClientPost$Response$ClientTypeNullableToJson(
  enums.V1AdminCreateOauthClientPost$Response$ClientType?
  v1AdminCreateOauthClientPost$Response$ClientType,
) {
  return v1AdminCreateOauthClientPost$Response$ClientType?.value;
}

String? v1AdminCreateOauthClientPost$Response$ClientTypeToJson(
  enums.V1AdminCreateOauthClientPost$Response$ClientType
  v1AdminCreateOauthClientPost$Response$ClientType,
) {
  return v1AdminCreateOauthClientPost$Response$ClientType.value;
}

enums.V1AdminCreateOauthClientPost$Response$ClientType
v1AdminCreateOauthClientPost$Response$ClientTypeFromJson(
  Object? v1AdminCreateOauthClientPost$Response$ClientType, [
  enums.V1AdminCreateOauthClientPost$Response$ClientType? defaultValue,
]) {
  return enums.V1AdminCreateOauthClientPost$Response$ClientType.values
          .firstWhereOrNull(
            (e) => e.value == v1AdminCreateOauthClientPost$Response$ClientType,
          ) ??
      defaultValue ??
      enums
          .V1AdminCreateOauthClientPost$Response$ClientType
          .swaggerGeneratedUnknown;
}

enums.V1AdminCreateOauthClientPost$Response$ClientType?
v1AdminCreateOauthClientPost$Response$ClientTypeNullableFromJson(
  Object? v1AdminCreateOauthClientPost$Response$ClientType, [
  enums.V1AdminCreateOauthClientPost$Response$ClientType? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientType == null) {
    return null;
  }
  return enums.V1AdminCreateOauthClientPost$Response$ClientType.values
          .firstWhereOrNull(
            (e) => e.value == v1AdminCreateOauthClientPost$Response$ClientType,
          ) ??
      defaultValue;
}

String v1AdminCreateOauthClientPost$Response$ClientTypeExplodedListToJson(
  List<enums.V1AdminCreateOauthClientPost$Response$ClientType>?
  v1AdminCreateOauthClientPost$Response$ClientType,
) {
  return v1AdminCreateOauthClientPost$Response$ClientType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminCreateOauthClientPost$Response$ClientTypeListToJson(
  List<enums.V1AdminCreateOauthClientPost$Response$ClientType>?
  v1AdminCreateOauthClientPost$Response$ClientType,
) {
  if (v1AdminCreateOauthClientPost$Response$ClientType == null) {
    return [];
  }

  return v1AdminCreateOauthClientPost$Response$ClientType
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$Response$ClientType>
v1AdminCreateOauthClientPost$Response$ClientTypeListFromJson(
  List? v1AdminCreateOauthClientPost$Response$ClientType, [
  List<enums.V1AdminCreateOauthClientPost$Response$ClientType>? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientType == null) {
    return defaultValue ?? [];
  }

  return v1AdminCreateOauthClientPost$Response$ClientType
      .map(
        (e) => v1AdminCreateOauthClientPost$Response$ClientTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$Response$ClientType>?
v1AdminCreateOauthClientPost$Response$ClientTypeNullableListFromJson(
  List? v1AdminCreateOauthClientPost$Response$ClientType, [
  List<enums.V1AdminCreateOauthClientPost$Response$ClientType>? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$Response$ClientType == null) {
    return defaultValue;
  }

  return v1AdminCreateOauthClientPost$Response$ClientType
      .map(
        (e) => v1AdminCreateOauthClientPost$Response$ClientTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String?
v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableToJson(
  enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
  v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
      ?.value;
}

String?
v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodToJson(
  enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
  v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
      .value;
}

enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodFromJson(
  Object? v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod, [
  enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
  defaultValue,
]) {
  return enums
          .V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
          ) ??
      defaultValue ??
      enums
          .V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
          .swaggerGeneratedUnknown;
}

enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableFromJson(
  Object? v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod, [
  enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod?
  defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod ==
      null) {
    return null;
  }
  return enums
          .V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
          ) ??
      defaultValue;
}

String
v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodExplodedListToJson(
  List<
    enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
  >?
  v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodListToJson(
  List<
    enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
  >?
  v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod,
) {
  if (v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod ==
      null) {
    return [];
  }

  return v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod>
v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodListFromJson(
  List? v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod, [
  List<
    enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
  >?
  defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod ==
      null) {
    return defaultValue ?? [];
  }

  return v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
      .map(
        (e) =>
            v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod>?
v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodNullableListFromJson(
  List? v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod, [
  List<
    enums.V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
  >?
  defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod ==
      null) {
    return defaultValue;
  }

  return v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod
      .map(
        (e) =>
            v1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethodFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? v1AdminUpdateOauthClientPost$Response$ClientGrantTypesNullableToJson(
  enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes?
  v1AdminUpdateOauthClientPost$Response$ClientGrantTypes,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientGrantTypes?.value;
}

String? v1AdminUpdateOauthClientPost$Response$ClientGrantTypesToJson(
  enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes
  v1AdminUpdateOauthClientPost$Response$ClientGrantTypes,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientGrantTypes.value;
}

enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes
v1AdminUpdateOauthClientPost$Response$ClientGrantTypesFromJson(
  Object? v1AdminUpdateOauthClientPost$Response$ClientGrantTypes, [
  enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes? defaultValue,
]) {
  return enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminUpdateOauthClientPost$Response$ClientGrantTypes,
          ) ??
      defaultValue ??
      enums
          .V1AdminUpdateOauthClientPost$Response$ClientGrantTypes
          .swaggerGeneratedUnknown;
}

enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes?
v1AdminUpdateOauthClientPost$Response$ClientGrantTypesNullableFromJson(
  Object? v1AdminUpdateOauthClientPost$Response$ClientGrantTypes, [
  enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientGrantTypes == null) {
    return null;
  }
  return enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminUpdateOauthClientPost$Response$ClientGrantTypes,
          ) ??
      defaultValue;
}

String v1AdminUpdateOauthClientPost$Response$ClientGrantTypesExplodedListToJson(
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes>?
  v1AdminUpdateOauthClientPost$Response$ClientGrantTypes,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientGrantTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminUpdateOauthClientPost$Response$ClientGrantTypesListToJson(
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes>?
  v1AdminUpdateOauthClientPost$Response$ClientGrantTypes,
) {
  if (v1AdminUpdateOauthClientPost$Response$ClientGrantTypes == null) {
    return [];
  }

  return v1AdminUpdateOauthClientPost$Response$ClientGrantTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes>
v1AdminUpdateOauthClientPost$Response$ClientGrantTypesListFromJson(
  List? v1AdminUpdateOauthClientPost$Response$ClientGrantTypes, [
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes>?
  defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientGrantTypes == null) {
    return defaultValue ?? [];
  }

  return v1AdminUpdateOauthClientPost$Response$ClientGrantTypes
      .map(
        (e) => v1AdminUpdateOauthClientPost$Response$ClientGrantTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes>?
v1AdminUpdateOauthClientPost$Response$ClientGrantTypesNullableListFromJson(
  List? v1AdminUpdateOauthClientPost$Response$ClientGrantTypes, [
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientGrantTypes>?
  defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientGrantTypes == null) {
    return defaultValue;
  }

  return v1AdminUpdateOauthClientPost$Response$ClientGrantTypes
      .map(
        (e) => v1AdminUpdateOauthClientPost$Response$ClientGrantTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? v1AdminUpdateOauthClientPost$Response$ClientResponseTypesNullableToJson(
  enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes?
  v1AdminUpdateOauthClientPost$Response$ClientResponseTypes,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientResponseTypes?.value;
}

String? v1AdminUpdateOauthClientPost$Response$ClientResponseTypesToJson(
  enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes
  v1AdminUpdateOauthClientPost$Response$ClientResponseTypes,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientResponseTypes.value;
}

enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes
v1AdminUpdateOauthClientPost$Response$ClientResponseTypesFromJson(
  Object? v1AdminUpdateOauthClientPost$Response$ClientResponseTypes, [
  enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes? defaultValue,
]) {
  return enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminUpdateOauthClientPost$Response$ClientResponseTypes,
          ) ??
      defaultValue ??
      enums
          .V1AdminUpdateOauthClientPost$Response$ClientResponseTypes
          .swaggerGeneratedUnknown;
}

enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes?
v1AdminUpdateOauthClientPost$Response$ClientResponseTypesNullableFromJson(
  Object? v1AdminUpdateOauthClientPost$Response$ClientResponseTypes, [
  enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientResponseTypes == null) {
    return null;
  }
  return enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminUpdateOauthClientPost$Response$ClientResponseTypes,
          ) ??
      defaultValue;
}

String
v1AdminUpdateOauthClientPost$Response$ClientResponseTypesExplodedListToJson(
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes>?
  v1AdminUpdateOauthClientPost$Response$ClientResponseTypes,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientResponseTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
v1AdminUpdateOauthClientPost$Response$ClientResponseTypesListToJson(
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes>?
  v1AdminUpdateOauthClientPost$Response$ClientResponseTypes,
) {
  if (v1AdminUpdateOauthClientPost$Response$ClientResponseTypes == null) {
    return [];
  }

  return v1AdminUpdateOauthClientPost$Response$ClientResponseTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes>
v1AdminUpdateOauthClientPost$Response$ClientResponseTypesListFromJson(
  List? v1AdminUpdateOauthClientPost$Response$ClientResponseTypes, [
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes>?
  defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientResponseTypes == null) {
    return defaultValue ?? [];
  }

  return v1AdminUpdateOauthClientPost$Response$ClientResponseTypes
      .map(
        (e) =>
            v1AdminUpdateOauthClientPost$Response$ClientResponseTypesFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes>?
v1AdminUpdateOauthClientPost$Response$ClientResponseTypesNullableListFromJson(
  List? v1AdminUpdateOauthClientPost$Response$ClientResponseTypes, [
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientResponseTypes>?
  defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientResponseTypes == null) {
    return defaultValue;
  }

  return v1AdminUpdateOauthClientPost$Response$ClientResponseTypes
      .map(
        (e) =>
            v1AdminUpdateOauthClientPost$Response$ClientResponseTypesFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? v1AdminUpdateOauthClientPost$Response$ClientTypeNullableToJson(
  enums.V1AdminUpdateOauthClientPost$Response$ClientType?
  v1AdminUpdateOauthClientPost$Response$ClientType,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientType?.value;
}

String? v1AdminUpdateOauthClientPost$Response$ClientTypeToJson(
  enums.V1AdminUpdateOauthClientPost$Response$ClientType
  v1AdminUpdateOauthClientPost$Response$ClientType,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientType.value;
}

enums.V1AdminUpdateOauthClientPost$Response$ClientType
v1AdminUpdateOauthClientPost$Response$ClientTypeFromJson(
  Object? v1AdminUpdateOauthClientPost$Response$ClientType, [
  enums.V1AdminUpdateOauthClientPost$Response$ClientType? defaultValue,
]) {
  return enums.V1AdminUpdateOauthClientPost$Response$ClientType.values
          .firstWhereOrNull(
            (e) => e.value == v1AdminUpdateOauthClientPost$Response$ClientType,
          ) ??
      defaultValue ??
      enums
          .V1AdminUpdateOauthClientPost$Response$ClientType
          .swaggerGeneratedUnknown;
}

enums.V1AdminUpdateOauthClientPost$Response$ClientType?
v1AdminUpdateOauthClientPost$Response$ClientTypeNullableFromJson(
  Object? v1AdminUpdateOauthClientPost$Response$ClientType, [
  enums.V1AdminUpdateOauthClientPost$Response$ClientType? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientType == null) {
    return null;
  }
  return enums.V1AdminUpdateOauthClientPost$Response$ClientType.values
          .firstWhereOrNull(
            (e) => e.value == v1AdminUpdateOauthClientPost$Response$ClientType,
          ) ??
      defaultValue;
}

String v1AdminUpdateOauthClientPost$Response$ClientTypeExplodedListToJson(
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientType>?
  v1AdminUpdateOauthClientPost$Response$ClientType,
) {
  return v1AdminUpdateOauthClientPost$Response$ClientType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminUpdateOauthClientPost$Response$ClientTypeListToJson(
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientType>?
  v1AdminUpdateOauthClientPost$Response$ClientType,
) {
  if (v1AdminUpdateOauthClientPost$Response$ClientType == null) {
    return [];
  }

  return v1AdminUpdateOauthClientPost$Response$ClientType
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$Response$ClientType>
v1AdminUpdateOauthClientPost$Response$ClientTypeListFromJson(
  List? v1AdminUpdateOauthClientPost$Response$ClientType, [
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientType>? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientType == null) {
    return defaultValue ?? [];
  }

  return v1AdminUpdateOauthClientPost$Response$ClientType
      .map(
        (e) => v1AdminUpdateOauthClientPost$Response$ClientTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$Response$ClientType>?
v1AdminUpdateOauthClientPost$Response$ClientTypeNullableListFromJson(
  List? v1AdminUpdateOauthClientPost$Response$ClientType, [
  List<enums.V1AdminUpdateOauthClientPost$Response$ClientType>? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$Response$ClientType == null) {
    return defaultValue;
  }

  return v1AdminUpdateOauthClientPost$Response$ClientType
      .map(
        (e) => v1AdminUpdateOauthClientPost$Response$ClientTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? v1AdminListUsersGetSearchFieldNullableToJson(
  enums.V1AdminListUsersGetSearchField? v1AdminListUsersGetSearchField,
) {
  return v1AdminListUsersGetSearchField?.value;
}

String? v1AdminListUsersGetSearchFieldToJson(
  enums.V1AdminListUsersGetSearchField v1AdminListUsersGetSearchField,
) {
  return v1AdminListUsersGetSearchField.value;
}

enums.V1AdminListUsersGetSearchField v1AdminListUsersGetSearchFieldFromJson(
  Object? v1AdminListUsersGetSearchField, [
  enums.V1AdminListUsersGetSearchField? defaultValue,
]) {
  return enums.V1AdminListUsersGetSearchField.values.firstWhereOrNull(
        (e) => e.value == v1AdminListUsersGetSearchField,
      ) ??
      defaultValue ??
      enums.V1AdminListUsersGetSearchField.swaggerGeneratedUnknown;
}

enums.V1AdminListUsersGetSearchField?
v1AdminListUsersGetSearchFieldNullableFromJson(
  Object? v1AdminListUsersGetSearchField, [
  enums.V1AdminListUsersGetSearchField? defaultValue,
]) {
  if (v1AdminListUsersGetSearchField == null) {
    return null;
  }
  return enums.V1AdminListUsersGetSearchField.values.firstWhereOrNull(
        (e) => e.value == v1AdminListUsersGetSearchField,
      ) ??
      defaultValue;
}

String v1AdminListUsersGetSearchFieldExplodedListToJson(
  List<enums.V1AdminListUsersGetSearchField>? v1AdminListUsersGetSearchField,
) {
  return v1AdminListUsersGetSearchField?.map((e) => e.value!).join(',') ?? '';
}

List<String> v1AdminListUsersGetSearchFieldListToJson(
  List<enums.V1AdminListUsersGetSearchField>? v1AdminListUsersGetSearchField,
) {
  if (v1AdminListUsersGetSearchField == null) {
    return [];
  }

  return v1AdminListUsersGetSearchField.map((e) => e.value!).toList();
}

List<enums.V1AdminListUsersGetSearchField>
v1AdminListUsersGetSearchFieldListFromJson(
  List? v1AdminListUsersGetSearchField, [
  List<enums.V1AdminListUsersGetSearchField>? defaultValue,
]) {
  if (v1AdminListUsersGetSearchField == null) {
    return defaultValue ?? [];
  }

  return v1AdminListUsersGetSearchField
      .map((e) => v1AdminListUsersGetSearchFieldFromJson(e.toString()))
      .toList();
}

List<enums.V1AdminListUsersGetSearchField>?
v1AdminListUsersGetSearchFieldNullableListFromJson(
  List? v1AdminListUsersGetSearchField, [
  List<enums.V1AdminListUsersGetSearchField>? defaultValue,
]) {
  if (v1AdminListUsersGetSearchField == null) {
    return defaultValue;
  }

  return v1AdminListUsersGetSearchField
      .map((e) => v1AdminListUsersGetSearchFieldFromJson(e.toString()))
      .toList();
}

String? v1AdminListUsersGetSortByNullableToJson(
  enums.V1AdminListUsersGetSortBy? v1AdminListUsersGetSortBy,
) {
  return v1AdminListUsersGetSortBy?.value;
}

String? v1AdminListUsersGetSortByToJson(
  enums.V1AdminListUsersGetSortBy v1AdminListUsersGetSortBy,
) {
  return v1AdminListUsersGetSortBy.value;
}

enums.V1AdminListUsersGetSortBy v1AdminListUsersGetSortByFromJson(
  Object? v1AdminListUsersGetSortBy, [
  enums.V1AdminListUsersGetSortBy? defaultValue,
]) {
  return enums.V1AdminListUsersGetSortBy.values.firstWhereOrNull(
        (e) => e.value == v1AdminListUsersGetSortBy,
      ) ??
      defaultValue ??
      enums.V1AdminListUsersGetSortBy.swaggerGeneratedUnknown;
}

enums.V1AdminListUsersGetSortBy? v1AdminListUsersGetSortByNullableFromJson(
  Object? v1AdminListUsersGetSortBy, [
  enums.V1AdminListUsersGetSortBy? defaultValue,
]) {
  if (v1AdminListUsersGetSortBy == null) {
    return null;
  }
  return enums.V1AdminListUsersGetSortBy.values.firstWhereOrNull(
        (e) => e.value == v1AdminListUsersGetSortBy,
      ) ??
      defaultValue;
}

String v1AdminListUsersGetSortByExplodedListToJson(
  List<enums.V1AdminListUsersGetSortBy>? v1AdminListUsersGetSortBy,
) {
  return v1AdminListUsersGetSortBy?.map((e) => e.value!).join(',') ?? '';
}

List<String> v1AdminListUsersGetSortByListToJson(
  List<enums.V1AdminListUsersGetSortBy>? v1AdminListUsersGetSortBy,
) {
  if (v1AdminListUsersGetSortBy == null) {
    return [];
  }

  return v1AdminListUsersGetSortBy.map((e) => e.value!).toList();
}

List<enums.V1AdminListUsersGetSortBy> v1AdminListUsersGetSortByListFromJson(
  List? v1AdminListUsersGetSortBy, [
  List<enums.V1AdminListUsersGetSortBy>? defaultValue,
]) {
  if (v1AdminListUsersGetSortBy == null) {
    return defaultValue ?? [];
  }

  return v1AdminListUsersGetSortBy
      .map((e) => v1AdminListUsersGetSortByFromJson(e.toString()))
      .toList();
}

List<enums.V1AdminListUsersGetSortBy>?
v1AdminListUsersGetSortByNullableListFromJson(
  List? v1AdminListUsersGetSortBy, [
  List<enums.V1AdminListUsersGetSortBy>? defaultValue,
]) {
  if (v1AdminListUsersGetSortBy == null) {
    return defaultValue;
  }

  return v1AdminListUsersGetSortBy
      .map((e) => v1AdminListUsersGetSortByFromJson(e.toString()))
      .toList();
}

String? v1AdminListUsersGetSortDirectionNullableToJson(
  enums.V1AdminListUsersGetSortDirection? v1AdminListUsersGetSortDirection,
) {
  return v1AdminListUsersGetSortDirection?.value;
}

String? v1AdminListUsersGetSortDirectionToJson(
  enums.V1AdminListUsersGetSortDirection v1AdminListUsersGetSortDirection,
) {
  return v1AdminListUsersGetSortDirection.value;
}

enums.V1AdminListUsersGetSortDirection v1AdminListUsersGetSortDirectionFromJson(
  Object? v1AdminListUsersGetSortDirection, [
  enums.V1AdminListUsersGetSortDirection? defaultValue,
]) {
  return enums.V1AdminListUsersGetSortDirection.values.firstWhereOrNull(
        (e) => e.value == v1AdminListUsersGetSortDirection,
      ) ??
      defaultValue ??
      enums.V1AdminListUsersGetSortDirection.swaggerGeneratedUnknown;
}

enums.V1AdminListUsersGetSortDirection?
v1AdminListUsersGetSortDirectionNullableFromJson(
  Object? v1AdminListUsersGetSortDirection, [
  enums.V1AdminListUsersGetSortDirection? defaultValue,
]) {
  if (v1AdminListUsersGetSortDirection == null) {
    return null;
  }
  return enums.V1AdminListUsersGetSortDirection.values.firstWhereOrNull(
        (e) => e.value == v1AdminListUsersGetSortDirection,
      ) ??
      defaultValue;
}

String v1AdminListUsersGetSortDirectionExplodedListToJson(
  List<enums.V1AdminListUsersGetSortDirection>?
  v1AdminListUsersGetSortDirection,
) {
  return v1AdminListUsersGetSortDirection?.map((e) => e.value!).join(',') ?? '';
}

List<String> v1AdminListUsersGetSortDirectionListToJson(
  List<enums.V1AdminListUsersGetSortDirection>?
  v1AdminListUsersGetSortDirection,
) {
  if (v1AdminListUsersGetSortDirection == null) {
    return [];
  }

  return v1AdminListUsersGetSortDirection.map((e) => e.value!).toList();
}

List<enums.V1AdminListUsersGetSortDirection>
v1AdminListUsersGetSortDirectionListFromJson(
  List? v1AdminListUsersGetSortDirection, [
  List<enums.V1AdminListUsersGetSortDirection>? defaultValue,
]) {
  if (v1AdminListUsersGetSortDirection == null) {
    return defaultValue ?? [];
  }

  return v1AdminListUsersGetSortDirection
      .map((e) => v1AdminListUsersGetSortDirectionFromJson(e.toString()))
      .toList();
}

List<enums.V1AdminListUsersGetSortDirection>?
v1AdminListUsersGetSortDirectionNullableListFromJson(
  List? v1AdminListUsersGetSortDirection, [
  List<enums.V1AdminListUsersGetSortDirection>? defaultValue,
]) {
  if (v1AdminListUsersGetSortDirection == null) {
    return defaultValue;
  }

  return v1AdminListUsersGetSortDirection
      .map((e) => v1AdminListUsersGetSortDirectionFromJson(e.toString()))
      .toList();
}

String?
v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodNullableToJson(
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod?
  v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
      ?.value;
}

String?
v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodToJson(
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
  v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
      .value;
}

enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodFromJson(
  Object?
  v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod, [
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod?
  defaultValue,
]) {
  return enums
          .V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod,
          ) ??
      defaultValue ??
      enums
          .V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
          .swaggerGeneratedUnknown;
}

enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod?
v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodNullableFromJson(
  Object?
  v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod, [
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod ==
      null) {
    return null;
  }
  return enums
          .V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod,
          ) ??
      defaultValue;
}

String
v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodExplodedListToJson(
  List<
    enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
  >?
  v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodListToJson(
  List<
    enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
  >?
  v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod,
) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod ==
      null) {
    return [];
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
      .map((e) => e.value!)
      .toList();
}

List<
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
>
v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodListFromJson(
  List?
  v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod, [
  List<
    enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
  >?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod ==
      null) {
    return defaultValue ?? [];
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
      .map(
        (e) =>
            v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
>?
v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodNullableListFromJson(
  List?
  v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod, [
  List<
    enums.V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
  >?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod ==
      null) {
    return defaultValue;
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod
      .map(
        (e) =>
            v1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethodFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String?
v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypesNullableToJson(
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes?
  v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes?.value;
}

String? v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypesToJson(
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes
  v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes.value;
}

enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes
v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypesFromJson(
  Object? v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes, [
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes?
  defaultValue,
]) {
  return enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes,
          ) ??
      defaultValue ??
      enums
          .V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes
          .swaggerGeneratedUnknown;
}

enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes?
v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypesNullableFromJson(
  Object? v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes, [
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes == null) {
    return null;
  }
  return enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes,
          ) ??
      defaultValue;
}

String
v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypesExplodedListToJson(
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes>?
  v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypesListToJson(
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes>?
  v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes,
) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes == null) {
    return [];
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes>
v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypesListFromJson(
  List? v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes, [
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes>?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes == null) {
    return defaultValue ?? [];
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes
      .map(
        (e) =>
            v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypesFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes>?
v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypesNullableListFromJson(
  List? v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes, [
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes>?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes == null) {
    return defaultValue;
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes
      .map(
        (e) =>
            v1AdminListOauthClientsGet$Response$Clients$ItemGrantTypesFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String?
v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypesNullableToJson(
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes?
  v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes?.value;
}

String? v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypesToJson(
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes
  v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes.value;
}

enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes
v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypesFromJson(
  Object? v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes, [
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes?
  defaultValue,
]) {
  return enums
          .V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes,
          ) ??
      defaultValue ??
      enums
          .V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes
          .swaggerGeneratedUnknown;
}

enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes?
v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypesNullableFromJson(
  Object? v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes, [
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes == null) {
    return null;
  }
  return enums
          .V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes,
          ) ??
      defaultValue;
}

String
v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypesExplodedListToJson(
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes>?
  v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypesListToJson(
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes>?
  v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes,
) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes == null) {
    return [];
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes>
v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypesListFromJson(
  List? v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes, [
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes>?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes == null) {
    return defaultValue ?? [];
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes
      .map(
        (e) =>
            v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypesFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes>?
v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypesNullableListFromJson(
  List? v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes, [
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes>?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes == null) {
    return defaultValue;
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes
      .map(
        (e) =>
            v1AdminListOauthClientsGet$Response$Clients$ItemResponseTypesFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? v1AdminListOauthClientsGet$Response$Clients$ItemTypeNullableToJson(
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemType?
  v1AdminListOauthClientsGet$Response$Clients$ItemType,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemType?.value;
}

String? v1AdminListOauthClientsGet$Response$Clients$ItemTypeToJson(
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemType
  v1AdminListOauthClientsGet$Response$Clients$ItemType,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemType.value;
}

enums.V1AdminListOauthClientsGet$Response$Clients$ItemType
v1AdminListOauthClientsGet$Response$Clients$ItemTypeFromJson(
  Object? v1AdminListOauthClientsGet$Response$Clients$ItemType, [
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemType? defaultValue,
]) {
  return enums.V1AdminListOauthClientsGet$Response$Clients$ItemType.values
          .firstWhereOrNull(
            (e) =>
                e.value == v1AdminListOauthClientsGet$Response$Clients$ItemType,
          ) ??
      defaultValue ??
      enums
          .V1AdminListOauthClientsGet$Response$Clients$ItemType
          .swaggerGeneratedUnknown;
}

enums.V1AdminListOauthClientsGet$Response$Clients$ItemType?
v1AdminListOauthClientsGet$Response$Clients$ItemTypeNullableFromJson(
  Object? v1AdminListOauthClientsGet$Response$Clients$ItemType, [
  enums.V1AdminListOauthClientsGet$Response$Clients$ItemType? defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemType == null) {
    return null;
  }
  return enums.V1AdminListOauthClientsGet$Response$Clients$ItemType.values
          .firstWhereOrNull(
            (e) =>
                e.value == v1AdminListOauthClientsGet$Response$Clients$ItemType,
          ) ??
      defaultValue;
}

String v1AdminListOauthClientsGet$Response$Clients$ItemTypeExplodedListToJson(
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemType>?
  v1AdminListOauthClientsGet$Response$Clients$ItemType,
) {
  return v1AdminListOauthClientsGet$Response$Clients$ItemType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminListOauthClientsGet$Response$Clients$ItemTypeListToJson(
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemType>?
  v1AdminListOauthClientsGet$Response$Clients$ItemType,
) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemType == null) {
    return [];
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemType
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemType>
v1AdminListOauthClientsGet$Response$Clients$ItemTypeListFromJson(
  List? v1AdminListOauthClientsGet$Response$Clients$ItemType, [
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemType>?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemType == null) {
    return defaultValue ?? [];
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemType
      .map(
        (e) => v1AdminListOauthClientsGet$Response$Clients$ItemTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemType>?
v1AdminListOauthClientsGet$Response$Clients$ItemTypeNullableListFromJson(
  List? v1AdminListOauthClientsGet$Response$Clients$ItemType, [
  List<enums.V1AdminListOauthClientsGet$Response$Clients$ItemType>?
  defaultValue,
]) {
  if (v1AdminListOauthClientsGet$Response$Clients$ItemType == null) {
    return defaultValue;
  }

  return v1AdminListOauthClientsGet$Response$Clients$ItemType
      .map(
        (e) => v1AdminListOauthClientsGet$Response$Clients$ItemTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? v1UserInfoGet$Response$SsoProviders$ItemProviderTypeNullableToJson(
  enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType?
  v1UserInfoGet$Response$SsoProviders$ItemProviderType,
) {
  return v1UserInfoGet$Response$SsoProviders$ItemProviderType?.value;
}

String? v1UserInfoGet$Response$SsoProviders$ItemProviderTypeToJson(
  enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType
  v1UserInfoGet$Response$SsoProviders$ItemProviderType,
) {
  return v1UserInfoGet$Response$SsoProviders$ItemProviderType.value;
}

enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType
v1UserInfoGet$Response$SsoProviders$ItemProviderTypeFromJson(
  Object? v1UserInfoGet$Response$SsoProviders$ItemProviderType, [
  enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType? defaultValue,
]) {
  return enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType.values
          .firstWhereOrNull(
            (e) =>
                e.value == v1UserInfoGet$Response$SsoProviders$ItemProviderType,
          ) ??
      defaultValue ??
      enums
          .V1UserInfoGet$Response$SsoProviders$ItemProviderType
          .swaggerGeneratedUnknown;
}

enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType?
v1UserInfoGet$Response$SsoProviders$ItemProviderTypeNullableFromJson(
  Object? v1UserInfoGet$Response$SsoProviders$ItemProviderType, [
  enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType? defaultValue,
]) {
  if (v1UserInfoGet$Response$SsoProviders$ItemProviderType == null) {
    return null;
  }
  return enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType.values
          .firstWhereOrNull(
            (e) =>
                e.value == v1UserInfoGet$Response$SsoProviders$ItemProviderType,
          ) ??
      defaultValue;
}

String v1UserInfoGet$Response$SsoProviders$ItemProviderTypeExplodedListToJson(
  List<enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType>?
  v1UserInfoGet$Response$SsoProviders$ItemProviderType,
) {
  return v1UserInfoGet$Response$SsoProviders$ItemProviderType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1UserInfoGet$Response$SsoProviders$ItemProviderTypeListToJson(
  List<enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType>?
  v1UserInfoGet$Response$SsoProviders$ItemProviderType,
) {
  if (v1UserInfoGet$Response$SsoProviders$ItemProviderType == null) {
    return [];
  }

  return v1UserInfoGet$Response$SsoProviders$ItemProviderType
      .map((e) => e.value!)
      .toList();
}

List<enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType>
v1UserInfoGet$Response$SsoProviders$ItemProviderTypeListFromJson(
  List? v1UserInfoGet$Response$SsoProviders$ItemProviderType, [
  List<enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType>?
  defaultValue,
]) {
  if (v1UserInfoGet$Response$SsoProviders$ItemProviderType == null) {
    return defaultValue ?? [];
  }

  return v1UserInfoGet$Response$SsoProviders$ItemProviderType
      .map(
        (e) => v1UserInfoGet$Response$SsoProviders$ItemProviderTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType>?
v1UserInfoGet$Response$SsoProviders$ItemProviderTypeNullableListFromJson(
  List? v1UserInfoGet$Response$SsoProviders$ItemProviderType, [
  List<enums.V1UserInfoGet$Response$SsoProviders$ItemProviderType>?
  defaultValue,
]) {
  if (v1UserInfoGet$Response$SsoProviders$ItemProviderType == null) {
    return defaultValue;
  }

  return v1UserInfoGet$Response$SsoProviders$ItemProviderType
      .map(
        (e) => v1UserInfoGet$Response$SsoProviders$ItemProviderTypeFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String?
v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodNullableToJson(
  enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod?
  v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod,
) {
  return v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod?.value;
}

String? v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodToJson(
  enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod
  v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod,
) {
  return v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod.value;
}

enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod
v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodFromJson(
  Object? v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod, [
  enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod?
  defaultValue,
]) {
  return enums
          .V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod,
          ) ??
      defaultValue ??
      enums
          .V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod
          .swaggerGeneratedUnknown;
}

enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod?
v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodNullableFromJson(
  Object? v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod, [
  enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod == null) {
    return null;
  }
  return enums
          .V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod,
          ) ??
      defaultValue;
}

String
v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodExplodedListToJson(
  List<enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod>?
  v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod,
) {
  return v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodListToJson(
  List<enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod>?
  v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod,
) {
  if (v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod == null) {
    return [];
  }

  return v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod>
v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodListFromJson(
  List? v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod, [
  List<enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod>?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod == null) {
    return defaultValue ?? [];
  }

  return v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod
      .map(
        (e) =>
            v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod>?
v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodNullableListFromJson(
  List? v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod, [
  List<enums.V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod>?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod == null) {
    return defaultValue;
  }

  return v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod
      .map(
        (e) =>
            v1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethodFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? v1AdminCreateOauthClientPost$RequestBodyGrantTypesNullableToJson(
  enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes?
  v1AdminCreateOauthClientPost$RequestBodyGrantTypes,
) {
  return v1AdminCreateOauthClientPost$RequestBodyGrantTypes?.value;
}

String? v1AdminCreateOauthClientPost$RequestBodyGrantTypesToJson(
  enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes
  v1AdminCreateOauthClientPost$RequestBodyGrantTypes,
) {
  return v1AdminCreateOauthClientPost$RequestBodyGrantTypes.value;
}

enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes
v1AdminCreateOauthClientPost$RequestBodyGrantTypesFromJson(
  Object? v1AdminCreateOauthClientPost$RequestBodyGrantTypes, [
  enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes? defaultValue,
]) {
  return enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value == v1AdminCreateOauthClientPost$RequestBodyGrantTypes,
          ) ??
      defaultValue ??
      enums
          .V1AdminCreateOauthClientPost$RequestBodyGrantTypes
          .swaggerGeneratedUnknown;
}

enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes?
v1AdminCreateOauthClientPost$RequestBodyGrantTypesNullableFromJson(
  Object? v1AdminCreateOauthClientPost$RequestBodyGrantTypes, [
  enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyGrantTypes == null) {
    return null;
  }
  return enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value == v1AdminCreateOauthClientPost$RequestBodyGrantTypes,
          ) ??
      defaultValue;
}

String v1AdminCreateOauthClientPost$RequestBodyGrantTypesExplodedListToJson(
  List<enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes>?
  v1AdminCreateOauthClientPost$RequestBodyGrantTypes,
) {
  return v1AdminCreateOauthClientPost$RequestBodyGrantTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminCreateOauthClientPost$RequestBodyGrantTypesListToJson(
  List<enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes>?
  v1AdminCreateOauthClientPost$RequestBodyGrantTypes,
) {
  if (v1AdminCreateOauthClientPost$RequestBodyGrantTypes == null) {
    return [];
  }

  return v1AdminCreateOauthClientPost$RequestBodyGrantTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes>
v1AdminCreateOauthClientPost$RequestBodyGrantTypesListFromJson(
  List? v1AdminCreateOauthClientPost$RequestBodyGrantTypes, [
  List<enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes>? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyGrantTypes == null) {
    return defaultValue ?? [];
  }

  return v1AdminCreateOauthClientPost$RequestBodyGrantTypes
      .map(
        (e) => v1AdminCreateOauthClientPost$RequestBodyGrantTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes>?
v1AdminCreateOauthClientPost$RequestBodyGrantTypesNullableListFromJson(
  List? v1AdminCreateOauthClientPost$RequestBodyGrantTypes, [
  List<enums.V1AdminCreateOauthClientPost$RequestBodyGrantTypes>? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyGrantTypes == null) {
    return defaultValue;
  }

  return v1AdminCreateOauthClientPost$RequestBodyGrantTypes
      .map(
        (e) => v1AdminCreateOauthClientPost$RequestBodyGrantTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? v1AdminCreateOauthClientPost$RequestBodyResponseTypesNullableToJson(
  enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes?
  v1AdminCreateOauthClientPost$RequestBodyResponseTypes,
) {
  return v1AdminCreateOauthClientPost$RequestBodyResponseTypes?.value;
}

String? v1AdminCreateOauthClientPost$RequestBodyResponseTypesToJson(
  enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes
  v1AdminCreateOauthClientPost$RequestBodyResponseTypes,
) {
  return v1AdminCreateOauthClientPost$RequestBodyResponseTypes.value;
}

enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes
v1AdminCreateOauthClientPost$RequestBodyResponseTypesFromJson(
  Object? v1AdminCreateOauthClientPost$RequestBodyResponseTypes, [
  enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes? defaultValue,
]) {
  return enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminCreateOauthClientPost$RequestBodyResponseTypes,
          ) ??
      defaultValue ??
      enums
          .V1AdminCreateOauthClientPost$RequestBodyResponseTypes
          .swaggerGeneratedUnknown;
}

enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes?
v1AdminCreateOauthClientPost$RequestBodyResponseTypesNullableFromJson(
  Object? v1AdminCreateOauthClientPost$RequestBodyResponseTypes, [
  enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyResponseTypes == null) {
    return null;
  }
  return enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminCreateOauthClientPost$RequestBodyResponseTypes,
          ) ??
      defaultValue;
}

String v1AdminCreateOauthClientPost$RequestBodyResponseTypesExplodedListToJson(
  List<enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes>?
  v1AdminCreateOauthClientPost$RequestBodyResponseTypes,
) {
  return v1AdminCreateOauthClientPost$RequestBodyResponseTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminCreateOauthClientPost$RequestBodyResponseTypesListToJson(
  List<enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes>?
  v1AdminCreateOauthClientPost$RequestBodyResponseTypes,
) {
  if (v1AdminCreateOauthClientPost$RequestBodyResponseTypes == null) {
    return [];
  }

  return v1AdminCreateOauthClientPost$RequestBodyResponseTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes>
v1AdminCreateOauthClientPost$RequestBodyResponseTypesListFromJson(
  List? v1AdminCreateOauthClientPost$RequestBodyResponseTypes, [
  List<enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes>?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyResponseTypes == null) {
    return defaultValue ?? [];
  }

  return v1AdminCreateOauthClientPost$RequestBodyResponseTypes
      .map(
        (e) => v1AdminCreateOauthClientPost$RequestBodyResponseTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes>?
v1AdminCreateOauthClientPost$RequestBodyResponseTypesNullableListFromJson(
  List? v1AdminCreateOauthClientPost$RequestBodyResponseTypes, [
  List<enums.V1AdminCreateOauthClientPost$RequestBodyResponseTypes>?
  defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyResponseTypes == null) {
    return defaultValue;
  }

  return v1AdminCreateOauthClientPost$RequestBodyResponseTypes
      .map(
        (e) => v1AdminCreateOauthClientPost$RequestBodyResponseTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? v1AdminCreateOauthClientPost$RequestBodyTypeNullableToJson(
  enums.V1AdminCreateOauthClientPost$RequestBodyType?
  v1AdminCreateOauthClientPost$RequestBodyType,
) {
  return v1AdminCreateOauthClientPost$RequestBodyType?.value;
}

String? v1AdminCreateOauthClientPost$RequestBodyTypeToJson(
  enums.V1AdminCreateOauthClientPost$RequestBodyType
  v1AdminCreateOauthClientPost$RequestBodyType,
) {
  return v1AdminCreateOauthClientPost$RequestBodyType.value;
}

enums.V1AdminCreateOauthClientPost$RequestBodyType
v1AdminCreateOauthClientPost$RequestBodyTypeFromJson(
  Object? v1AdminCreateOauthClientPost$RequestBodyType, [
  enums.V1AdminCreateOauthClientPost$RequestBodyType? defaultValue,
]) {
  return enums.V1AdminCreateOauthClientPost$RequestBodyType.values
          .firstWhereOrNull(
            (e) => e.value == v1AdminCreateOauthClientPost$RequestBodyType,
          ) ??
      defaultValue ??
      enums
          .V1AdminCreateOauthClientPost$RequestBodyType
          .swaggerGeneratedUnknown;
}

enums.V1AdminCreateOauthClientPost$RequestBodyType?
v1AdminCreateOauthClientPost$RequestBodyTypeNullableFromJson(
  Object? v1AdminCreateOauthClientPost$RequestBodyType, [
  enums.V1AdminCreateOauthClientPost$RequestBodyType? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyType == null) {
    return null;
  }
  return enums.V1AdminCreateOauthClientPost$RequestBodyType.values
          .firstWhereOrNull(
            (e) => e.value == v1AdminCreateOauthClientPost$RequestBodyType,
          ) ??
      defaultValue;
}

String v1AdminCreateOauthClientPost$RequestBodyTypeExplodedListToJson(
  List<enums.V1AdminCreateOauthClientPost$RequestBodyType>?
  v1AdminCreateOauthClientPost$RequestBodyType,
) {
  return v1AdminCreateOauthClientPost$RequestBodyType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminCreateOauthClientPost$RequestBodyTypeListToJson(
  List<enums.V1AdminCreateOauthClientPost$RequestBodyType>?
  v1AdminCreateOauthClientPost$RequestBodyType,
) {
  if (v1AdminCreateOauthClientPost$RequestBodyType == null) {
    return [];
  }

  return v1AdminCreateOauthClientPost$RequestBodyType
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$RequestBodyType>
v1AdminCreateOauthClientPost$RequestBodyTypeListFromJson(
  List? v1AdminCreateOauthClientPost$RequestBodyType, [
  List<enums.V1AdminCreateOauthClientPost$RequestBodyType>? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyType == null) {
    return defaultValue ?? [];
  }

  return v1AdminCreateOauthClientPost$RequestBodyType
      .map(
        (e) =>
            v1AdminCreateOauthClientPost$RequestBodyTypeFromJson(e.toString()),
      )
      .toList();
}

List<enums.V1AdminCreateOauthClientPost$RequestBodyType>?
v1AdminCreateOauthClientPost$RequestBodyTypeNullableListFromJson(
  List? v1AdminCreateOauthClientPost$RequestBodyType, [
  List<enums.V1AdminCreateOauthClientPost$RequestBodyType>? defaultValue,
]) {
  if (v1AdminCreateOauthClientPost$RequestBodyType == null) {
    return defaultValue;
  }

  return v1AdminCreateOauthClientPost$RequestBodyType
      .map(
        (e) =>
            v1AdminCreateOauthClientPost$RequestBodyTypeFromJson(e.toString()),
      )
      .toList();
}

String? v1AdminUpdateOauthClientPost$RequestBodyGrantTypesNullableToJson(
  enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes?
  v1AdminUpdateOauthClientPost$RequestBodyGrantTypes,
) {
  return v1AdminUpdateOauthClientPost$RequestBodyGrantTypes?.value;
}

String? v1AdminUpdateOauthClientPost$RequestBodyGrantTypesToJson(
  enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes
  v1AdminUpdateOauthClientPost$RequestBodyGrantTypes,
) {
  return v1AdminUpdateOauthClientPost$RequestBodyGrantTypes.value;
}

enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes
v1AdminUpdateOauthClientPost$RequestBodyGrantTypesFromJson(
  Object? v1AdminUpdateOauthClientPost$RequestBodyGrantTypes, [
  enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes? defaultValue,
]) {
  return enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value == v1AdminUpdateOauthClientPost$RequestBodyGrantTypes,
          ) ??
      defaultValue ??
      enums
          .V1AdminUpdateOauthClientPost$RequestBodyGrantTypes
          .swaggerGeneratedUnknown;
}

enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes?
v1AdminUpdateOauthClientPost$RequestBodyGrantTypesNullableFromJson(
  Object? v1AdminUpdateOauthClientPost$RequestBodyGrantTypes, [
  enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$RequestBodyGrantTypes == null) {
    return null;
  }
  return enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value == v1AdminUpdateOauthClientPost$RequestBodyGrantTypes,
          ) ??
      defaultValue;
}

String v1AdminUpdateOauthClientPost$RequestBodyGrantTypesExplodedListToJson(
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes>?
  v1AdminUpdateOauthClientPost$RequestBodyGrantTypes,
) {
  return v1AdminUpdateOauthClientPost$RequestBodyGrantTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminUpdateOauthClientPost$RequestBodyGrantTypesListToJson(
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes>?
  v1AdminUpdateOauthClientPost$RequestBodyGrantTypes,
) {
  if (v1AdminUpdateOauthClientPost$RequestBodyGrantTypes == null) {
    return [];
  }

  return v1AdminUpdateOauthClientPost$RequestBodyGrantTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes>
v1AdminUpdateOauthClientPost$RequestBodyGrantTypesListFromJson(
  List? v1AdminUpdateOauthClientPost$RequestBodyGrantTypes, [
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes>? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$RequestBodyGrantTypes == null) {
    return defaultValue ?? [];
  }

  return v1AdminUpdateOauthClientPost$RequestBodyGrantTypes
      .map(
        (e) => v1AdminUpdateOauthClientPost$RequestBodyGrantTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes>?
v1AdminUpdateOauthClientPost$RequestBodyGrantTypesNullableListFromJson(
  List? v1AdminUpdateOauthClientPost$RequestBodyGrantTypes, [
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyGrantTypes>? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$RequestBodyGrantTypes == null) {
    return defaultValue;
  }

  return v1AdminUpdateOauthClientPost$RequestBodyGrantTypes
      .map(
        (e) => v1AdminUpdateOauthClientPost$RequestBodyGrantTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? v1AdminUpdateOauthClientPost$RequestBodyResponseTypesNullableToJson(
  enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes?
  v1AdminUpdateOauthClientPost$RequestBodyResponseTypes,
) {
  return v1AdminUpdateOauthClientPost$RequestBodyResponseTypes?.value;
}

String? v1AdminUpdateOauthClientPost$RequestBodyResponseTypesToJson(
  enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes
  v1AdminUpdateOauthClientPost$RequestBodyResponseTypes,
) {
  return v1AdminUpdateOauthClientPost$RequestBodyResponseTypes.value;
}

enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes
v1AdminUpdateOauthClientPost$RequestBodyResponseTypesFromJson(
  Object? v1AdminUpdateOauthClientPost$RequestBodyResponseTypes, [
  enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes? defaultValue,
]) {
  return enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminUpdateOauthClientPost$RequestBodyResponseTypes,
          ) ??
      defaultValue ??
      enums
          .V1AdminUpdateOauthClientPost$RequestBodyResponseTypes
          .swaggerGeneratedUnknown;
}

enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes?
v1AdminUpdateOauthClientPost$RequestBodyResponseTypesNullableFromJson(
  Object? v1AdminUpdateOauthClientPost$RequestBodyResponseTypes, [
  enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$RequestBodyResponseTypes == null) {
    return null;
  }
  return enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                v1AdminUpdateOauthClientPost$RequestBodyResponseTypes,
          ) ??
      defaultValue;
}

String v1AdminUpdateOauthClientPost$RequestBodyResponseTypesExplodedListToJson(
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes>?
  v1AdminUpdateOauthClientPost$RequestBodyResponseTypes,
) {
  return v1AdminUpdateOauthClientPost$RequestBodyResponseTypes
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminUpdateOauthClientPost$RequestBodyResponseTypesListToJson(
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes>?
  v1AdminUpdateOauthClientPost$RequestBodyResponseTypes,
) {
  if (v1AdminUpdateOauthClientPost$RequestBodyResponseTypes == null) {
    return [];
  }

  return v1AdminUpdateOauthClientPost$RequestBodyResponseTypes
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes>
v1AdminUpdateOauthClientPost$RequestBodyResponseTypesListFromJson(
  List? v1AdminUpdateOauthClientPost$RequestBodyResponseTypes, [
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes>?
  defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$RequestBodyResponseTypes == null) {
    return defaultValue ?? [];
  }

  return v1AdminUpdateOauthClientPost$RequestBodyResponseTypes
      .map(
        (e) => v1AdminUpdateOauthClientPost$RequestBodyResponseTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes>?
v1AdminUpdateOauthClientPost$RequestBodyResponseTypesNullableListFromJson(
  List? v1AdminUpdateOauthClientPost$RequestBodyResponseTypes, [
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyResponseTypes>?
  defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$RequestBodyResponseTypes == null) {
    return defaultValue;
  }

  return v1AdminUpdateOauthClientPost$RequestBodyResponseTypes
      .map(
        (e) => v1AdminUpdateOauthClientPost$RequestBodyResponseTypesFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? v1AdminUpdateOauthClientPost$RequestBodyTypeNullableToJson(
  enums.V1AdminUpdateOauthClientPost$RequestBodyType?
  v1AdminUpdateOauthClientPost$RequestBodyType,
) {
  return v1AdminUpdateOauthClientPost$RequestBodyType?.value;
}

String? v1AdminUpdateOauthClientPost$RequestBodyTypeToJson(
  enums.V1AdminUpdateOauthClientPost$RequestBodyType
  v1AdminUpdateOauthClientPost$RequestBodyType,
) {
  return v1AdminUpdateOauthClientPost$RequestBodyType.value;
}

enums.V1AdminUpdateOauthClientPost$RequestBodyType
v1AdminUpdateOauthClientPost$RequestBodyTypeFromJson(
  Object? v1AdminUpdateOauthClientPost$RequestBodyType, [
  enums.V1AdminUpdateOauthClientPost$RequestBodyType? defaultValue,
]) {
  return enums.V1AdminUpdateOauthClientPost$RequestBodyType.values
          .firstWhereOrNull(
            (e) => e.value == v1AdminUpdateOauthClientPost$RequestBodyType,
          ) ??
      defaultValue ??
      enums
          .V1AdminUpdateOauthClientPost$RequestBodyType
          .swaggerGeneratedUnknown;
}

enums.V1AdminUpdateOauthClientPost$RequestBodyType?
v1AdminUpdateOauthClientPost$RequestBodyTypeNullableFromJson(
  Object? v1AdminUpdateOauthClientPost$RequestBodyType, [
  enums.V1AdminUpdateOauthClientPost$RequestBodyType? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$RequestBodyType == null) {
    return null;
  }
  return enums.V1AdminUpdateOauthClientPost$RequestBodyType.values
          .firstWhereOrNull(
            (e) => e.value == v1AdminUpdateOauthClientPost$RequestBodyType,
          ) ??
      defaultValue;
}

String v1AdminUpdateOauthClientPost$RequestBodyTypeExplodedListToJson(
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyType>?
  v1AdminUpdateOauthClientPost$RequestBodyType,
) {
  return v1AdminUpdateOauthClientPost$RequestBodyType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> v1AdminUpdateOauthClientPost$RequestBodyTypeListToJson(
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyType>?
  v1AdminUpdateOauthClientPost$RequestBodyType,
) {
  if (v1AdminUpdateOauthClientPost$RequestBodyType == null) {
    return [];
  }

  return v1AdminUpdateOauthClientPost$RequestBodyType
      .map((e) => e.value!)
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$RequestBodyType>
v1AdminUpdateOauthClientPost$RequestBodyTypeListFromJson(
  List? v1AdminUpdateOauthClientPost$RequestBodyType, [
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyType>? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$RequestBodyType == null) {
    return defaultValue ?? [];
  }

  return v1AdminUpdateOauthClientPost$RequestBodyType
      .map(
        (e) =>
            v1AdminUpdateOauthClientPost$RequestBodyTypeFromJson(e.toString()),
      )
      .toList();
}

List<enums.V1AdminUpdateOauthClientPost$RequestBodyType>?
v1AdminUpdateOauthClientPost$RequestBodyTypeNullableListFromJson(
  List? v1AdminUpdateOauthClientPost$RequestBodyType, [
  List<enums.V1AdminUpdateOauthClientPost$RequestBodyType>? defaultValue,
]) {
  if (v1AdminUpdateOauthClientPost$RequestBodyType == null) {
    return defaultValue;
  }

  return v1AdminUpdateOauthClientPost$RequestBodyType
      .map(
        (e) =>
            v1AdminUpdateOauthClientPost$RequestBodyTypeFromJson(e.toString()),
      )
      .toList();
}

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
