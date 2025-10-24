import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_utils/hippo_utils.dart';

class HippoAuthLoginController {
  final HippoAuthApiController apiController;

  HippoAuthLoginController({required this.apiController});

  Future<LoginResult> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await apiController.api.v1UserSignUpEmailPost(
      body: V1UserSignUpEmailPost$RequestBody(
        name: name,
        email: email,
        password: password,
      ),
    );
    if (response.isSuccessful) {
      final body = response.body!;
      final authToken = AuthSession(
        id: body.sessionId,
        token: body.token,
        expiresAt: body.expiresAt,
      );

      await internalHandleSignIn(authToken);
      return SuccessfulLoginResult();
    } else {
      return FailedLoginResult(_parseLoginError(response.error));
    }
  }

  Future<LoginResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await apiController.api.v1UserSignInEmailPost(
      body: V1UserSignInEmailPost$RequestBody(email: email, password: password),
    );
    if (response.isSuccessful) {
      final body = response.body!;
      final authToken = AuthSession(
        id: body.sessionId,
        token: body.token,
        expiresAt: body.expiresAt,
      );

      await internalHandleSignIn(authToken);
      return SuccessfulLoginResult();
    } else {
      return FailedLoginResult(_parseLoginError(response.error));
    }
  }

  /// Creates the OAuth2 sign-in URL for the given provider and callback URL.
  String createOauth2SignInUrl({
    required String provider,
    required String callbackUrl,
  }) {
    final baseUrl = apiController.api.client.baseUrl;

    return '$baseUrl/v1/oauth2/sign-in/${Uri.encodeComponent(provider)}?callbackURL=${Uri.encodeComponent(callbackUrl)}';
  }

  Future<LoginResult> oauth2SignIn({
    required String provider,
    required String callbackUrlScheme,
    FlutterWebAuth2Options? webAuthOptions,
  }) async {
    try {
      final signInUrl = createOauth2SignInUrl(
        provider: provider,
        callbackUrl: callbackUrlScheme,
      );

      final result = await FlutterWebAuth2.authenticate(
        url: signInUrl,
        callbackUrlScheme: callbackUrlScheme,
        options:
            webAuthOptions ?? const FlutterWebAuth2Options(useWebview: false),
      );

      final responseParams = Uri.parse(result).queryParameters;

      final authToken = AuthSession(
        id: responseParams['session_id']!,
        token: responseParams['token']!,
        expiresAt: DateTime.parse(responseParams['expires_at']!),
      );

      await internalHandleSignIn(authToken);
      return SuccessfulLoginResult();
    } catch (e) {
      return FailedLoginResult(
        UnknownLoginError(error: 'SSO_ERROR', message: e.toString()),
      );
    }
  }

  Future<bool?> requestPasswordReset(String email) async {
    final result = await apiController.api.v1UserRequestPasswordResetPost(
      body: V1UserRequestPasswordResetPost$RequestBody(email: email),
    );
    return result.body;
  }

  Future<void> internalHandleSignIn(AuthSession session) async {
    apiController.sessionSubject.add(null);
    try {
      await apiController.setSession(session);
    } catch (e) {
      apiController.sessionSubject.add(SelectedValue(null));
    }
  }

  Future<void> signOut() async {
    await apiController.removeSession();
  }

  LoginError _parseLoginError(dynamic error) {
    final apiError = AuthApiError.parse(error);
    switch (apiError.errorCode) {
      case 'INVALID_EMAIL_OR_PASSWORD':
        return InvalidCredentialsLoginError();
      case 'PASSWORD_TOO_SHORT':
        return PasswordTooShortLoginError();
      default:
        return UnknownLoginError(
          error: apiError.errorCode,
          message: apiError.message,
        );
    }
  }
}
