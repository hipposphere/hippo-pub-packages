import 'package:dart_edge_core/dart_edge_core.dart';

import '../shared/route_context.dart';
import 'callback/route.dart';
import 'sign_in/route.dart';

void mountOAuth2Routes<TServices>(Router<TServices> router, HippoAuthRouteContext context) {
  router.routeGet('/sign-in/<providerId>', OAuth2SignInRoute<TServices>());
  router.routeGet('/callback/<providerId>', OAuth2CallbackRoute<TServices>());
}
