import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../utils/api_error.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class OAuth2SignInRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  OAuth2SignInRoute()
    : super(
        error: const HippoAuthRouteError(
          'OAuth2SignInUnsupported',
          'OAuth2 sign-in is not supported by dart_edge_auth.',
          status: 501,
        ),
      );

  @override
  RouteOptions get options => oauth2SignInRouteOptions;

  @override
  Object? handleJson(RequestContext<TServices> ctx) {
    return hippoAuthErrorResponse(
      501,
      'OAuth2SignInUnsupported',
      'OAuth2 sign-in is not supported by dart_edge_auth.',
      details: {'provider_id': ctx.req.param('providerId')},
    );
  }
}
