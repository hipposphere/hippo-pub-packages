import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_axum/dart_axum.dart';
import 'package:test/test.dart';

void main() {
  test('serves typed HTTP routes, route definitions, middleware, and openapi docs', () async {
    final app = AxumApp(
      openApi: const AxumOpenApi(
        info: AxumOpenApiInfo(title: 'Integration API', version: '0.1.0'),
      ),
    );
    final usersRouter = AxumRouter();

    final createUserComponent = AxumSchemaComponent.object(
      name: 'CreateUserRequest',
      properties: <String, AxumSchema>{'name': AxumSchema.string()},
      required: const <String>{'name'},
    );
    final userComponent = AxumSchemaComponent.object(
      name: 'UserRecord',
      properties: <String, AxumSchema>{'id': AxumSchema.string(), 'name': AxumSchema.string()},
      required: const <String>{'id', 'name'},
    );

    final createUserType = AxumJsonType<_CreateUser>.component(
      decodeJson: _CreateUser.fromJsonObject,
      encodeJson: (value) => value.toJson(),
      component: createUserComponent,
    );
    final userType = AxumJsonType<_UserRecord>.component(
      decodeJson: _UserRecord.fromJsonObject,
      encodeJson: (value) => value.toJson(),
      component: userComponent,
    );

    app.use((context, next) async {
      final response = await next();
      return AxumResponse(
        statusCode: response.statusCode,
        body: response.body,
        headers: <String, List<String>>{
          ...response.headers,
          'x-middleware': const <String>['active'],
        },
      );
    });

    app.get('/health', handler: (_) => AxumResponse.json(<String, Object?>{'ok': true}));

    usersRouter.use((context, next) async {
      final response = await next();
      return AxumResponse(
        statusCode: response.statusCode,
        body: response.body,
        headers: <String, List<String>>{
          ...response.headers,
          'x-router': const <String>['users'],
        },
      );
    });

    usersRouter.register<_CreateUser, _UserRecord>(
      AxumTypedRouteDefinition<_CreateUser, _UserRecord>(
        method: AxumMethod.post,
        path: '/',
        request: createUserType,
        response: userType,
      ),
      handler: (context) => _UserRecord(id: 'user-1', name: context.body.name),
    );
    app.mount('/users', usersRouter);

    final server = await app.listen(port: 0);
    addTearDown(server.close);

    final client = HttpClient();
    addTearDown(client.close);

    final healthRequest = await client.getUrl(server.baseUri.replace(path: '/health'));
    final healthResponse = await healthRequest.close();
    final healthBody = await utf8.decodeStream(healthResponse);

    expect(healthResponse.statusCode, HttpStatus.ok);
    expect(healthResponse.headers.value('x-middleware'), 'active');
    expect(jsonDecode(healthBody), <String, Object?>{'ok': true});

    final createRequest = await client.postUrl(server.baseUri.replace(path: '/users'));
    createRequest.headers.contentType = ContentType.json;
    createRequest.write(jsonEncode(<String, Object?>{'name': 'Ada'}));
    final createResponse = await createRequest.close();
    final createBody = await utf8.decodeStream(createResponse);

    expect(createResponse.statusCode, HttpStatus.ok);
    expect(createResponse.headers.value('content-type'), startsWith('application/json'));
    expect(createResponse.headers.value('x-router'), 'users');
    expect(jsonDecode(createBody), <String, Object?>{'id': 'user-1', 'name': 'Ada'});

    final docsRequest = await client.getUrl(server.baseUri.replace(path: '/openapi.json'));
    final docsResponse = await docsRequest.close();
    final docsBody = await utf8.decodeStream(docsResponse);
    final docs = jsonDecode(docsBody) as Map<String, Object?>;

    expect(docsResponse.statusCode, HttpStatus.ok);
    expect(
      ((docs['paths']! as Map<String, Object?>)['/users']! as Map<String, Object?>).containsKey(
        'post',
      ),
      isTrue,
    );
    expect(
      (((docs['components']! as Map<String, Object?>)['schemas']! as Map<String, Object?>)
          .containsKey('UserRecord')),
      isTrue,
    );
  });

  test('serves a stable docs page shell', () async {
    final app = AxumApp(
      openApi: const AxumOpenApi(
        info: AxumOpenApiInfo(title: 'Docs API', version: '0.1.0'),
      ),
    );

    final server = await app.listen(port: 0);
    addTearDown(server.close);

    final client = HttpClient();
    addTearDown(client.close);

    final docsRequest = await client.getUrl(server.baseUri.replace(path: '/docs'));
    final docsResponse = await docsRequest.close();
    final docsBody = await utf8.decodeStream(docsResponse);

    expect(docsResponse.statusCode, HttpStatus.ok);
    expect(docsBody, contains('https://cdn.redoc.ly/redoc/latest/bundles/redoc.standalone.js'));
    expect(docsBody, contains('window.__axumOpenApiPath = "/openapi.json"'));
    expect(docsBody, contains('API docs failed to load'));
  });

  test('bridges websocket traffic through axum', () async {
    final app = AxumApp();
    final chatRouter = AxumRouter();

    chatRouter.ws('/chat/:roomId', (socket) async {
      await socket.sendJson(<String, Object?>{'kind': 'joined', 'roomId': socket.params['roomId']});

      await for (final message in socket.messages) {
        if (message is! AxumWebSocketTextMessage) {
          continue;
        }
        final payload = jsonDecode(message.text) as Map<String, Object?>;
        if (payload['kind'] == 'ping') {
          await socket.sendText('pong:${socket.params['roomId']}');
          await socket.close(code: 1000, reason: 'done');
          return;
        }
      }
    });
    app.mount('/ws', chatRouter);

    final server = await app.listen(port: 0);
    addTearDown(server.close);

    final socket = await WebSocket.connect(
      server.baseUri.replace(scheme: 'ws', path: '/ws/chat/lobby').toString(),
    );
    addTearDown(socket.close);

    final events = <Object?>[];
    final eventsReady = Completer<void>();
    late final StreamSubscription<Object?> subscription;
    subscription = socket.listen((event) {
      events.add(event);
      if (events.length >= 2 && !eventsReady.isCompleted) {
        eventsReady.complete();
      }
    });
    addTearDown(subscription.cancel);

    socket.add(jsonEncode(<String, Object?>{'kind': 'ping'}));

    await eventsReady.future.timeout(const Duration(seconds: 10));
    await socket.done.timeout(const Duration(seconds: 10));

    expect(jsonDecode(events.first! as String), <String, Object?>{
      'kind': 'joined',
      'roomId': 'lobby',
    });
    expect(events[1], 'pong:lobby');
  });

  test('streams server-sent events through axum', () async {
    final app = AxumApp();

    app.sse('/events', (connection) async {
      await connection.comment('ready');
      await connection.sendJson(<String, Object?>{'tick': 1}, event: 'tick', id: '1');
      await connection.sendText('done', event: 'done');
    });

    final server = await app.listen(port: 0);
    addTearDown(server.close);

    final client = HttpClient();
    addTearDown(client.close);

    final request = await client.getUrl(server.baseUri.replace(path: '/events'));
    final response = await request.close();
    final body = await utf8.decodeStream(response);

    expect(response.statusCode, HttpStatus.ok);
    expect(response.headers.value('content-type'), startsWith('text/event-stream'));
    expect(body, contains(': ready'));
    expect(body, contains('id: 1'));
    expect(body, contains('event: tick'));
    expect(body, contains('data: {"tick":1}'));
    expect(body, contains('event: done'));
    expect(body, contains('data: done'));
  });

  test('parses multipart form-data uploads', () async {
    final app = AxumApp();

    app.post(
      '/uploads',
      handler: (context) {
        final form = context.multipartFormData();
        final owner = form.requireField('owner');
        final notes = form.field('notes');
        final file = form.files('file').first;
        return AxumResponse.json(<String, Object?>{
          'owner': owner,
          'notes': notes,
          'filename': file.filename,
          'contentType': file.contentType,
          'sizeBytes': file.bytes.length,
          'text': file.text(),
        });
      },
      docs: const AxumRouteDocs(
        requestBody: AxumRequestBodyDocs(
          contentType: 'multipart/form-data',
          schema: AxumSchema.object(
            properties: <String, AxumSchema>{
              'owner': AxumSchema.string(),
              'notes': AxumSchema.string(),
              'file': AxumSchema.string(format: 'binary'),
            },
            required: <String>{'owner', 'file'},
          ),
        ),
      ),
    );

    final server = await app.listen(port: 0);
    addTearDown(server.close);

    final client = HttpClient();
    addTearDown(client.close);

    final boundary = 'dart-axum-boundary';
    final request = await client.postUrl(server.baseUri.replace(path: '/uploads'));
    request.headers.set(HttpHeaders.contentTypeHeader, 'multipart/form-data; boundary=$boundary');
    request.add(
      _buildMultipartBody(
        boundary: boundary,
        owner: 'Ada',
        notes: 'Uploaded from test',
        filename: 'note.txt',
        contentType: 'text/plain',
        fileBytes: Uint8List.fromList(utf8.encode('hello multipart')),
      ),
    );
    final response = await request.close();
    final body = await utf8.decodeStream(response);

    expect(response.statusCode, HttpStatus.ok);
    expect(jsonDecode(body), <String, Object?>{
      'owner': 'Ada',
      'notes': 'Uploaded from test',
      'filename': 'note.txt',
      'contentType': 'text/plain',
      'sizeBytes': 15,
      'text': 'hello multipart',
    });
  });
}

