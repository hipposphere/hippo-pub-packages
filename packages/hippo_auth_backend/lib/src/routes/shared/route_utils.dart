import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

import '../../utils/api_error.dart';
import '../../utils/json_payload.dart';

Map<String, Object?> requestBody<TServices>(RequestContext<TServices> ctx) {
  return readJsonObject(ctx.req.bodyOrNull, 'request body');
}

bool statusFromResponse(DartEdgeAuthApiResponse response) {
  if (!response.isSuccess) {
    throw DartEdgeAuthApiException(response);
  }
  return readStatus(response.jsonBody);
}

bool readStatus(Object? value) {
  if (value case final bool status) {
    return status;
  }
  if (value case {'status': final bool status}) {
    return status;
  }
  if (value case {'success': final bool success}) {
    return success;
  }
  return true;
}

Map<String, Object?>? readOptionalObject(Map<String, Object?> body, String key) {
  final value = body[key];
  if (value == null) {
    return null;
  }
  return readJsonObject(value, key);
}

String? parseRoleInput(Object? value, String errorCode) {
  if (value == null) {
    return null;
  }

  if (value case final String role) {
    final trimmed = role.trim();
    if (trimmed.isEmpty) {
      throw HippoAuthBackendException(400, errorCode, 'Role must not be empty.');
    }
    return trimmed;
  }

  if (value case final List<Object?> roles) {
    if (roles.isEmpty) {
      return null;
    }
    if (roles.length > 1) {
      throw HippoAuthBackendException(400, errorCode, 'At most one role may be provided.');
    }
    return parseRoleInput(roles.single, errorCode);
  }

  throw HippoAuthBackendException(400, errorCode, 'Invalid role value.');
}

int? readIntQuery(Map<String, String> query, String key, {int? min, int? max}) {
  final raw = query[key];
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final value = int.tryParse(raw);
  if (value == null || (min != null && value < min) || (max != null && value > max)) {
    throw FormatException('Invalid query parameter "$key".');
  }
  return value;
}
