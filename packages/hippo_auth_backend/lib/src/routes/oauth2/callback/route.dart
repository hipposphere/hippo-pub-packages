import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../utils/api_error.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class OAuth2CallbackRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  OAuth2CallbackRoute()
    : super(
        error: const HippoAuthRouteError(
          'OAuth2CallbackUnsupported',
          'OAuth2 callbacks are not supported by dart_edge_auth.',
          status: 501,
        ),
      );

  @override
  RouteOptions get options => oauth2CallbackRouteOptions;

  @override
  Object? handleJson(RequestContext<TServices> ctx) {
    return hippoAuthErrorResponse(
      501,
      'OAuth2CallbackUnsupported',
      'OAuth2 callbacks are not supported by dart_edge_auth.',
      details: {'provider_id': ctx.req.param('providerId')},
    );
  }
}
