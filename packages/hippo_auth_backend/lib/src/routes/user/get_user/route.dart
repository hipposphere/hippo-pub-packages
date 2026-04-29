import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class GetUserRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  GetUserRoute(this.context)
    : super(error: const HippoAuthRouteError('GetUserFailed', 'Failed to load user.'));

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => getUserRouteOptions;

  @override
  Object? handleJson(RequestContext<TServices> ctx) {
    final identity = ctx.requireAuthIdentity;
    return GetUserResponse(user: identity.user);
  }
}
