// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

enum V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('none')
  none('none'),
  @JsonValue('client_secret_basic')
  clientSecretBasic('client_secret_basic'),
  @JsonValue('client_secret_post')
  clientSecretPost('client_secret_post');

  final String? value;

  const V1AdminCreateOauthClientPost$Response$ClientTokenEndpointAuthMethod(
    this.value,
  );
}

enum V1AdminCreateOauthClientPost$Response$ClientGrantTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('authorization_code')
  authorizationCode('authorization_code'),
  @JsonValue('client_credentials')
  clientCredentials('client_credentials'),
  @JsonValue('refresh_token')
  refreshToken('refresh_token');

  final String? value;

  const V1AdminCreateOauthClientPost$Response$ClientGrantTypes(this.value);
}

enum V1AdminCreateOauthClientPost$Response$ClientResponseTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('code')
  code('code');

  final String? value;

  const V1AdminCreateOauthClientPost$Response$ClientResponseTypes(this.value);
}

enum V1AdminCreateOauthClientPost$Response$ClientType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('web')
  web('web'),
  @JsonValue('native')
  native('native'),
  @JsonValue('user-agent-based')
  userAgentBased('user-agent-based');

  final String? value;

  const V1AdminCreateOauthClientPost$Response$ClientType(this.value);
}

enum V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('none')
  none('none'),
  @JsonValue('client_secret_basic')
  clientSecretBasic('client_secret_basic'),
  @JsonValue('client_secret_post')
  clientSecretPost('client_secret_post');

  final String? value;

  const V1AdminUpdateOauthClientPost$Response$ClientTokenEndpointAuthMethod(
    this.value,
  );
}

enum V1AdminUpdateOauthClientPost$Response$ClientGrantTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('authorization_code')
  authorizationCode('authorization_code'),
  @JsonValue('client_credentials')
  clientCredentials('client_credentials'),
  @JsonValue('refresh_token')
  refreshToken('refresh_token');

  final String? value;

  const V1AdminUpdateOauthClientPost$Response$ClientGrantTypes(this.value);
}

enum V1AdminUpdateOauthClientPost$Response$ClientResponseTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('code')
  code('code');

  final String? value;

  const V1AdminUpdateOauthClientPost$Response$ClientResponseTypes(this.value);
}

enum V1AdminUpdateOauthClientPost$Response$ClientType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('web')
  web('web'),
  @JsonValue('native')
  native('native'),
  @JsonValue('user-agent-based')
  userAgentBased('user-agent-based');

  final String? value;

  const V1AdminUpdateOauthClientPost$Response$ClientType(this.value);
}

enum V1AdminListUsersGetSearchField {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('email')
  email('email'),
  @JsonValue('name')
  name('name');

  final String? value;

  const V1AdminListUsersGetSearchField(this.value);
}

enum V1AdminListUsersGetSortBy {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('id')
  id('id'),
  @JsonValue('name')
  name('name'),
  @JsonValue('email')
  email('email'),
  @JsonValue('role')
  role('role'),
  @JsonValue('createdAt')
  createdat('createdAt'),
  @JsonValue('updatedAt')
  updatedat('updatedAt');

  final String? value;

  const V1AdminListUsersGetSortBy(this.value);
}

enum V1AdminListUsersGetSortDirection {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('asc')
  asc('asc'),
  @JsonValue('desc')
  desc('desc');

  final String? value;

  const V1AdminListUsersGetSortDirection(this.value);
}

enum V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('none')
  none('none'),
  @JsonValue('client_secret_basic')
  clientSecretBasic('client_secret_basic'),
  @JsonValue('client_secret_post')
  clientSecretPost('client_secret_post');

  final String? value;

  const V1AdminListOauthClientsGet$Response$Clients$ItemTokenEndpointAuthMethod(
    this.value,
  );
}

enum V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('authorization_code')
  authorizationCode('authorization_code'),
  @JsonValue('client_credentials')
  clientCredentials('client_credentials'),
  @JsonValue('refresh_token')
  refreshToken('refresh_token');

  final String? value;

  const V1AdminListOauthClientsGet$Response$Clients$ItemGrantTypes(this.value);
}

enum V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('code')
  code('code');

  final String? value;

  const V1AdminListOauthClientsGet$Response$Clients$ItemResponseTypes(
    this.value,
  );
}

enum V1AdminListOauthClientsGet$Response$Clients$ItemType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('web')
  web('web'),
  @JsonValue('native')
  native('native'),
  @JsonValue('user-agent-based')
  userAgentBased('user-agent-based');

  final String? value;

  const V1AdminListOauthClientsGet$Response$Clients$ItemType(this.value);
}

enum V1UserInfoGet$Response$SsoProviders$ItemProviderType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('generic_oauth')
  genericOauth('generic_oauth'),
  @JsonValue('social')
  social('social');

  final String? value;

  const V1UserInfoGet$Response$SsoProviders$ItemProviderType(this.value);
}

enum V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('none')
  none('none'),
  @JsonValue('client_secret_basic')
  clientSecretBasic('client_secret_basic'),
  @JsonValue('client_secret_post')
  clientSecretPost('client_secret_post');

  final String? value;

  const V1AdminCreateOauthClientPost$RequestBodyTokenEndpointAuthMethod(
    this.value,
  );
}

enum V1AdminCreateOauthClientPost$RequestBodyGrantTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('authorization_code')
  authorizationCode('authorization_code'),
  @JsonValue('client_credentials')
  clientCredentials('client_credentials'),
  @JsonValue('refresh_token')
  refreshToken('refresh_token');

  final String? value;

  const V1AdminCreateOauthClientPost$RequestBodyGrantTypes(this.value);
}

enum V1AdminCreateOauthClientPost$RequestBodyResponseTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('code')
  code('code');

  final String? value;

  const V1AdminCreateOauthClientPost$RequestBodyResponseTypes(this.value);
}

enum V1AdminCreateOauthClientPost$RequestBodyType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('web')
  web('web'),
  @JsonValue('native')
  native('native'),
  @JsonValue('user-agent-based')
  userAgentBased('user-agent-based');

  final String? value;

  const V1AdminCreateOauthClientPost$RequestBodyType(this.value);
}

enum V1AdminUpdateOauthClientPost$RequestBodyGrantTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('authorization_code')
  authorizationCode('authorization_code'),
  @JsonValue('client_credentials')
  clientCredentials('client_credentials'),
  @JsonValue('refresh_token')
  refreshToken('refresh_token');

  final String? value;

  const V1AdminUpdateOauthClientPost$RequestBodyGrantTypes(this.value);
}

enum V1AdminUpdateOauthClientPost$RequestBodyResponseTypes {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('code')
  code('code');

  final String? value;

  const V1AdminUpdateOauthClientPost$RequestBodyResponseTypes(this.value);
}

enum V1AdminUpdateOauthClientPost$RequestBodyType {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('web')
  web('web'),
  @JsonValue('native')
  native('native'),
  @JsonValue('user-agent-based')
  userAgentBased('user-agent-based');

  final String? value;

  const V1AdminUpdateOauthClientPost$RequestBodyType(this.value);
}
