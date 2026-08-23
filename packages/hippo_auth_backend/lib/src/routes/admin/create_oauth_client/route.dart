import 'package:dart_http_core/dart_http_core.dart';

import '../../../utils/api_error.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class AdminCreateOAuthClientRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  AdminCreateOAuthClientRoute()
    : super(
        error: const HippoAuthRouteError(
          'AdminCreateOAuthClientUnsupported',
          'OAuth client management is not supported by dart_better_auth.',
          status: 501,
        ),
      );

  @override
  RouteOptions get options => adminCreateOAuthClientRouteOptions;

  @override
  Object? handleJson(RequestContext<TServices> ctx) {
    return hippoAuthErrorResponse(
      501,
      'AdminCreateOAuthClientUnsupported',
      'OAuth client management is not supported by dart_better_auth.',
    );
  }
}
