import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

import 'options.dart';
import 'routes/routes.dart';
import 'routes/shared/route_context.dart';
import 'views/views.dart';

final class HippoAuthBackend {
  HippoAuthBackend(this.options) : auth = DartEdgeAuth(options.toDartEdgeAuthConfig());

  final HippoAuthBackendOptions options;
  final DartEdgeAuth auth;

  Router<TServices> createRouter<TServices>({String basePath = ''}) {
    final router = Router<TServices>();
    mount(router, basePath: basePath);
    return router;
  }

  void mount<TServices>(Router<TServices> router, {String basePath = ''}) {
    final target = _targetRouter(router, basePath);
    final routeContext = HippoAuthRouteContext(options: options, auth: auth);

    mountHippoAuthApiRoutes(target, routeContext);
    mountHippoAuthViews(target, options, routeBasePath: target.prefix);
    _mountBetterAuthRoutes(target);
  }

  void dispose() {
    auth.dispose();
  }

  Router<TServices> _targetRouter<TServices>(Router<TServices> router, String basePath) {
    final normalizedBasePath = _normalizeBasePath(basePath);
    if (normalizedBasePath.isEmpty) {
      return router;
    }
    return router.router(normalizedBasePath);
  }

  void _mountBetterAuthRoutes<TServices>(Router<TServices> router) {
    if (!options.exposeBetterAuthApi) {
      return;
    }

    final authRouter = router.router('', tags: const ['better-auth']);
    if (options.useNativeBetterAuthRoutes && router.prefix.isEmpty) {
      auth.mountNative(authRouter);
    } else {
      auth.mount(authRouter);
    }
  }
}

String _normalizeBasePath(String value) {
  var normalized = value.trim();
  if (normalized.isEmpty || normalized == '/') {
    return '';
  }
  if (!normalized.startsWith('/')) {
    normalized = '/$normalized';
  }
  while (normalized.endsWith('/') && normalized.length > 1) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}
