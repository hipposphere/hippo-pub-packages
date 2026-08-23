import 'package:dart_better_auth/dart_better_auth.dart';
import 'package:dart_http_core/dart_http_core.dart';

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
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    final user = hippobaseAuthUser(ctx.requireAuthIdentity.user);
    final result = await context.api(ctx).signOut();
    for (final header in result.response.headers) {
      if (header.name.toLowerCase() == 'set-cookie') {
        ctx.res.header(header.name, header.value);
      }
    }
    return LogoutResponse(user: user);
  }
}
