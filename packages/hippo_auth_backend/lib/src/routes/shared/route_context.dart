import 'dart:io';

import 'package:dart_better_auth/dart_better_auth.dart';
import 'package:dart_http_core/dart_http_core.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';

import '../../utils/api_error.dart';
import '../../utils/auth_guard.dart';
import '../../utils/session_cookie_names.dart';
import '../../gateways/session_gateway.dart';
import '../../gateways/verification_gateway.dart';
import '../../models/hippo_auth_session_payload.dart';
import '../../models/auth_user.dart';
import '../../options.dart';

final class HippoAuthRouteContext {
  HippoAuthRouteContext({required this.options, required this.auth})
    : sessions = SessionGateway(options.database, schema: options.normalizedDatabaseSchema),
      verifications = VerificationGateway(
        options.database,
        schema: options.normalizedDatabaseSchema,
      );

  final HippoAuthBackendOptions options;
  final DartBetterAuth auth;
  final SessionGateway sessions;
  final VerificationGateway verifications;

  HippoAuthGuard<TServices> adminGuard<TServices>() {
    return HippoAuthGuard<TServices>(
      auth: auth,
      sessionCookieName: options.sessionCookieName,
      allowedRoles: options.admin.normalizedAdminRoles,
    );
  }

  DartBetterAuthApi api<TServices>(RequestContext<TServices> ctx) {
    return auth.api.withHeaders(betterAuthHeaders(ctx));
  }

  DartBetterAuthAdminApi adminApi<TServices>(RequestContext<TServices> ctx) {
    return api(ctx).admin;
  }

  Map<String, String> betterAuthHeaders<TServices>(RequestContext<TServices> ctx) {
    return authHeadersForBetterAuth(ctx.req.headersMap, options.sessionCookieName);
  }

  String sessionToken<TServices>(RequestContext<TServices> ctx) {
    final token = resolveSessionToken(betterAuthHeaders(ctx), options.sessionCookieName);
    if (token == null) {
      throw const HippoAuthBackendException(401, 'Unauthorized', 'Unauthorized.');
    }
    return token;
  }

  List<Map<String, Object?>> ssoProvidersJson() {
    final seen = <String>{};
    final providers = <Map<String, Object?>>[];
    for (final provider in options.ssoProviders) {
      final providerId = provider.providerId.trim();
      if (providerId.isEmpty || !seen.add(providerId)) {
        continue;
      }
      providers.add(
        HippoAuthSsoProvider(providerId: providerId, providerType: provider.providerType).toJson(),
      );
    }
    return providers;
  }

  Future<HippoAuthSessionPayload> signUpSessionPayload(
    DartBetterAuthSignUpResult result,
    ResponseBuilder response,
  ) {
    return _sessionPayload(
      token: result.token,
      user: result.user,
      authResponse: result.response,
      response: response,
    );
  }

  Future<HippoAuthSessionPayload> signInSessionPayload(
    DartBetterAuthSignInResult result,
    ResponseBuilder response,
  ) {
    return _sessionPayload(
      token: result.token,
      user: result.user,
      authResponse: result.response,
      response: response,
    );
  }

  Future<HippoAuthSessionPayload> _sessionPayload({
    required String? token,
    required DartBetterAuthUser? user,
    required DartBetterAuthApiResponse authResponse,
    required ResponseBuilder response,
  }) async {
    final sessionUser = _sessionUser(user);
    final session = _createdSession(token);
    for (final header in _responseHeaders(authResponse, session)) {
      response.header(header.name, header.value);
    }
    return HippoAuthSessionPayload(
      sessionId: session.id,
      token: session.token,
      expiresAt: session.expiresAt.toUtc().toIso8601String(),
      user: sessionUser,
    );
  }

  void ensureAdminEnabled() {
    if (!options.admin.enabled) {
      throw const HippoAuthBackendException(501, 'AdminDisabled', 'Admin routes are disabled.');
    }
  }

  DartBetterAuthSession _createdSession(String? token) {
    if (token == null || token.isEmpty) {
      throw const HippoAuthBackendException(
        401,
        'SessionResultInvalid',
        'Auth session result did not contain a usable session token.',
      );
    }

    final result = DartBetterAuthSessionResult.fromResponse(
      auth.api
          .withBearerToken(token)
          .callKnownOperationSync(operation: DartBetterAuthOperation.getSession),
    );
    return result.session;
  }

  AuthUserRow _sessionUser(DartBetterAuthUser? user) {
    if (user == null) {
      throw const HippoAuthBackendException(
        401,
        'SessionResultInvalid',
        'Auth session result did not contain a usable user.',
      );
    }
    return hippobaseAuthUser(user);
  }

  List<HttpHeader> _responseHeaders(
    DartBetterAuthApiResponse response,
    DartBetterAuthSession session,
  ) {
    final headers = [
      for (final header in response.headers)
        if (_isForwardedHeader(header.name)) header,
    ];

    if (!isBetterAuthSessionCookieName(options.sessionCookieName)) {
      headers.add(HttpHeader('set-cookie', _customSessionCookie(session.token, session.expiresAt)));
    }

    return headers;
  }

  String _customSessionCookie(String token, DateTime expiresAt) {
    final secure = Uri.tryParse(options.baseUrl)?.scheme == 'https';
    return '${options.sessionCookieName}=${Uri.encodeComponent(token)}; '
        'Path=/; Expires=${HttpDate.format(expiresAt.toUtc())}; HttpOnly; SameSite=Lax'
        '${secure ? '; Secure' : ''}';
  }
}

bool _isForwardedHeader(String name) {
  final lower = name.toLowerCase();
  return lower == 'set-cookie' || lower == 'set-auth-token';
}
