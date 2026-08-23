import 'package:dart_http_core/dart_http_core.dart';

import '../../../utils/api_error.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class AdminListOAuthClientsRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  AdminListOAuthClientsRoute()
    : super(
        error: const HippoAuthRouteError(
          'AdminListOAuthClientsUnsupported',
          'OAuth client management is not supported by dart_better_auth.',
          status: 501,
        ),
      );

  @override
  RouteOptions get options => adminListOAuthClientsRouteOptions;

  @override
  Object? handleJson(RequestContext<TServices> ctx) {
    return hippoAuthErrorResponse(
      501,
      'AdminListOAuthClientsUnsupported',
      'OAuth client management is not supported by dart_better_auth.',
    );
  }
}
