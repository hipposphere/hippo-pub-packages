import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../utils/api_error.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class AdminDeleteOAuthClientRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  AdminDeleteOAuthClientRoute()
    : super(
        error: const HippoAuthRouteError(
          'AdminDeleteOAuthClientUnsupported',
          'OAuth client management is not supported by dart_edge_auth.',
          status: 501,
        ),
      );

  @override
  RouteOptions get options => adminDeleteOAuthClientRouteOptions;

  @override
  Object? handleJson(RequestContext<TServices> ctx) {
    return hippoAuthErrorResponse(
      501,
      'AdminDeleteOAuthClientUnsupported',
      'OAuth client management is not supported by dart_edge_auth.',
    );
  }
}
