import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_axum/dart_axum.dart';
import 'package:test/test.dart';

void main() {
  test('serves typed HTTP routes, middleware, and openapi docs', () async {
    final app = AxumApp(
      openApi: const AxumOpenApi(
        info: AxumOpenApiInfo(title: 'Integration API', version: '0.1.0'),
      ),
    );

    final createUserCodec = AxumJsonCodec<_CreateUser>(
      decodeJson: _CreateUser.fromJsonObject,
      encodeJson: (value) => value.toJson(),
      schema: const AxumSchema.object(
        properties: <String, AxumSchema>{'name': AxumSchema.string()},
        required: <String>{'name'},
      ),
    );
    final userCodec = AxumJsonCodec<_UserRecord>(
      decodeJson: _UserRecord.fromJsonObject,
      encodeJson: (value) => value.toJson(),
      schema: const AxumSchema.object(
        properties: <String, AxumSchema>{'id': AxumSchema.string(), 'name': AxumSchema.string()},
        required: <String>{'id', 'name'},
      ),
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

    app.postTyped<_CreateUser, _UserRecord>(
      '/users',
      request: createUserCodec,
      response: userCodec,
      handler: (context) => _UserRecord(id: 'user-1', name: context.body.name),
    );

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
  });

  test('bridges websocket traffic through axum', () async {
    final app = AxumApp();

    app.ws('/chat/:roomId', (socket) async {
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

    final server = await app.listen(port: 0);
    addTearDown(server.close);

    final socket = await WebSocket.connect(
      server.baseUri.replace(scheme: 'ws', path: '/chat/lobby').toString(),
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
