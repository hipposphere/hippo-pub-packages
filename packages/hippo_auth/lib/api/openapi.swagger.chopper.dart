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
  Future<Response<bool>> _v1ConfirmMailPost({
    required V1ConfirmMailPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/confirm_mail');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<bool, bool>($request);
  }

  @override
  Future<Response<V1GetUserGet$Response>> _v1GetUserGet() {
    final Uri $url = Uri.parse('/v1/get_user');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<V1GetUserGet$Response, V1GetUserGet$Response>($request);
  }

  @override
  Future<Response<dynamic>> _v1oauth2Get({
    required String? undefinedParameter,
  }) {
    final Uri $url = Uri.parse('/v1oauth2/${undefinedParameter}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _v1oauth2Head({
    required String? undefinedParameter,
  }) {
    final Uri $url = Uri.parse('/v1oauth2/${undefinedParameter}');
    final Request $request = Request('HEAD', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _v1oauth2Delete({
    required String? undefinedParameter,
  }) {
    final Uri $url = Uri.parse('/v1oauth2/${undefinedParameter}');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _v1oauth2Patch({
    required String? undefinedParameter,
  }) {
    final Uri $url = Uri.parse('/v1oauth2/${undefinedParameter}');
    final Request $request = Request('PATCH', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _v1oauth2Put({
    required String? undefinedParameter,
  }) {
    final Uri $url = Uri.parse('/v1oauth2/${undefinedParameter}');
    final Request $request = Request('PUT', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _v1oauth2Post({
    required String? undefinedParameter,
  }) {
    final Uri $url = Uri.parse('/v1oauth2/${undefinedParameter}');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<V1RefreshSessionPost$Response>> _v1RefreshSessionPost() {
    final Uri $url = Uri.parse('/v1/refresh-session');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client
        .send<V1RefreshSessionPost$Response, V1RefreshSessionPost$Response>(
          $request,
        );
  }

  @override
  Future<Response<bool>> _v1RequestPasswordResetPost({
    required V1RequestPasswordResetPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/request-password-reset');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<bool, bool>($request);
  }

  @override
  Future<Response<bool>> _v1ResetPasswordPost({
    required V1ResetPasswordPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/reset-password');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<bool, bool>($request);
  }

  @override
  Future<Response<V1SignInEmailPost$Response>> _v1SignInEmailPost({
    required V1SignInEmailPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/sign-in-email');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<V1SignInEmailPost$Response, V1SignInEmailPost$Response>(
      $request,
    );
  }

  @override
  Future<Response<V1SignInSsoPost$Response>> _v1SignInSsoPost({
    required V1SignInSsoPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/sign-in-sso');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<V1SignInSsoPost$Response, V1SignInSsoPost$Response>(
      $request,
    );
  }

  @override
  Future<Response<V1SignUpEmailPost$Response>> _v1SignUpEmailPost({
    required V1SignUpEmailPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/sign-up-email');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<V1SignUpEmailPost$Response, V1SignUpEmailPost$Response>(
      $request,
    );
  }
}
