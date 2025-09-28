import 'dart:convert';

class AuthApiError {
  final String errorCode;
  final String message;

  AuthApiError({required this.errorCode, required this.message});

  factory AuthApiError.parse(dynamic data) {
    try {
      final json = jsonDecode(data);
      return AuthApiError(errorCode: json['error'], message: json['message']);
    } catch (e) {
      return AuthApiError(errorCode: 'UNKNOWN_ERROR', message: data.toString());
    }
  }

  @override
  String toString() {
    return 'AuthApiError(errorCode: $errorCode, message: $message)';
  }
}
