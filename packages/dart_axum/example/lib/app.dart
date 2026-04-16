import 'dart:async';
import 'dart:io';

import 'package:dart_axum/dart_axum.dart';

import 'routes/root_router.dart';
import 'routes/realtime_router.dart';
import 'routes/uploads_router.dart';
import 'routes/users_router.dart';

Future<void> runExampleApp() async {
  final app = AxumApp(
    openApi: const AxumOpenApi(
      info: AxumOpenApiInfo(
        title: 'dart_axum Example API',
        version: '1.0.0',
        description: 'Small example server with mounted routers, JSON routes, and generated docs.',
      ),
    ),
  );

  app.use((context, next) async {
    final response = await next();
    return AxumResponse(
      statusCode: response.statusCode,
      body: response.body,
      headers: <String, List<String>>{
        ...response.headers,
        'x-powered-by': const <String>['dart_axum-example'],
      },
    );
  });

  app.mount('/', buildRootRouter());
  app.mount('/realtime', buildRealtimeRouter());
  app.mount('/uploads', buildUploadsRouter());
  app.mount('/users', buildUsersRouter());

  final server = await app.listen(port: 3000);
  final docsUri = server.baseUri.replace(path: '/docs');
  final openApiUri = server.baseUri.replace(path: '/openapi.json');

  stdout.writeln('Listening on ${server.baseUri}');
  stdout.writeln('OpenAPI JSON: $openApiUri');
  stdout.writeln('Docs UI: $docsUri');
  stdout.writeln('Try: curl ${server.baseUri.replace(path: '/')}');
  stdout.writeln(
    'Try: curl "${server.baseUri.replace(path: '/hello/Ada', queryParameters: <String, String>{'uppercase': 'true'})}"',
  );
  stdout.writeln('Try: curl ${server.baseUri.replace(path: '/users')}');
  stdout.writeln('Try: curl ${server.baseUri.replace(path: '/users/ada')}');
  stdout.writeln('Try: curl -N ${server.baseUri.replace(path: '/realtime/events/ticks')}');
  stdout.writeln('Try: open ${server.baseUri.replace(path: '/playground')}');
  stdout.writeln(
    "Try: curl -F 'owner=Ada' -F 'file=@README.md;type=text/plain' ${server.baseUri.replace(path: '/uploads')}",
  );
  stdout.writeln(
    "Try: curl -X POST -H 'content-type: application/json' -d '{\"name\":\"Linus\"}' ${server.baseUri.replace(path: '/users')}",
  );
  stdout.writeln('Press Ctrl+C to stop.');

  await _waitForShutdownSignal();

  stdout.writeln('Shutting down...');
  await server.close();
}

Future<void> _waitForShutdownSignal() async {
  final sigint = ProcessSignal.sigint.watch().first;
  if (Platform.isWindows) {
    await sigint;
    return;
  }

  final sigterm = ProcessSignal.sigterm.watch().first;
  await Future.any(<Future<void>>[sigint, sigterm]);
}
