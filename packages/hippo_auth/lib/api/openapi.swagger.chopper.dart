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
  }) {
    final Uri $url = Uri.parse('/v1/user/confirm_mail');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<bool, bool>($request);
  }

  @override
  Future<Response<V1UserGetUserGet$Response>> _v1UserGetUserGet() {
    final Uri $url = Uri.parse('/v1/user/get_user');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<V1UserGetUserGet$Response, V1UserGetUserGet$Response>(
      $request,
    );
  }

  @override
  Future<Response<dynamic>> _v1Useroauth2Get({
    required String? undefinedParameter,
  }) {
    final Uri $url = Uri.parse('/v1/useroauth2/${undefinedParameter}');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<V1UserRefreshSessionPost$Response>>
  _v1UserRefreshSessionPost() {
    final Uri $url = Uri.parse('/v1/user/refresh-session');
    final Request $request = Request('POST', $url, client.baseUrl);
    return client.send<
      V1UserRefreshSessionPost$Response,
      V1UserRefreshSessionPost$Response
    >($request);
  }

  @override
  Future<Response<bool>> _v1UserRequestPasswordResetPost({
    required V1UserRequestPasswordResetPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/user/request-password-reset');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<bool, bool>($request);
  }

  @override
  Future<Response<bool>> _v1UserResetPasswordPost({
    required V1UserResetPasswordPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/user/reset-password');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<bool, bool>($request);
  }

  @override
  Future<Response<V1UserSignInEmailPost$Response>> _v1UserSignInEmailPost({
    required V1UserSignInEmailPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/user/sign-in-email');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client
        .send<V1UserSignInEmailPost$Response, V1UserSignInEmailPost$Response>(
          $request,
        );
  }

  @override
  Future<Response<V1UserSignInSsoPost$Response>> _v1UserSignInSsoPost({
    required V1UserSignInSsoPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/user/sign-in-sso');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client
        .send<V1UserSignInSsoPost$Response, V1UserSignInSsoPost$Response>(
          $request,
        );
  }

  @override
  Future<Response<V1UserSignUpEmailPost$Response>> _v1UserSignUpEmailPost({
    required V1UserSignUpEmailPost$RequestBody? body,
  }) {
    final Uri $url = Uri.parse('/v1/user/sign-up-email');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client
        .send<V1UserSignUpEmailPost$Response, V1UserSignUpEmailPost$Response>(
          $request,
        );
  }
}
