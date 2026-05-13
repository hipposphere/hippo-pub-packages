import 'dart:async';
import 'dart:convert';

import 'package:dart_edge_core/dart_edge_core.dart';

import '../live_audio_service.dart';
import '../live_audio_session.dart';
import '../models/live_audio_socket_message.dart';
import '../openai/openai_realtime_session.dart';

typedef LiveAudioDartEdgeServiceFactory<TServices> =
    FutureOr<LiveAudioService> Function(WebSocketContext<TServices> socket);

typedef LiveAudioDartEdgeEventEncoder = Object? Function(LiveAudioEvent event);

final class LiveAudioDartEdgeWebSocketOptions {
  const LiveAudioDartEdgeWebSocketOptions({
    this.sendAudioAsBinary = true,
    this.sendJsonAudio = false,
    this.sendRawEvents = false,
    this.closeOnSessionError = true,
    this.closeOnProtocolError = true,
    this.closeCode = 1000,
    this.errorCloseCode = 1011,
  });

  final bool sendAudioAsBinary;
  final bool sendJsonAudio;
  final bool sendRawEvents;
  final bool closeOnSessionError;
  final bool closeOnProtocolError;
  final int closeCode;
  final int errorCloseCode;
}

final class LiveAudioDartEdgeWebSocketRoute<TServices> extends WebSocketRouteDefinition<TServices> {
  LiveAudioDartEdgeWebSocketRoute({
    required LiveAudioDartEdgeServiceFactory<TServices> service,
    WebSocketOptions options = const WebSocketOptions(),
    LiveAudioDartEdgeWebSocketOptions bridgeOptions = const LiveAudioDartEdgeWebSocketOptions(),
    LiveAudioDartEdgeEventEncoder eventEncoder = encodeLiveAudioSocketEvent,
  }) : _service = service,
       _bridgeOptions = bridgeOptions,
       _eventEncoder = eventEncoder,
       _options = options.normalized(defaultOperationId: operationIdDefault);

  static const operationIdDefault = 'liveAudio';

  final LiveAudioDartEdgeServiceFactory<TServices> _service;
  final LiveAudioDartEdgeWebSocketOptions _bridgeOptions;
  final LiveAudioDartEdgeEventEncoder _eventEncoder;
  final WebSocketOptions _options;

  @override
  WebSocketOptions get options => _options;

  @override
  Future<void> onConnect(WebSocketContext<TServices> socket) {
    return handleLiveAudioDartEdgeWebSocket(
      socket,
      service: _service,
      options: _bridgeOptions,
      eventEncoder: _eventEncoder,
    );
  }
}

extension LiveAudioDartEdgeRouterExtension<TServices> on Router<TServices> {
  void liveAudioWebSocket(
    String path, {
    required LiveAudioDartEdgeServiceFactory<TServices> service,
    WebSocketOptions options = const WebSocketOptions(),
    LiveAudioDartEdgeWebSocketOptions bridgeOptions = const LiveAudioDartEdgeWebSocketOptions(),
    LiveAudioDartEdgeEventEncoder eventEncoder = encodeLiveAudioSocketEvent,
    List<Guard<TServices>>? guards,
  }) {
    websocket(
      path,
      options: options,
      guards: guards,
      onConnect: (socket) => handleLiveAudioDartEdgeWebSocket(
        socket,
        service: service,
        options: bridgeOptions,
        eventEncoder: eventEncoder,
      ),
    );
  }
}

Future<void> handleLiveAudioDartEdgeWebSocket<TServices>(
  WebSocketContext<TServices> socket, {
  required LiveAudioDartEdgeServiceFactory<TServices> service,
  LiveAudioDartEdgeWebSocketOptions options = const LiveAudioDartEdgeWebSocketOptions(),
  LiveAudioDartEdgeEventEncoder eventEncoder = encodeLiveAudioSocketEvent,
}) async {
  LiveAudioSession? session;
  StreamSubscription<LiveAudioEvent>? liveEvents;
  StreamSubscription<WebSocketMessage>? clientMessages;
  final done = Completer<void>();

  Future<void> complete([Object? error, StackTrace? stackTrace]) async {
    if (!done.isCompleted) {
      if (error == null) {
        done.complete();
      } else {
        done.completeError(error, stackTrace);
      }
    }
  }

  try {
    session = await (await Future.value(service(socket))).connect();

    liveEvents = session.events.listen(
      (event) {
        unawaited(_sendLiveAudioEvent(socket, event, options, eventEncoder));
      },
      onError: (Object error, StackTrace stackTrace) {
        unawaited(socket.sendJson({'type': 'error', 'message': error.toString()}));
        if (options.closeOnSessionError) {
          unawaited(socket.close(options.errorCloseCode, 'Live audio error'));
        }
      },
      onDone: complete,
    );

    clientMessages = socket.messages.frames().listen(
      (message) {
        final activeSession = session;
        if (activeSession == null) {
          return;
        }
        unawaited(_handleClientMessage(socket, activeSession, message, options));
      },
      onError: complete,
      onDone: complete,
    );

    await done.future;
  } finally {
    await clientMessages?.cancel();
    await liveEvents?.cancel();
    await session?.close();
  }
}

