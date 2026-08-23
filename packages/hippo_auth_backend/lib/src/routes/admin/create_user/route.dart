import 'package:dart_http_core/dart_http_core.dart';

import '../../../models/auth_user.dart';
import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import '../../shared/route_utils.dart';
import 'schema.dart';

final class AdminCreateUserRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  AdminCreateUserRoute(this.context)
    : super(error: const HippoAuthRouteError('AdminCreateUserFailed', 'Failed to create user.'));

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => adminCreateUserRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    context.ensureAdminEnabled();
    final body = ctx.req.body<AdminCreateUserBody>();
    final role = parseRoleInput(body.role, 'AdminCreateUserInvalidRole');
    final data = body.data;
    final response = await context
        .adminApi(ctx)
        .createUser(
          email: body.email,
          password: body.password,
          name: body.name,
          role: role,
          data: data == null || data.isEmpty ? null : data,
        );
    return AdminCreateUserResponse(user: hippobaseAuthUser(response.user));
  }
}
