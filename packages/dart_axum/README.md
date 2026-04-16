# dart_axum

`dart_axum` provides an Express-style Dart API on top of a native Rust [Axum](https://github.com/tokio-rs/axum) runtime. Route declarations, middleware, typed contracts, OpenAPI generation, and websocket handlers live in Dart; the HTTP transport, request parsing, and websocket upgrade path run in Rust via `dart:ffi`, build hooks, and `native_toolchain_rust`.

## What You Get

- Express-like route registration with ordered matching
- Global and per-route middleware
- Typed request/response contracts that can be wired manually or generated later
- Built-in OpenAPI 3.1 document generation
- Optional `/openapi.json` and `/docs` endpoints
- Server-sent events with a dedicated Dart-side streaming API
- Websocket routes backed by native Axum upgrade handling
- Multipart form-data parsing from Dart request contexts
- Native builds through Dart build hooks with `ffi 2.2.0`, `hooks 1.0.2`, `code_assets 1.0.0`, and `native_toolchain_rust 1.0.3`

## Runtime Requirements

- Dart SDK `>=3.11.0 <4.0.0`
- Rust toolchain managed through `native/rust-toolchain.toml`
- Supported native targets in the package today:
  - macOS arm64/x64
  - Linux arm64/x64
  - Windows arm64/x64

## Quick Start

```dart
import 'dart:convert';

import 'package:dart_axum/dart_axum.dart';

final createUserComponent = AxumSchemaComponent.object(
  name: 'CreateUserRequest',
  properties: <String, AxumSchema>{
    'name': AxumSchema.string(),
  },
  required: const <String>{'name'},
);

final userComponent = AxumSchemaComponent.object(
  name: 'UserRecord',
  properties: <String, AxumSchema>{
    'id': AxumSchema.string(),
    'name': AxumSchema.string(),
  },
  required: const <String>{'id', 'name'},
);

final createUserType = AxumJsonType<CreateUser>.component(
  decodeJson: CreateUser.fromJsonObject,
  encodeJson: (value) => value.toJson(),
  component: createUserComponent,
);

final userType = AxumJsonType<UserRecord>.component(
  decodeJson: UserRecord.fromJsonObject,
  encodeJson: (value) => value.toJson(),
  component: userComponent,
);

Future<void> main() async {
  final app = AxumApp(
    openApi: const AxumOpenApi(
      info: AxumOpenApiInfo(
        title: 'Users API',
        version: '1.0.0',
        description: 'Example dart_axum server',
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
        'x-powered-by': const <String>['dart_axum'],
      },
    );
  });

  app.get(
    '/health',
    handler: (_) => AxumResponse.json(<String, Object?>{'ok': true}),
    docs: const AxumRouteDocs(summary: 'Health check'),
  );

  final createUserRoute = AxumTypedRouteDefinition<CreateUser, UserRecord>(
    method: AxumMethod.post,
    path: '/users',
    request: createUserType,
    response: userType,
    docs: AxumRouteDocs(
      summary: 'Create a user',
      tags: const <String>['users', 'contracts'],
      responses: <int, AxumResponseDocs>{
        201: AxumResponseDocs(
          description: 'Created',
          schema: userComponent.reference,
          components: <AxumSchemaComponent>[userComponent],
        ),
      },
    ),
  );

  app.register<CreateUser, UserRecord>(
    createUserRoute,
    handler: (context) async {
      final record = UserRecord(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        name: context.body.name,
      );
      return record;
    },
  );

  app.ws('/chat/:roomId', (socket) async {
    await socket.sendJson(<String, Object?>{
      'kind': 'joined',
      'roomId': socket.params['roomId'],
    });

    await for (final message in socket.messages) {
      if (message is AxumWebSocketTextMessage) {
        final decoded = jsonDecode(message.text) as Map<String, Object?>;
        if (decoded['kind'] == 'ping') {
          await socket.sendJson(<String, Object?>{
            'kind': 'pong',
            'roomId': socket.params['roomId'],
          });
        }
      }
    }
  });

  final server = await app.listen(port: 8080);
  print('Listening on ${server.baseUri}');
}

final class CreateUser {
  CreateUser({required this.name});

  final String name;

  static CreateUser fromJsonObject(Object? raw) {
    final json = raw as Map<String, Object?>;
    return CreateUser(name: json['name']! as String);
  }

  Map<String, Object?> toJson() => <String, Object?>{'name': name};
}

final class UserRecord {
  UserRecord({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  static UserRecord fromJsonObject(Object? raw) {
    final json = raw as Map<String, Object?>;
    return UserRecord(
      id: json['id']! as String,
      name: json['name']! as String,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
      };
}
```

## Notes

- Route matching is ordered, like Express.
- The Rust runtime is intentionally generic: Dart owns application routing and type-safe codecs, while Axum owns transport and websocket upgrade handling.
- `AxumType` and `AxumRouteDefinition` are the stable contract layer for handwritten routes today and future code generation later.
- `AxumRouter` lets you group related routes in separate files and mount them under a prefix with `app.mount('/users', buildUsersRouter())`.
- `app.sse(...)` lets Dart stream native `text/event-stream` responses without dropping down into Rust.
- `context.multipartFormData()` parses `multipart/form-data` bodies, including file parts, directly from a raw route.
- OpenAPI generation can now hoist reusable request/response models into `components.schemas` and reference them with `$ref`.
- The package serves `/openapi.json` and `/docs` automatically when `openApi` is configured.

## Mounted Routers

```dart
// lib/routes/users_router.dart
AxumRouter buildUsersRouter() {
  return AxumRouter(
    build: (router) {
      router.get('/', handler: (_) => AxumResponse.json(<Object?>[]));
      router.get('/:userId', handler: (context) {
        return AxumResponse.json(<String, Object?>{'id': context.params['userId']});
      });
    },
  );
}

// main.dart
final app = AxumApp();
app.mount('/users', buildUsersRouter());
```

Mounted router paths are joined automatically, so `'/'` becomes `/users` and `'/:userId'` becomes `/users/{userId}` in OpenAPI.

## Development

From the package directory:

```bash
cd packages/dart_axum
dart pub get
dart analyze
dart test
```
