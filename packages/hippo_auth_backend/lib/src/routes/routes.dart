import 'package:dart_http_core/dart_http_core.dart';

import 'admin/admin_routes.dart';
import 'oauth2/oauth2_routes.dart';
import 'shared/route_context.dart';
import 'user/user_routes.dart';

void mountHippoAuthApiRoutes<TServices>(Router<TServices> router, HippoAuthRouteContext context) {
  mountUserRoutes(router.router('/v1/user', tags: const ['hippo-auth:user']), context);
  mountAdminRoutes(router.router('/v1/admin', tags: const ['hippo-auth:admin']), context);
  mountOAuth2Routes(router.router('/v1/oauth2', tags: const ['hippo-auth:oauth2']), context);
}
