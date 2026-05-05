import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_auth/api/openapi.models.swagger.dart';
import 'package:hippo_auth/src/auth_login_controller.dart';
import 'package:hippo_auth/src/models/auth_api_error.dart';
import 'package:hippo_auth/src/models/login_result.dart';

void main() {
  group('AuthApiError.parse', () {
    test('parses legacy flat better-auth errors', () {
      final error = AuthApiError.parse(
        jsonEncode({
          'code': 'INVALID_EMAIL_OR_PASSWORD',
          'message': 'Invalid email or password',
        }),
      );

      expect(error.errorCode, 'INVALID_EMAIL_OR_PASSWORD');
      expect(error.message, 'Invalid email or password');
    });

    test('parses nested better-auth-rs errors', () {
      final error = AuthApiError.parse(
        jsonEncode({
          'error': {
            'code': 'SignInEmailFailed',
            'message': 'Invalid credentials',
          },
        }),
      );

      expect(error.errorCode, 'SignInEmailFailed');
      expect(error.message, 'Invalid credentials');
    });

    test('parses generated hippo auth error responses', () {
      final error = AuthApiError.parse(
        const HippoAuthErrorResponse(
          error: HippoAuthErrorResponse$Error(
            code: 'SignInEmailFailed',
            message: 'Invalid credentials',
          ),
        ),
      );

      expect(error.errorCode, 'SignInEmailFailed');
      expect(error.message, 'Invalid credentials');
    });

    test('parses generated hippo auth error bodies', () {
      final error = AuthApiError.parse(
        const HippoAuthErrorResponse$Error(
          code: 'SignInEmailFailed',
          message: 'Invalid credentials',
        ),
      );

      expect(error.errorCode, 'SignInEmailFailed');
      expect(error.message, 'Invalid credentials');
    });
  });

  group('parseLoginError', () {
    test('maps legacy invalid credentials to InvalidCredentialsLoginError', () {
      final error = parseLoginError(
        jsonEncode({
          'code': 'INVALID_EMAIL_OR_PASSWORD',
          'message': 'Invalid email or password',
        }),
      );

      expect(error, isA<InvalidCredentialsLoginError>());
    });

    test(
      'maps better-auth-rs invalid credentials to InvalidCredentialsLoginError',
      () {
        final error = parseLoginError(
          jsonEncode({
            'error': {
              'code': 'SignInEmailFailed',
              'message': 'Invalid credentials',
            },
          }),
        );

        expect(error, isA<InvalidCredentialsLoginError>());
      },
    );
  });
}
