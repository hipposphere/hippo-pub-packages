import 'dart:math' as math;

import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

import '../../utils/api_error.dart';
import '../../utils/user_payload.dart';

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

Map<String, Object?> listUsersResponse(
  DartEdgeAuthListUsersResult result, {
  required int requestedLimit,
  required int requestedOffset,
}) {
  final users = result.users.map(authUserFromUsersRow).toList(growable: false);
  final limit = result.limit == 0 ? requestedLimit : result.limit;
  final offset = result.offset;
  final total = math.max(0, result.total);
  final totalPages = math.max(1, (total / limit).ceil());
  final page = math.min(totalPages, (offset / limit).floor() + 1);

  return {
    'users': users,
    'total': total,
    'limit': limit,
    'offset': offset,
    'page': page,
    'page_size': limit,
    'total_pages': totalPages,
  };
}

int? readInt(Object? value) {
  if (value case final int intValue) {
    return intValue;
  }
  if (value case final num numValue) {
    return numValue.toInt();
  }
  if (value case final String text) {
    return int.tryParse(text);
  }
  return null;
}

Map<String, Object?> userFromResponse(DartEdgeAuthUserResult response) {
  return authUserFromUsersRow(response.user);
}

Future<Map<String, Object?>> findAdminUser(DartEdgeAuthAdminApi admin, String userId) async {
  final response = await admin.listUsers(limit: 1, filterField: 'id', filterValue: userId);
  if (response.users case [final user, ...]) {
    return authUserFromUsersRow(user);
  }
  throw const HippoAuthBackendException(
    500,
    'AdminUserLookupFailed',
    'Updated user could not be found.',
  );
}
