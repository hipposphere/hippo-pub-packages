import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

final class HippoAuthBackendException implements Exception {
  const HippoAuthBackendException(this.status, this.code, this.message, {this.details});

  final int status;
  final String code;
  final String message;
  final Map<String, Object?>? details;
}

RawResponse hippoAuthErrorResponse(
  int status,
  String code,
  String message, {
  Map<String, Object?>? details,
}) {
  return RawResponse.json(
    status: status,
    headers: status == 401 && _isBearerSessionError(code)
        ? const <HttpHeader>[HttpHeader('www-authenticate', 'Bearer error="invalid_token"')]
        : const <HttpHeader>[],
    body: {
      'error': {
        'code': code,
        'message': message,
        if (details != null && details.isNotEmpty) 'details': details,
      },
    },
  );
}

bool _isBearerSessionError(String code) {
  return code == 'Unauthorized' || code.startsWith('RefreshSession');
}

RawResponse hippoAuthExceptionResponse(
  Object error, {
  required int defaultStatus,
  required String defaultCode,
  required String defaultMessage,
  Map<String, Object?>? details,
}) {
  if (error case final HippoAuthBackendException apiError) {
    return hippoAuthErrorResponse(
      apiError.status,
      apiError.code,
      apiError.message,
      details: apiError.details,
    );
  }

  if (error case final DartEdgeAuthApiException authError) {
    final parsed = _parseAuthError(authError.response.jsonBody);
    return hippoAuthErrorResponse(
      authError.status,
      parsed.code ?? defaultCode,
      parsed.message ?? authError.message,
      details: details,
    );
  }

  if (error case final FormatException formatError) {
    return hippoAuthErrorResponse(400, 'InvalidRequest', formatError.message, details: details);
  }

  return hippoAuthErrorResponse(defaultStatus, defaultCode, defaultMessage, details: details);
}

({String? code, String? message}) _parseAuthError(Object? jsonBody) {
  if (jsonBody case {'error': final Map<Object?, Object?> error}) {
    return (code: error['code']?.toString(), message: error['message']?.toString());
  }
  if (jsonBody case final Map<Object?, Object?> body) {
    return (
      code: body['code']?.toString(),
      message: body['message']?.toString() ?? body['error']?.toString(),
    );
  }
  return (code: null, message: null);
}
