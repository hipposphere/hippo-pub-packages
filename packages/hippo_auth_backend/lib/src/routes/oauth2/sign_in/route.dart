import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../options.dart';
import '../../../utils/api_error.dart';
import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class OAuth2SignInRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  OAuth2SignInRoute(this.context)
    : super(
        error: const HippoAuthRouteError(
          'SSOLoginInitiationFailed',
          'Failed to initiate SSO login.',
        ),
      );

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => oauth2SignInRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    final providerId = ctx.req.param('providerId');
    final callbackUrl = ctx.req.queryParam('callbackURL');
    if (providerId == null || providerId.isEmpty || callbackUrl == null || callbackUrl.isEmpty) {
      return hippoAuthErrorResponse(
        400,
        'SSOLoginInitiationFailed',
        'Missing OAuth2 provider or callback URL.',
        details: {'provider_id': providerId},
      );
    }

    if (!_isTrustedAppCallbackUrl(context.options, callbackUrl)) {
      return hippoAuthErrorResponse(
        400,
        'SSOLoginInitiationFailed',
        'callbackURL must be an absolute http(s) URL on the auth origin, a trusted origin, or a loopback origin.',
        details: {'provider_id': providerId},
      );
    }

    final providerRedirectUrl = _providerRedirectUrl(context.options, providerId);
    if (!_isAbsoluteHttpUrl(providerRedirectUrl)) {
      return hippoAuthErrorResponse(
        400,
        'SSOLoginInitiationFailed',
        'OAuth2 provider redirect URL must be an absolute http(s) URL.',
        details: {'provider_id': providerId},
      );
    }

    final result = await context
        .api(ctx)
        .signInOAuth(provider: providerId, callbackUrl: providerRedirectUrl);
    if (result.redirect) {
      final state = _oauthState(result.url);
      if (state == null || state.isEmpty) {
        return hippoAuthErrorResponse(
          500,
          'SSOLoginInitiationFailed',
          'OAuth2 login initiation did not return a state parameter.',
          details: {'provider_id': providerId},
        );
      }
      await context.verifications.storeOAuthRelayCallbackUrl(
        state: state,
        callbackUrl: callbackUrl,
      );
      return RawResponse.text(
        status: 302,
        headers: [..._forwardedHeaders(result.response), HttpHeader('location', result.url)],
      );
    }

    return RawResponse.encoded(
      status: result.response.status,
      contentType: result.response.contentType,
      body: result.response.body,
      headers: _forwardedHeaders(result.response),
    );
  }
}

List<HttpHeader> _forwardedHeaders(DartEdgeAuthApiResponse response) {
  return [
    for (final header in response.headers)
      if (header.name.toLowerCase() != 'content-length') header,
  ];
}

String _providerRedirectUrl(HippoAuthBackendOptions options, String providerId) {
  for (final provider in options.ssoProviders) {
    if (provider.providerId.trim() != providerId) {
      continue;
    }
    final redirectUrl = provider.redirectUrl?.trim();
    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      return redirectUrl;
    }
    break;
  }
  return _defaultOAuthCallbackUrl(options.baseUrl, providerId);
}

String _defaultOAuthCallbackUrl(String baseUrl, String providerId) {
  final uri = Uri.tryParse(baseUrl);
  if (uri == null || !_isHttpScheme(uri) || uri.host.isEmpty) {
    return '';
  }
  final path = uri.path.endsWith('/')
      ? '${uri.path}v1/oauth2/callback/${Uri.encodeComponent(providerId)}'
      : '${uri.path}/v1/oauth2/callback/${Uri.encodeComponent(providerId)}';
  return uri.replace(path: path, query: null, fragment: null).toString();
}

String? _oauthState(String authorizationUrl) {
  final uri = Uri.tryParse(authorizationUrl);
  return uri?.queryParameters['state'];
}

bool _isTrustedAppCallbackUrl(HippoAuthBackendOptions options, String callbackUrl) {
  final uri = Uri.tryParse(callbackUrl);
  if (uri == null || !_isHttpScheme(uri) || uri.host.isEmpty) {
    return false;
  }
  if (options.allowLoopbackOAuthCallbackUrls && _isLoopbackHost(uri.host)) {
    return true;
  }

  final baseUrl = Uri.tryParse(options.baseUrl);
  if (baseUrl != null && _isHttpScheme(baseUrl) && uri.origin == baseUrl.origin) {
    return true;
  }

  for (final trustedOrigin in options.trustedOrigins) {
    final trustedUri = Uri.tryParse(trustedOrigin.trim());
    if (trustedUri != null && _isHttpScheme(trustedUri) && uri.origin == trustedUri.origin) {
      return true;
    }
  }
  return false;
}

bool _isAbsoluteHttpUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null && _isHttpScheme(uri) && uri.host.isNotEmpty;
}

bool _isHttpScheme(Uri uri) => uri.scheme == 'http' || uri.scheme == 'https';

bool _isLoopbackHost(String host) {
  final normalized = host.toLowerCase();
  if (normalized == 'localhost' || normalized == '::1' || normalized == '[::1]') {
    return true;
  }
  final parts = normalized.split('.');
  if (parts.length != 4 || parts.first != '127') {
    return false;
  }
  return parts.every((part) {
    final value = int.tryParse(part);
    return value != null && value >= 0 && value <= 255;
  });
}
