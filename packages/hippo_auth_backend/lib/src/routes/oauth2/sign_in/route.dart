import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

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

    final result = await context
        .api(ctx)
        .signInOAuth(provider: providerId, callbackUrl: callbackUrl);
    if (result.redirect) {
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
