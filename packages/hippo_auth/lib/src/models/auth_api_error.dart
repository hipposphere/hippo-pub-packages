import 'dart:convert';

import 'package:hippo_auth/api/openapi.models.swagger.dart';

class AuthApiError {
  final String errorCode;
  final String message;

  AuthApiError({required this.errorCode, required this.message});

  factory AuthApiError.parse(dynamic data) {
    try {
      final dynamic decoded = switch (data) {
        String() => jsonDecode(data),
        HippoAuthErrorResponse() => data.error.toJson(),
        HippoAuthErrorResponse$Error() => data.toJson(),
        _ => data,
      };
      if (decoded is! Map) {
        throw const FormatException('Unsupported authentication error');
      }
      final nested = decoded['error'];
      final error = nested is Map ? nested : decoded;
      final code = error['code'];
      final message = error['message'];
      if (code is! String || message is! String) {
        throw const FormatException('Malformed authentication error');
      }
      return AuthApiError(errorCode: code, message: message);
    } catch (_) {
      return AuthApiError(errorCode: 'UNKNOWN_ERROR', message: data.toString());
    }
  }

  @override
  String toString() {
    return 'AuthApiError(errorCode: $errorCode, message: $message)';
  }
}
