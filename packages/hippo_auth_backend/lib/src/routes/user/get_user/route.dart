import 'package:dart_better_auth/dart_better_auth.dart';
import 'package:dart_http_core/dart_http_core.dart';

import '../../../models/auth_user.dart';
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
    return GetUserResponse(user: hippobaseAuthUser(identity.user));
  }
}
