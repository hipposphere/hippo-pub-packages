import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../models/auth_user.dart';
import '../../../utils/api_error.dart';
import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import '../../shared/route_utils.dart';
import 'schema.dart';

final class AdminUpdateUserRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  AdminUpdateUserRoute(this.context)
    : super(error: const HippoAuthRouteError('AdminUpdateUserFailed', 'Failed to update user.'));

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => adminUpdateUserRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    context.ensureAdminEnabled();
    final body = ctx.req.body<AdminUpdateUserBody>();
    final userId = body.userId;
    final data = body.data ?? const <String, Object?>{};
    final unsupportedFields = data.keys.where((field) => field != 'role').toList(growable: false);
    if (unsupportedFields.isNotEmpty) {
      throw HippoAuthBackendException(
        501,
        'AdminUpdateUserDataUnsupported',
        'Generic admin user data updates are not supported by dart_edge_auth.',
        details: {'fields': unsupportedFields},
      );
    }

    final role =
        parseRoleInput(body.role, 'AdminUpdateUserInvalidRole') ??
        parseRoleInput(data['role'], 'AdminUpdateUserInvalidRole');
    if (role == null) {
      throw const HippoAuthBackendException(
        400,
        'AdminUpdateUserInvalidRequest',
        'At least one of role or data must be provided.',
      );
    }

    final admin = context.adminApi(ctx);
    final response = await admin.setRole(userId: userId, role: role);
    return AdminUpdateUserResponse(user: hippobaseAuthUser(response.user));
  }
}
