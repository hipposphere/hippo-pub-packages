import 'dart:convert';

import 'package:dart_edge_auth/dart_edge_auth.dart';

String? sessionTokenFromAuthResponse(DartEdgeAuthApiResponse response) {
  final jsonBody = response.jsonBody;
  if (jsonBody case {'token': final String token}) {
    return token;
  }
  if (response.body.isNotEmpty) {
    final parsed = jsonDecode(response.body);
    if (parsed case {'token': final String token}) {
      return token;
    }
  }
  return response.header('set-auth-token') ?? _sessionCookieToken(response);
}

String? _sessionCookieToken(DartEdgeAuthApiResponse response) {
  for (final header in response.headers) {
    if (header.name.toLowerCase() != 'set-cookie') {
      continue;
    }
    final token = _readCookie(header.value, 'better-auth.session-token');
    if (token != null && token.isNotEmpty) {
      return token;
    }
  }
  return null;
}

String? _readCookie(String cookieHeader, String name) {
  for (final part in cookieHeader.split(';')) {
    final index = part.indexOf('=');
    if (index < 0) {
      continue;
    }
    final cookieName = part.substring(0, index).trim();
    if (cookieName == name) {
      return Uri.decodeComponent(part.substring(index + 1).trim());
    }
  }
  return null;
}
