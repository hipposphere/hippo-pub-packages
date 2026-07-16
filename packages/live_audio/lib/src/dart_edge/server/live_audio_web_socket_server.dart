import 'dart:async';

import 'package:dart_edge_core/dart_edge_core.dart';

import '../../live_audio_service.dart';
import '../../live_audio_session.dart';
import '../../models/live_audio_socket_message.dart';
import '../../openai/openai_realtime_session.dart';

typedef LiveAudioDartEdgeServiceFactory<TServices> =
    FutureOr<LiveAudioService> Function(WebSocketContext<TServices> socket);

typedef LiveAudioDartEdgeEventEncoder = Object? Function(LiveAudioEvent event);

typedef LiveAudioDartEdgeEventFilter = bool Function(LiveAudioEvent event);

final class LiveAudioDartEdgeWebSocketOptions {
  const LiveAudioDartEdgeWebSocketOptions({
    this.sendAudioAsBinary = true,
    this.sendJsonAudio = false,
    this.sendRawEvents = false,
    this.events = const LiveAudioDartEdgeEventFilterConfig(),
    this.eventFilter,
    this.closeOnSessionError = true,
    this.closeOnProtocolError = true,
    this.closeCode = 1000,
    this.errorCloseCode = 1011,
  });

  final bool sendAudioAsBinary;
  final bool sendJsonAudio;
  final bool sendRawEvents;
  final LiveAudioDartEdgeEventFilterConfig events;
  final LiveAudioDartEdgeEventFilter? eventFilter;
  final bool closeOnSessionError;
  final bool closeOnProtocolError;
  final int closeCode;
  final int errorCloseCode;
}

final class LiveAudioDartEdgeEventFilterConfig {
  const LiveAudioDartEdgeEventFilterConfig({
    this.sessionStarted = true,
    this.outputChunk = true,
    this.transcript = true,
    this.textDelta = true,
    this.thinking = true,
    this.interrupted = true,
    this.turnComplete = true,
    this.toolCall = true,
    this.error = true,
    this.raw = true,
  });

  final bool sessionStarted;
  final bool outputChunk;
  final bool transcript;
  final bool textDelta;
  final bool thinking;
  final bool interrupted;
  final bool turnComplete;
  final bool toolCall;
  final bool error;
  final bool raw;

  bool allows(LiveAudioEvent event) {
    return switch (event) {
      LiveAudioSessionStarted() => sessionStarted,
      LiveAudioOutputChunk() => outputChunk,
      LiveAudioTranscript() => transcript,
      LiveAudioTextDelta() => textDelta,
      LiveAudioThinking() => thinking,
      LiveAudioInterrupted() => interrupted,
      LiveAudioTurnComplete() => turnComplete,
      LiveAudioToolCallEvent() => toolCall,
      LiveAudioError() => error,
      LiveAudioRawEvent() => raw,
    };
  }
}

final class LiveAudioDartEdgeWebSocketRoute<TServices> extends WebSocketRouteDefinition<TServices> {
  LiveAudioDartEdgeWebSocketRoute({
    required LiveAudioDartEdgeServiceFactory<TServices> service,
    WebSocketOptions options = const WebSocketOptions(),
    LiveAudioDartEdgeWebSocketOptions bridgeOptions = const LiveAudioDartEdgeWebSocketOptions(),
    LiveAudioDartEdgeEventEncoder? eventEncoder,
  }) : _service = service,
       _bridgeOptions = bridgeOptions,
       _eventEncoder =
           eventEncoder ??
           LiveAudioSocketEventCodec(includeRawEvents: bridgeOptions.sendRawEvents).encode,
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
    LiveAudioDartEdgeEventEncoder? eventEncoder,
    List<Guard<TServices>>? guards,
  }) {
    final resolvedEventEncoder =
        eventEncoder ??
        LiveAudioSocketEventCodec(includeRawEvents: bridgeOptions.sendRawEvents).encode;
    websocket(
      path,
      options: options,
      guards: guards,
      onConnect: (socket) => handleLiveAudioDartEdgeWebSocket(
        socket,
        service: service,
        options: bridgeOptions,
        eventEncoder: resolvedEventEncoder,
      ),
    );
  }
}

Future<void> handleLiveAudioDartEdgeWebSocket<TServices>(
  WebSocketContext<TServices> socket, {
  required LiveAudioDartEdgeServiceFactory<TServices> service,
  LiveAudioDartEdgeWebSocketOptions options = const LiveAudioDartEdgeWebSocketOptions(),
  LiveAudioDartEdgeEventEncoder? eventEncoder,
}) async {
  LiveAudioSession? session;
  StreamSubscription<LiveAudioEvent>? liveEvents;
  StreamSubscription<WebSocketMessage>? clientMessages;
  final done = Completer<void>();
  final resolvedEventEncoder =
      eventEncoder ?? LiveAudioSocketEventCodec(includeRawEvents: options.sendRawEvents).encode;

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
        unawaited(_sendLiveAudioEvent(socket, event, options, resolvedEventEncoder));
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

Future<void> _handleClientMessage<TServices>(
  WebSocketContext<TServices> socket,
  LiveAudioSession session,
  WebSocketMessage message,
  LiveAudioDartEdgeWebSocketOptions options,
) async {
  try {
    final socketMessage = message.kind == WebSocketMessageKind.binary
        ? LiveAudioSocketMessage.audioBytes(message.bytes)
        : LiveAudioSocketMessage.fromJsonText(message.text);

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
      case LiveAudioSocketMessageType.toolResult:
        final result = socketMessage.toolResult;
        if (result != null) {
          await session.sendToolResult(result);
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
  if (!_shouldSendLiveAudioEvent(event, options)) {
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

bool _shouldSendLiveAudioEvent(LiveAudioEvent event, LiveAudioDartEdgeWebSocketOptions options) {
  if (event is LiveAudioRawEvent && !options.sendRawEvents) {
    return false;
  }

  if (!options.events.allows(event)) {
    return false;
  }

  final eventFilter = options.eventFilter;
  if (eventFilter != null && !eventFilter(event)) {
    return false;
  }

  return true;
}
