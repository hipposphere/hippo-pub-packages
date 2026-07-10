import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../models/auth_user.dart';
import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class LogoutRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  LogoutRoute(this.context)
    : super(error: const HippoAuthRouteError('LogoutFailed', 'Logout failed.'));

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => logoutRouteOptions;

  @override
  Object? handleJson(RequestContext<TServices> ctx) {
    return LogoutResponse(user: hippobaseAuthUser(ctx.requireAuthIdentity.user));
  }
}
