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

      await _handleSignIn(authToken);
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

      await _handleSignIn(authToken);
      return SuccessfulLoginResult();
    } else {
      return FailedLoginResult(_parseLoginError(response.error));
    }
  }

  Future<LoginResult> signInWithSSO({
    required String provider,
    required String callbackUrlScheme,
  }) async {
    try {
      final response = await apiController.api.v1UserSignInSsoPost(
        body: V1UserSignInSsoPost$RequestBody(
          providerId: provider,
          successUrl: callbackUrlScheme,
        ),
      );

      final result = await FlutterWebAuth2.authenticate(
        url: response.body!.data.redirectUrl,
        callbackUrlScheme: callbackUrlScheme,
        options: const FlutterWebAuth2Options(useWebview: false),
      );

      final responseParams = Uri.parse(result).queryParameters;

      final authToken = AuthSession(
        id: responseParams['session_id']!,
        token: responseParams['token']!,
        expiresAt: DateTime.parse(responseParams['expires_at']!),
      );

      await _handleSignIn(authToken);
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

  Future<void> _handleSignIn(AuthSession session) async {
    apiController.sessionSubject.add(null);
    try {
      await apiController.setSession(session);
    } catch (e) {
      apiController.sessionSubject.add(SelectedValue(null));
    }
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
