import 'dart:convert';

import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../utils/api_error.dart';
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

    final redirectLocation = await context.verifications.oauthCallbackUrl(state);
    final authResponse = await context
        .api(ctx)
        .oauthCallback(
          provider: providerId,
          code: code,
          state: state,
          headers: context.betterAuthHeaders(ctx),
        );
    if (!authResponse.isSuccess) {
      throw DartEdgeAuthApiException(authResponse);
    }

    final token = _token(authResponse);
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

    if (redirectLocation == null || redirectLocation.isEmpty) {
      return hippoAuthErrorResponse(
        500,
        'OAuth2CallbackMissingRedirect',
        'OAuth2 callback did not return a redirect location.',
        details: {'provider_id': providerId},
      );
    }

    final redirectUrl = _sessionRedirectUrl(
      redirectLocation,
      token: token,
      sessionId: session.id,
      expiresAt: session.expiresAt,
    );
    return RawResponse.text(status: 302, headers: [HttpHeader('location', redirectUrl)]);
  }
}

String? _token(DartEdgeAuthApiResponse response) {
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
  return response.header('set-auth-token');
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
