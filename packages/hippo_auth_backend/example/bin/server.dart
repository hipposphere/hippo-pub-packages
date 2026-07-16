import 'dart:io';

import 'package:dart_edge_http_server/dart_edge_http_server.dart';
import 'package:dart_edge_sql/dart_edge_sql.dart';
import 'package:hippo_auth_backend/hippo_auth_backend.dart';
import 'package:json_schema/json_schema.dart';

Future<void> main() async {
  final database = SqliteDatabase.inMemory();

  final backend = HippoAuthBackend(
    HippoAuthBackendOptions(
      workerPoolSize: 4,
      database: database,
      secret: 'example-secret-key-that-is-at-least-32-characters-long',
      baseUrl: 'http://localhost:3000',
      appName: 'Hippo Auth Example',
      exposeBetterAuthApi: true,
      manageMigrations: true,
      branding: const HippoAuthBackendBranding(
        appName: 'Hippo Auth Example',
        supportEmail: 'support@hippo.local',
      ),
    ),
  );

  final app = DartEdge<void>(
    services: () {},
    openApiDocument: OpenApiDocument(title: 'Hippo Auth Backend Example', version: '0.1.0'),
  );

  app.installSchemaRegistry(JsonSchemaRegistry(schemas: hippoAuthSchemas));

  backend.mount(app);
  OpenApiHelpers.mountJson(app, path: '/openapi.json');
  OpenApiHelpers.mountSwaggerUi(app, path: '/docs', specPath: '/openapi.json');

  final server = await app.listen(port: 3000, workers: 1);
  stdout.writeln('Hippo auth backend listening on http://127.0.0.1:${server.port}');
  stdout.writeln('Swagger UI: http://127.0.0.1:${server.port}/docs');
  stdout.writeln(
    'Reset view: http://127.0.0.1:${server.port}/views/reset-password?token=test-token&email=demo%40hippo.local',
  );
}
