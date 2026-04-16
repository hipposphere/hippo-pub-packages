# dart_axum

`dart_axum` provides an Express-style Dart API on top of a native Rust [Axum](https://github.com/tokio-rs/axum) runtime. Route declarations, middleware, typed body codecs, OpenAPI generation, and websocket handlers live in Dart; the HTTP transport, request parsing, and websocket upgrade path run in Rust via `dart:ffi`, build hooks, and `native_toolchain_rust`.

## What You Get

- Express-like route registration with ordered matching
- Global and per-route middleware
- Typed request/response codecs built with Dart classes
- Built-in OpenAPI 3.1 document generation
- Optional `/openapi.json` and `/docs` endpoints
- Websocket routes backed by native Axum upgrade handling
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

final createUserCodec = AxumJsonCodec<CreateUser>(
  decodeJson: CreateUser.fromJsonObject,
  encodeJson: (value) => value.toJson(),
  schema: const AxumSchema.object(
    properties: <String, AxumSchema>{
      'name': AxumSchema.string(),
    },
    required: <String>{'name'},
  ),
);

final userCodec = AxumJsonCodec<UserRecord>(
  decodeJson: UserRecord.fromJsonObject,
  encodeJson: (value) => value.toJson(),
  schema: const AxumSchema.object(
    properties: <String, AxumSchema>{
      'id': AxumSchema.string(),
      'name': AxumSchema.string(),
    },
    required: <String>{'id', 'name'},
  ),
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

  app.postTyped<CreateUser, UserRecord>(
    '/users',
    request: createUserCodec,
    response: userCodec,
    docs: const AxumRouteDocs(
      summary: 'Create a user',
      responses: <int, AxumResponseDocs>{
        201: AxumResponseDocs(description: 'Created'),
      },
    ),
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
- OpenAPI generation is schema-driven. Supply `AxumSchema` objects on your codecs to get useful request/response docs.
- The package serves `/openapi.json` and `/docs` automatically when `openApi` is configured.

## Development

From the monorepo root:

```bash
dart pub get
dart analyze packages/dart_axum
dart test packages/dart_axum
```
