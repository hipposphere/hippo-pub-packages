import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:hippo_auth/hippo_auth.dart';

class HippoAuthorizationTokenRequestInterceptor implements Interceptor {
  final AuthSession? Function() getSession;
  final Future<AuthSession?> Function() refreshSession;
  final List<String> excludedPaths;

  HippoAuthorizationTokenRequestInterceptor({
    required this.getSession,
    required this.refreshSession,
    this.excludedPaths = const [],
  });

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    // DOnt add the header for sign_in and sign_up requests
    if (chain.request.url.path.contains('sign_in_email') ||
        chain.request.url.path.contains('sign_up_email') ||
        chain.request.url.path.contains('sign_in_sso') ||
        chain.request.url.path.contains('request_password_reset') ||
        excludedPaths.any((path) => chain.request.url.path.contains(path))) {
      return chain.proceed(chain.request);
    }
    if (chain.request.headers['Authorization'] == null) {
      AuthSession? session = getSession();
      if (session == null) {
        // ignore: avoid_print
        print('Session is null, trying to refresh session');
        session = await refreshSession();
      }
      if (session != null && session.isExpired) {
        // ignore: avoid_print
        print('Session is expired, trying to refresh session');
        session = await refreshSession();
      }

      if (session != null) {
        final authorizedRequest = applyHeader(
          chain.request,
          'Authorization',
          'Bearer ${session.token}',
        );
        return chain.proceed(authorizedRequest);
      }
    }

    return chain.proceed(chain.request);
  }
}
