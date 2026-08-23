import 'package:dart_better_auth/dart_better_auth.dart';
import 'package:dart_http_core/dart_http_core.dart';

import '../../../utils/api_error.dart';
import '../../../utils/auth_response_token.dart';
import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class OAuth2CallbackRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  OAuth2CallbackRoute(this.context)
    : super(error: const HippoAuthRouteError('OAuth2CallbackFailed', 'OAuth2 callback failed.'));

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => oauth2CallbackRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    final providerId = ctx.req.param('providerId');
    final oauthError = ctx.req.queryParam('error');
    final oauthErrorDescription = ctx.req.queryParam('error_description');
    if (oauthError != null && oauthError.isNotEmpty) {
      return hippoAuthErrorResponse(
        400,
        'OAuth2CallbackFailed',
        oauthErrorDescription ?? oauthError,
        details: {
          'provider_id': providerId,
          'oauth_error': oauthError,
          'oauth_error_description': ?oauthErrorDescription,
        },
      );
    }

    final code = ctx.req.queryParam('code');
    final state = ctx.req.queryParam('state');
    if (providerId == null ||
        providerId.isEmpty ||
        code == null ||
        code.isEmpty ||
        state == null ||
        state.isEmpty) {
      return hippoAuthErrorResponse(
        400,
        'OAuth2CallbackFailed',
        'Missing OAuth2 callback provider, code, or state.',
        details: {'provider_id': providerId},
      );
    }

    final relayRedirectLocation = await context.verifications.oauthRelayCallbackUrl(state);
    final redirectLocation =
        relayRedirectLocation ?? await context.verifications.oauthCallbackUrl(state);
    if (redirectLocation == null || redirectLocation.isEmpty) {
      return hippoAuthErrorResponse(
        400,
        'OAuth2CallbackUnknownState',
        'OAuth2 callback state is unknown or expired.',
        details: {'provider_id': providerId},
      );
    }

    final DartBetterAuthApiResponse authResponse;
    try {
      authResponse = await context
          .api(ctx)
          .oauthCallback(
            provider: providerId,
            code: code,
            state: state,
            headers: context.betterAuthHeaders(ctx),
          );
    } catch (error) {
      return hippoAuthErrorResponse(
        500,
        'OAuth2CallbackExchangeFailed',
        'OAuth2 callback exchange failed.',
        details: {'provider_id': providerId, 'error': error.toString()},
      );
    }
    if (!authResponse.isSuccess) {
      return hippoAuthExceptionResponse(
        DartBetterAuthApiException(authResponse),
        defaultStatus: authResponse.status,
        defaultCode: 'OAuth2CallbackExchangeFailed',
        defaultMessage: 'OAuth2 callback exchange failed.',
        details: {
          'provider_id': providerId,
          'auth_status': authResponse.status,
          'auth_content_type': authResponse.contentType,
          if (authResponse.body.isNotEmpty) 'auth_body': _truncated(authResponse.body),
        },
      );
    }

    final token = sessionTokenFromAuthResponse(authResponse);
    if (token == null || token.isEmpty) {
      return hippoAuthErrorResponse(
        401,
        'OAuth2CallbackMissingToken',
        'OAuth2 callback did not return a session token.',
        details: {'provider_id': providerId},
      );
    }

    final session = await context.sessions.findByToken(token);
    if (session == null) {
      return hippoAuthErrorResponse(
        401,
        'OAuth2CallbackInvalidSession',
        'OAuth2 session could not be validated.',
        details: {'provider_id': providerId},
      );
    }

    final redirectUrl = _sessionRedirectUrl(
      redirectLocation,
      token: token,
      sessionId: session.id,
      expiresAt: session.expiresAt,
    );
    if (relayRedirectLocation != null) {
      await context.verifications.deleteOAuthRelayCallbackUrl(state);
    }
    return RawResponse.text(status: 302, headers: [HttpHeader('location', redirectUrl)]);
  }
}

String _truncated(String value) {
  const maxLength = 2000;
  if (value.length <= maxLength) {
    return value;
  }
  return '${value.substring(0, maxLength)}...';
}

String _sessionRedirectUrl(
  String redirectLocation, {
  required String token,
  required String sessionId,
  required DateTime expiresAt,
}) {
  final uri = Uri.parse(redirectLocation);
  return uri
      .replace(
        queryParameters: {
          ...uri.queryParameters,
          'token': token,
          'session_id': sessionId,
          'expires_at': expiresAt.toUtc().toIso8601String(),
        },
      )
      .toString();
}
