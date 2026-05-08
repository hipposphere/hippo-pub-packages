// dart format width=80
// Generated code

part of 'openapi.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$Openapi extends Openapi {
  _$Openapi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = Openapi;

  @override
  Future<Response<V1AdminCreateUserPost$Response>> _v1AdminCreateUserPost({
    required V1AdminCreateUserPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1AdminCreateUser',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/admin/create-user');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client
        .send<V1AdminCreateUserPost$Response, V1AdminCreateUserPost$Response>(
          $request,
        );
  }

  @override
  Future<Response<V1AdminCreateOauthClientPost$Response>>
  _v1AdminCreateOauthClientPost({
    required V1AdminCreateOauthClientPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1AdminCreateOauthClient',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/admin/create-oauth-client');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      V1AdminCreateOauthClientPost$Response,
      V1AdminCreateOauthClientPost$Response
    >($request);
  }

  @override
  Future<Response<V1AdminDeleteUserPost$Response>> _v1AdminDeleteUserPost({
    required V1AdminDeleteUserPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1AdminDeleteUser',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/admin/delete-user');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client
        .send<V1AdminDeleteUserPost$Response, V1AdminDeleteUserPost$Response>(
          $request,
        );
  }

  @override
  Future<Response<V1AdminDeleteOauthClientPost$Response>>
  _v1AdminDeleteOauthClientPost({
    required V1AdminDeleteOauthClientPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1AdminDeleteOauthClient',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/admin/delete-oauth-client');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      V1AdminDeleteOauthClientPost$Response,
      V1AdminDeleteOauthClientPost$Response
    >($request);
  }

  @override
  Future<Response<V1AdminUpdateUserPost$Response>> _v1AdminUpdateUserPost({
    required V1AdminUpdateUserPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1AdminUpdateUser',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/admin/update-user');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client
        .send<V1AdminUpdateUserPost$Response, V1AdminUpdateUserPost$Response>(
          $request,
        );
  }

  @override
  Future<Response<V1AdminUpdateOauthClientPost$Response>>
  _v1AdminUpdateOauthClientPost({
    required V1AdminUpdateOauthClientPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1AdminUpdateOauthClient',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/admin/update-oauth-client');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<
      V1AdminUpdateOauthClientPost$Response,
      V1AdminUpdateOauthClientPost$Response
    >($request);
  }

  @override
  Future<Response<V1AdminListUsersGet$Response>> _v1AdminListUsersGet({
    int? limit,
    int? offset,
    String? searchValue,
    String? searchField,
    String? sortBy,
    String? sortDirection,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'getV1AdminListUsers',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/admin/list-users');
    final Map<String, dynamic> $params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'search_value': searchValue,
      'search_field': searchField,
      'sort_by': sortBy,
      'sort_direction': sortDirection,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client
        .send<V1AdminListUsersGet$Response, V1AdminListUsersGet$Response>(
          $request,
        );
  }

  @override
  Future<Response<V1AdminListOauthClientsGet$Response>>
  _v1AdminListOauthClientsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'getV1AdminListOauthClients',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/admin/list-oauth-clients');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      V1AdminListOauthClientsGet$Response,
      V1AdminListOauthClientsGet$Response
    >($request);
  }

  @override
  Future<Response<bool>> _v1UserConfirmMailPost({
    required V1UserConfirmMailPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1UserConfirmMail',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/confirm-mail');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<bool, bool>($request);
  }

  @override
  Future<Response<V1UserInfoGet$Response>> _v1UserInfoGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'getV1UserInfo',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/info');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<V1UserInfoGet$Response, V1UserInfoGet$Response>(
      $request,
    );
  }

  @override
  Future<Response<V1UserGetUserGet$Response>> _v1UserGetUserGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'getV1UserGetUser',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/get_user');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<V1UserGetUserGet$Response, V1UserGetUserGet$Response>(
      $request,
    );
  }

  @override
  Future<Response<V1UserLogoutGet$Response>> _v1UserLogoutGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'getV1UserLogout',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/logout');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<V1UserLogoutGet$Response, V1UserLogoutGet$Response>(
      $request,
    );
  }

  @override
  Future<Response<V1UserRefreshSessionPost$Response>>
  _v1UserRefreshSessionPost({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1UserRefreshSession',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/refresh-session');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<
      V1UserRefreshSessionPost$Response,
      V1UserRefreshSessionPost$Response
    >($request);
  }

  @override
  Future<Response<bool>> _v1UserRequestPasswordResetPost({
    required V1UserRequestPasswordResetPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1UserRequestPasswordReset',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/request-password-reset');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<bool, bool>($request);
  }

  @override
  Future<Response<bool>> _v1UserResetPasswordPost({
    required V1UserResetPasswordPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1UserResetPassword',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/reset-password');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<bool, bool>($request);
  }

  @override
  Future<Response<V1UserSignInEmailPost$Response>> _v1UserSignInEmailPost({
    required V1UserSignInEmailPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1UserSignInEmail',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/sign-in-email');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client
        .send<V1UserSignInEmailPost$Response, V1UserSignInEmailPost$Response>(
          $request,
        );
  }

  @override
  Future<Response<V1UserSignInSsoPost$Response>> _v1UserSignInSsoPost({
    required V1UserSignInSsoPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1UserSignInSso',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/sign-in-sso');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client
        .send<V1UserSignInSsoPost$Response, V1UserSignInSsoPost$Response>(
          $request,
        );
  }

  @override
  Future<Response<V1UserSignUpEmailPost$Response>> _v1UserSignUpEmailPost({
    required V1UserSignUpEmailPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'postV1UserSignUpEmail',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/sign-up-email');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client
        .send<V1UserSignUpEmailPost$Response, V1UserSignUpEmailPost$Response>(
          $request,
        );
  }

  @override
  Future<Response<dynamic>> _v1Oauth2CallbackProviderIdGet({
    String? code,
    String? state,
    String? error,
    String? errorDescription,
    String? sessionState,
    required String? providerId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'getV1Oauth2CallbackByProviderId',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/oauth2/callback/${providerId}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'code': code,
      'state': state,
      'error': error,
      'error_description': errorDescription,
      'session_state': sessionState,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _v1Oauth2SignInProviderIdGet({
    required String? callbackURL,
    required String? providerId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'getV1Oauth2SignInByProviderId',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/oauth2/sign-in/${providerId}');
    final Map<String, dynamic> $params = <String, dynamic>{
      'callbackURL': callbackURL,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
