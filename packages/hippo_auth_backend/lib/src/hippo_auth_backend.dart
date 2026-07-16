import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_http_server_runtime/dart_edge_http_server_runtime.dart';
import 'package:json_schema/json_schema.dart';

import 'options.dart';
import 'routes/routes.dart';
import 'routes/shared/route_context.dart';
import 'utils/schemas.dart';
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
    _installSchemas(router);
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

void _installSchemas<TServices>(Router<TServices> router) {
  if (router is! DartEdge<TServices>) {
    return;
  }

  final schemas = <JsonSchema>[];
  final seenIds = <String>{};

  void addSchema(JsonSchema schema) {
    final id = schema.id;
    if (id != null && !seenIds.add(id)) {
      return;
    }
    schemas.add(schema);
  }

  for (final schema in router.schemaRegistry?.schemas ?? const <JsonSchema>[]) {
    addSchema(schema);
  }
  for (final schema in hippoAuthSchemas) {
    addSchema(schema);
  }

  router.installSchemaRegistry(JsonSchemaRegistry(schemas: schemas));
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
