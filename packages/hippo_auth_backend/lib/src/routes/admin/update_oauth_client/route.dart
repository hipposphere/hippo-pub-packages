import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../utils/api_error.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class AdminUpdateOAuthClientRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  AdminUpdateOAuthClientRoute()
    : super(
        error: const HippoAuthRouteError(
          'AdminUpdateOAuthClientUnsupported',
          'OAuth client management is not supported by dart_edge_auth.',
          status: 501,
        ),
      );

  @override
  RouteOptions get options => adminUpdateOAuthClientRouteOptions;

  @override
  Object? handleJson(RequestContext<TServices> ctx) {
    return hippoAuthErrorResponse(
      501,
      'AdminUpdateOAuthClientUnsupported',
      'OAuth client management is not supported by dart_edge_auth.',
    );
  }
}
