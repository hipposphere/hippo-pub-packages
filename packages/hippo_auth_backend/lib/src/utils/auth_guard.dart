import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

import 'api_error.dart';
import 'session_cookie_names.dart';

final class HippoAuthGuard<TServices> implements Guard<TServices> {
  HippoAuthGuard({required this.auth, required this.sessionCookieName, this.allowedRoles});

  final DartEdgeAuth auth;
  final String sessionCookieName;
  final List<String>? allowedRoles;

  @override
  Future<GuardResult> authorize(RequestContext<TServices> ctx) async {
    final headers = _authHeaders(ctx.req.headersMap);
    if (!headers.containsKey('authorization') && !headers.containsKey('cookie')) {
      return GuardResult.deny(hippoAuthErrorResponse(401, 'Unauthorized', 'Unauthorized.'));
    }

    final sessionResult = await auth.api.tryGetSession(headers: headers);
    if (sessionResult == null) {
      return GuardResult.deny(hippoAuthErrorResponse(401, 'Unauthorized', 'Unauthorized.'));
    }

    final identity = DartEdgeAuthIdentity(
      session: sessionResult.session,
      user: sessionResult.user,
      response: sessionResult,
    );
    ctx.put(identity);

    final roles = allowedRoles;
    if (roles != null && !_hasAnyRole(identity.user.role, roles)) {
      return GuardResult.deny(hippoAuthErrorResponse(403, 'Forbidden', 'Forbidden.'));
    }

    return const GuardResult.allow();
  }

  Map<String, String> _authHeaders(Map<String, String> requestHeaders) {
    return authHeadersForBetterAuth(requestHeaders, sessionCookieName);
  }

  @override
  String toString() => 'HippoAuthGuard<$TServices>()';
}

Map<String, String> authHeadersForBetterAuth(
  Map<String, String> requestHeaders,
  String sessionCookieName,
) {
  final headers = <String, String>{
    for (final entry in requestHeaders.entries) entry.key.toLowerCase(): entry.value,
  };
  final token = resolveSessionToken(headers, sessionCookieName);
  if (token != null) {
    headers['cookie'] = _upsertCookie(headers['cookie'], betterAuthSessionCookieName, token);
  }
  return headers;
}

String? resolveSessionToken(Map<String, String> headers, String sessionCookieName) {
  final authorization = headers['authorization'];
  if (authorization != null) {
    final parts = authorization.trim().split(RegExp(r'\s+'));
    if (parts.length == 2 && parts.first.toLowerCase() == 'bearer') {
      return _decodeCookieValue(parts.last);
    }
  }

  final cookie = headers['cookie'];
  if (cookie == null) {
    return null;
  }

  for (final name in betterAuthSessionCookieAliases(sessionCookieName)) {
    final token = _readCookie(cookie, name);
    if (token != null) {
      return token;
    }
  }
  return null;
}

String _upsertCookie(String? cookieHeader, String name, String value) {
  final encodedValue = Uri.encodeComponent(_decodeCookieValue(value));
  final cookie = '$name=$encodedValue';
  if (cookieHeader == null || cookieHeader.trim().isEmpty) {
    return cookie;
  }

  final parts = <String>[];
  var replaced = false;
  for (final rawPart in cookieHeader.split(';')) {
    final part = rawPart.trim();
    if (part.isEmpty) {
      continue;
    }
    final index = part.indexOf('=');
    if (index < 0) {
      parts.add(part);
      continue;
    }
    final cookieName = part.substring(0, index).trim();
    if (cookieName == name) {
      if (!replaced) {
        parts.add(cookie);
        replaced = true;
      }
    } else {
      parts.add(part);
    }
  }

  if (!replaced) {
    parts.add(cookie);
  }
  return parts.join('; ');
}

String? _readCookie(String cookieHeader, String name) {
  for (final part in cookieHeader.split(';')) {
    final index = part.indexOf('=');
    if (index < 0) {
      continue;
    }
    final cookieName = part.substring(0, index).trim();
    if (cookieName == name) {
      return _decodeCookieValue(part.substring(index + 1).trim());
    }
  }
  return null;
}

String _decodeCookieValue(String value) {
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    return value;
  }
}

bool _hasAnyRole(Object? rawRole, List<String> allowedRoles) {
  final allowed = allowedRoles.map((role) => role.trim()).where((role) => role.isNotEmpty).toSet();
  if (allowed.isEmpty) {
    return true;
  }

  final roles = switch (rawRole) {
    final String role => role.split(',').map((value) => value.trim()),
    final List<Object?> roleList => roleList.map((value) => value?.toString().trim() ?? ''),
    _ => const Iterable<String>.empty(),
  };

  return roles.any(allowed.contains);
}
