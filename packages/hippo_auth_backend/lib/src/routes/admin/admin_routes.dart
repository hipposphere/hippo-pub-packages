import 'package:dart_edge_core/dart_edge_core.dart';

import '../shared/route_context.dart';
import 'create_oauth_client/route.dart';
import 'create_user/route.dart';
import 'delete_oauth_client/route.dart';
import 'delete_user/route.dart';
import 'list_oauth_clients/route.dart';
import 'list_users/route.dart';
import 'update_oauth_client/route.dart';
import 'update_user/route.dart';

void mountAdminRoutes<TServices>(Router<TServices> router, HippoAuthRouteContext context) {
  final adminRouter = router.router('', guards: [context.adminGuard<TServices>()]);

  adminRouter.routePost('/create-user', AdminCreateUserRoute<TServices>(context));
  adminRouter.routeGet('/list-users', AdminListUsersRoute<TServices>(context));
  adminRouter.routePost('/update-user', AdminUpdateUserRoute<TServices>(context));
  adminRouter.routePost('/delete-user', AdminDeleteUserRoute<TServices>(context));
  adminRouter.routePost('/create-oauth-client', AdminCreateOAuthClientRoute<TServices>());
  adminRouter.routeGet('/list-oauth-clients', AdminListOAuthClientsRoute<TServices>());
  adminRouter.routePost('/update-oauth-client', AdminUpdateOAuthClientRoute<TServices>());
  adminRouter.routePost('/delete-oauth-client', AdminDeleteOAuthClientRoute<TServices>());
}
