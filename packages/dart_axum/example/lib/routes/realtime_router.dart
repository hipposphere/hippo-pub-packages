import 'dart:async';
import 'dart:convert';

import 'package:dart_axum/dart_axum.dart';

AxumRouter buildRealtimeRouter() {
  return AxumRouter(
    build: (router) {
      router.sse(
        '/events/ticks',
        (connection) async {
          await connection.comment('connected to dart_axum SSE example');
          var tick = 0;
          while (!connection.isClosed) {
            tick++;
            await connection.sendJson(
              <String, Object?>{
                'tick': tick,
                'timestamp': DateTime.now().toUtc().toIso8601String(),
              },
              event: tick.isEven ? 'heartbeat' : 'tick',
              id: '$tick',
            );
            await Future<void>.delayed(const Duration(seconds: 1));
          }
        },
        docs: const AxumRouteDocs(
          summary: 'Example server-sent event stream',
          description: 'Streams JSON tick payloads over text/event-stream.',
          tags: <String>['realtime'],
          responses: <int, AxumResponseDocs>{
            200: AxumResponseDocs(
              description: 'Long-lived SSE stream.',
              schema: AxumSchema.string(description: 'Server-sent event stream.'),
              contentType: 'text/event-stream; charset=utf-8',
            ),
          },
        ),
      );

      router.ws('/chat/:roomId', (socket) async {
        await socket.sendJson(<String, Object?>{
          'kind': 'joined',
          'roomId': socket.params['roomId'],
        });

        await for (final message in socket.messages) {
          if (message is! AxumWebSocketTextMessage) {
            continue;
          }
          final payload = jsonDecode(message.text) as Map<String, Object?>;
          await socket.sendJson(<String, Object?>{
            'kind': 'echo',
            'roomId': socket.params['roomId'],
            'payload': payload,
          });
        }
      });
    },
  );
}
