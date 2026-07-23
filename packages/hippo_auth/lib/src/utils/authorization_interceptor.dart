import 'dart:async';
import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:hippo_auth/hippo_auth.dart';

class HippoAuthorizationTokenRequestInterceptor implements Interceptor {
  final AuthSession? Function() getSession;
  final Future<AuthSession?> Function() refreshSession;
  final Future<AuthSession?> Function()? resolveSession;
  final Future<bool> Function()? recoverSessionAfterUnauthorized;
  final Future<void> Function()? onUnauthorized;
  final bool Function(Response<dynamic>) isUnauthorizedResponse;
  final List<String> excludedPaths;

  HippoAuthorizationTokenRequestInterceptor({
    required this.getSession,
    required this.refreshSession,
    this.resolveSession,
    this.recoverSessionAfterUnauthorized,
    this.onUnauthorized,
    this.isUnauthorizedResponse = isHippoAuthUnauthorizedResponse,
    this.excludedPaths = const [],
  });

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final path = chain.request.url.path.replaceAll('_', '-');
    final isRefreshRequest = path.contains('refresh-session');
    if (path.contains('sign-in-email') ||
        path.contains('sign-up-email') ||
        path.contains('sign-in-sso') ||
        path.contains('request-password-reset') ||
        excludedPaths.any(
          (excludedPath) => path.contains(excludedPath.replaceAll('_', '-')),
        )) {
      return chain.proceed(chain.request);
    }
    var request = chain.request;
    if (!chain.request.headers.keys.any(
      (header) => header.toLowerCase() == 'authorization',
    )) {
      final AuthSession? session;
      if (isRefreshRequest) {
        session = getSession();
      } else if (resolveSession case final resolveSession?) {
        session = await resolveSession();
      } else {
        var resolvedSession = getSession();
        if (resolvedSession == null || resolvedSession.isExpired) {
          resolvedSession = await refreshSession();
        }
        session = resolvedSession;
      }

      if (session != null && !session.isExpired) {
        request = applyHeader(
          chain.request,
          'Authorization',
          'Bearer ${session.token}',
        );
      }
    }

    var response = await chain.proceed(request);
    if (isRefreshRequest ||
        recoverSessionAfterUnauthorized == null ||
        !isUnauthorizedResponse(response)) {
      return response;
    }

    final recovered = await recoverSessionAfterUnauthorized!();
    final recoveredSession = getSession();
    if (!recovered || recoveredSession == null || recoveredSession.isExpired) {
      await onUnauthorized?.call();
      return response;
    }

    response = await chain.proceed(
      applyHeader(
        chain.request,
        'Authorization',
        'Bearer ${recoveredSession.token}',
      ),
    );
    if (isUnauthorizedResponse(response)) {
      await onUnauthorized?.call();
    }
    return response;
  }
}

/// Whether [response] says that the bearer session itself is invalid.
///
/// The error-code fallback supports authentication backends deployed before
/// the `WWW-Authenticate` challenge was added without treating product-level
/// authorization failures as an expired session.
bool isHippoAuthUnauthorizedResponse(Response<dynamic> response) {
  if (response.statusCode != 401) {
    return false;
  }

  final challenge = response.headers['www-authenticate'];
  if (challenge?.toLowerCase().contains('bearer') ?? false) {
    return true;
  }

  try {
    final error = response.error;
    final decoded = error is String ? jsonDecode(error) : error;
    return decoded is Map &&
        decoded['error'] is Map &&
        (decoded['error'] as Map)['code'] == 'Unauthorized';
  } catch (_) {
    return false;
  }
}
