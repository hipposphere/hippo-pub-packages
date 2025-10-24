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
  Future<Response<bool>> _v1UserConfirmMailPost({
    required V1UserConfirmMailPost$RequestBody? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/user/confirm_mail');
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
  Future<Response<V1UserGetUserGet$Response>> _v1UserGetUserGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
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
      operationId: '',
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
      operationId: '',
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
      operationId: '',
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
      operationId: '',
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
      operationId: '',
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
      operationId: '',
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
      operationId: '',
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
    required String? providerId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/oauth2/callback/${providerId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _v1Oauth2SignInProviderIdGet({
    required String? providerId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/v1/oauth2/sign-in/${providerId}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _viewsResetPasswordGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/views/reset-password');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _viewsConfirmMailGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: '',
      consumes: [],
      produces: [],
      security: [],
      tags: [],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/views/confirm-mail');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