Object? encodeLiveAudioSocketEvent(LiveAudioEvent event) {
  return switch (event) {
    LiveAudioSessionStarted(:final sessionId) => {
      'type': 'session_started',
      'session_id': ?sessionId,
      'provider': event.provider.name,
    },
    LiveAudioOutputChunk(:final bytes, :final format, :final responseId) => {
      'type': 'audio',
      'audio': base64Encode(bytes),
      'format': ?(format == null ? null : _formatToJson(format)),
      'response_id': ?responseId,
      'provider': event.provider.name,
    },
    LiveAudioTranscript(
      :final kind,
      :final text,
      :final isDelta,
      :final itemId,
      :final responseId,
    ) =>
      {
        'type': 'transcript',
        'kind': kind.name,
        'text': text,
        'is_delta': isDelta,
        'item_id': ?itemId,
        'response_id': ?responseId,
        'provider': event.provider.name,
      },
    LiveAudioTextDelta(:final text, :final responseId) => {
      'type': 'text_delta',
      'text': text,
      'response_id': ?responseId,
      'provider': event.provider.name,
    },
    LiveAudioTurnComplete() => {'type': 'turn_complete', 'provider': event.provider.name},
    LiveAudioToolCall(:final name, :final arguments, :final id) => {
      'type': 'tool_call',
      'name': name,
      'arguments': arguments,
      'id': ?id,
      'provider': event.provider.name,
    },
    LiveAudioError(:final message, :final code) => {
      'type': 'error',
      'message': message,
      'code': ?code,
      'provider': event.provider.name,
    },
    LiveAudioRawEvent(:final rawEvent) => {
      'type': 'raw',
      'event': rawEvent.toString(),
      'provider': event.provider.name,
    },
  };
}

Future<void> _handleClientMessage<TServices>(
  WebSocketContext<TServices> socket,
  LiveAudioSession session,
  WebSocketMessage message,
  LiveAudioDartEdgeWebSocketOptions options,
) async {
  try {
    final socketMessage = message.kind == WebSocketMessageKind.binary
        ? LiveAudioSocketMessage.audioBytes(message.bytes)
        : LiveAudioSocketMessage.fromJson(jsonDecode(message.text));

    switch (socketMessage.type) {
      case LiveAudioSocketMessageType.audio:
        final audio = socketMessage.audio;
        if (audio != null && audio.isNotEmpty) {
          await session.sendAudio(audio);
        }
      case LiveAudioSocketMessageType.text:
        final text = socketMessage.text;
        if (text != null && text.trim().isNotEmpty) {
          await session.sendText(text);
        }
      case LiveAudioSocketMessageType.commitAudio:
        await session.commitAudio();
      case LiveAudioSocketMessageType.clearAudio:
        await session.clearAudio();
      case LiveAudioSocketMessageType.endAudioInput:
        await session.endAudioInput();
      case LiveAudioSocketMessageType.cancelResponse:
        if (session is OpenAIRealtimeSession) {
          await session.cancelResponse();
        }
      case LiveAudioSocketMessageType.close:
        await session.close();
        await socket.close(options.closeCode, socketMessage.reason);
    }
  } on Object catch (error) {
    await socket.sendJson({'type': 'error', 'message': error.toString()});
    if (options.closeOnProtocolError) {
      await socket.close(options.errorCloseCode, 'Invalid live audio message');
    }
  }
}

Future<void> _sendLiveAudioEvent<TServices>(
  WebSocketContext<TServices> socket,
  LiveAudioEvent event,
  LiveAudioDartEdgeWebSocketOptions options,
  LiveAudioDartEdgeEventEncoder eventEncoder,
) async {
  if (event is LiveAudioRawEvent && !options.sendRawEvents) {
    return;
  }

  if (event case LiveAudioOutputChunk(:final bytes) when options.sendAudioAsBinary) {
    await socket.sendBinary(bytes);
    if (!options.sendJsonAudio) {
      return;
    }
  }

  final encoded = eventEncoder(event);
  if (encoded != null) {
    await socket.sendJson(encoded);
  }
}

Object _formatToJson(LiveAudioInputFormat format) {
  return {
    'type': format.format.mimeType,
    'sample_rate': format.sampleRate,
    'channels': format.channels,
  };
}
