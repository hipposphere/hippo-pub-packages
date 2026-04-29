import 'package:dart_edge_core/dart_edge_core.dart';

import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class AdminDeleteUserRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  AdminDeleteUserRoute(this.context)
    : super(error: const HippoAuthRouteError('AdminDeleteUserFailed', 'Failed to delete user.'));

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => adminDeleteUserRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    context.ensureAdminEnabled();
    final body = ctx.req.body<AdminDeleteUserBody>();
    final userId = body.userId;
    final response = await context.adminApi(ctx).removeUser(userId: userId);
    return AdminDeleteUserResponse(success: response.success, userId: userId);
  }
}