final class _CreateUser {
  _CreateUser({required this.name});

  final String name;

  static _CreateUser fromJsonObject(Object? value) {
    final json = value as Map<String, Object?>;
    return _CreateUser(name: json['name']! as String);
  }

  Map<String, Object?> toJson() => <String, Object?>{'name': name};
}

final class _UserRecord {
  _UserRecord({required this.id, required this.name});

  final String id;
  final String name;

  static _UserRecord fromJsonObject(Object? value) {
    final json = value as Map<String, Object?>;
    return _UserRecord(id: json['id']! as String, name: json['name']! as String);
  }

  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'name': name};
}

Uint8List _buildMultipartBody({
  required String boundary,
  required String owner,
  required String notes,
  required String filename,
  required String contentType,
  required Uint8List fileBytes,
}) {
  final builder = BytesBuilder();

  void addText(String value) {
    builder.add(utf8.encode(value));
  }

  addText('--$boundary\r\n');
  addText('Content-Disposition: form-data; name="owner"\r\n\r\n');
  addText(owner);
  addText('\r\n');

  addText('--$boundary\r\n');
  addText('Content-Disposition: form-data; name="notes"\r\n\r\n');
  addText(notes);
  addText('\r\n');

  addText('--$boundary\r\n');
  addText('Content-Disposition: form-data; name="file"; filename="$filename"\r\n');
  addText('Content-Type: $contentType\r\n\r\n');
  builder.add(fileBytes);
  addText('\r\n');

  addText('--$boundary--\r\n');
  return builder.toBytes();
}
