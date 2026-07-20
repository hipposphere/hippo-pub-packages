import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart' as openai;
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;
import 'package:agent_core/agent_core.dart';

import '../live_audio_service.dart';
import '../live_audio_session.dart';
import '../models/live_audio_tool_mapping.dart';
import 'openai_realtime_config.dart';
import 'openai_realtime_session_update.dart';

final class OpenAIRealtimeService implements LiveAudioService {
  const OpenAIRealtimeService(this.config);

  final OpenAIRealtimeConfig config;

  @override
  Future<OpenAIRealtimeSession> connect() => OpenAIRealtimeSession.connect(config);
}

final class OpenAIRealtimeSession implements LiveAudioSession {
  OpenAIRealtimeSession._({
    required OpenAIRealtimeConfig config,
    required openai.OpenAIClient client,
    required openai.RealtimeConnection connection,
  }) : _config = config,
       _client = client,
       _connection = connection {
    _subscription = _connection.events.listen(
      _handleRealtimeEvent,
      onError: (Object error, StackTrace stackTrace) {
        _events.add(LiveAudioError(provider: provider, message: error.toString(), rawEvent: error));
      },
      onDone: _events.close,
    );
  }

  final OpenAIRealtimeConfig _config;
  final openai.OpenAIClient _client;
  final openai.RealtimeConnection _connection;
  final _events = StreamController<LiveAudioEvent>.broadcast();
  late final StreamSubscription<realtime.RealtimeEvent> _subscription;
  var _responseActive = false;
  String? _currentResponseId;
  var _closed = false;

  @override
  LiveAudioProvider get provider => LiveAudioProvider.openaiRealtime;

  @override
  Stream<LiveAudioEvent> get events => _events.stream;

  static Future<OpenAIRealtimeSession> connect(OpenAIRealtimeConfig config) async {
    final client = openai.OpenAIClient.withApiKey(
      config.apiKey,
      baseUrl: _httpBaseUrl(config.baseUrl),
    );
    final connection = await client.realtime.connect(model: config.model);
    final session = OpenAIRealtimeSession._(config: config, client: client, connection: connection);
    session._connection.send(createOpenAIRealtimeSessionUpdate(config));
    return session;
  }

  @override
  Future<void> sendText(String text) async {
    if (_closed || text.trim().isEmpty) {
      return;
    }
    _connection.createItem({
      'type': 'message',
      'role': 'user',
      'content': [
        {'type': 'input_text', 'text': text.trim()},
      ],
    });
    _connection.createResponse(outputModalities: const ['audio']);
  }

  @override
  Future<void> sendAudio(Uint8List bytes) async {
    if (_closed || bytes.isEmpty) {
      return;
    }
    _connection.appendAudio(base64Encode(bytes));
  }

  @override
  Future<void> commitAudio() async {
    if (_closed) {
      return;
    }
    _connection.commitAudio();
    if (!_config.enableServerVad || !_config.createResponseFromVad) {
      _connection.createResponse(outputModalities: const ['audio']);
    }
  }

  @override
  Future<void> clearAudio() async {
    if (_closed) {
      return;
    }
    _connection.clearAudio();
  }

  @override
  Future<void> endAudioInput() => commitAudio();

  Future<void> cancelResponse() async {
    if (_closed) {
      return;
    }
    _connection.cancelResponse();
  }

  @override
  Future<void> sendToolResult(AgentToolResult<Object?> result) async {
    if (_closed) {
      return;
    }
    final callId = result.callId;
    if (callId.isEmpty) {
      throw ArgumentError.value(
        result.callId,
        'result.callId',
        'OpenAI Realtime tool results require a call id.',
      );
    }
    _connection.sendFunctionOutput(callId, jsonEncode(liveAudioToolResultValue(result)));
    _connection.createResponse(outputModalities: const ['audio']);
  }

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    await _subscription.cancel();
    await _events.close();
    await _connection.close();
    _client.close();
  }

  void _handleRealtimeEvent(realtime.RealtimeEvent event) {
    _events.add(LiveAudioRawEvent(provider: provider, rawEvent: event));

    switch (event) {
      case realtime.SessionCreatedEvent(:final session):
      case realtime.SessionUpdatedEvent(:final session):
        _events.add(
          LiveAudioSessionStarted(provider: provider, sessionId: session.id, rawEvent: event),
        );
      case realtime.ResponseAudioDeltaEvent(:final delta, :final responseId):
        if (delta.isNotEmpty) {
          _events.add(
            LiveAudioOutputChunk(
              provider: provider,
              bytes: base64Decode(delta),
              format: _config.outputFormat,
              responseId: responseId,
              turnId: responseId,
              rawEvent: event,
            ),
          );
        }
      case realtime.InputAudioTranscriptionDeltaEvent(:final delta, :final itemId):
        _emitTranscript(
          text: delta,
          itemId: itemId,
          kind: LiveAudioTranscriptKind.input,
          isDelta: true,
          rawEvent: event,
        );
      case realtime.InputAudioTranscriptionCompletedEvent(:final transcript, :final itemId):
        _emitTranscript(
          text: transcript,
          itemId: itemId,
          kind: LiveAudioTranscriptKind.input,
          rawEvent: event,
        );
      case realtime.ResponseAudioTranscriptDeltaEvent(
        :final delta,
        :final itemId,
        :final responseId,
      ):
        _emitTranscript(
          text: delta,
          itemId: itemId,
          responseId: responseId,
          turnId: responseId,
          kind: LiveAudioTranscriptKind.output,
          isDelta: true,
          rawEvent: event,
        );
      case realtime.ResponseAudioTranscriptDoneEvent(
        :final transcript,
        :final itemId,
        :final responseId,
      ):
        _emitTranscript(
          text: transcript,
          itemId: itemId,
          responseId: responseId,
          turnId: responseId,
          kind: LiveAudioTranscriptKind.output,
          rawEvent: event,
        );
      case realtime.ResponseTextDeltaEvent(:final delta, :final responseId):
        if (delta.isNotEmpty) {
          _events.add(
            LiveAudioTextDelta(
              provider: provider,
              text: delta,
              responseId: responseId,
              turnId: responseId,
              rawEvent: event,
            ),
          );
        }
      case realtime.InputAudioBufferSpeechStartedEvent():
        if (_responseActive) {
          _events.add(
            LiveAudioInterrupted(provider: provider, turnId: _currentResponseId, rawEvent: event),
          );
        }
      case realtime.ConversationItemTruncatedEvent():
        _events.add(
          LiveAudioInterrupted(provider: provider, turnId: _currentResponseId, rawEvent: event),
        );
      case realtime.ResponseCreatedEvent(:final response):
        _responseActive = true;
        if (response['id'] case final String responseId when responseId.isNotEmpty) {
          _currentResponseId = responseId;
        }
      case realtime.ResponseOutputItemDoneEvent(:final item):
        _emitToolCallFromItem(item, event);
      case realtime.ResponseDoneEvent(:final response):
        final turnId = switch (response['id']) {
          final String responseId when responseId.isNotEmpty => responseId,
          _ => _currentResponseId,
        };
        _responseActive = false;
        _currentResponseId = null;
        _events.add(LiveAudioTurnComplete(provider: provider, turnId: turnId, rawEvent: event));
      case realtime.ErrorEvent(:final error):
        _events.add(
          LiveAudioError(
            provider: provider,
            message: error.message,
            code: error.code,
            rawEvent: event,
          ),
        );
      case _:
        break;
    }
  }

  void _emitTranscript({
    required String text,
    required LiveAudioTranscriptKind kind,
    required Object rawEvent,
    bool isDelta = false,
    String? itemId,
    String? responseId,
    String? turnId,
  }) {
    if (text.isEmpty) {
      return;
    }
    _events.add(
      LiveAudioTranscript(
        provider: provider,
        kind: kind,
        text: text,
        isDelta: isDelta,
        itemId: itemId,
        responseId: responseId,
        turnId: turnId,
        rawEvent: rawEvent,
      ),
    );
  }

  void _emitToolCallFromItem(Map<String, dynamic> item, Object rawEvent) {
    if (item['type'] != 'function_call') {
      return;
    }

    final name = item['name'];
    if (name is! String || name.isEmpty) {
      return;
    }

    final arguments = item['arguments'];
    _events.add(
      LiveAudioToolCallEvent(
        provider: provider,
        call: liveAudioToolCall(
          id: item['call_id'] as String? ?? item['id'] as String? ?? '',
          name: name,
          arguments: arguments,
          metadata: const <String, Object?>{'provider': 'openai_realtime'},
        ),
        rawEvent: rawEvent,
      ),
    );
  }
}

String _httpBaseUrl(String baseUrl) {
  final uri = Uri.parse(baseUrl);
  var normalizedUri = uri;
  if (normalizedUri.path.endsWith('/realtime')) {
    normalizedUri = normalizedUri.replace(
      path: normalizedUri.path.substring(0, normalizedUri.path.length - '/realtime'.length),
    );
  }
  if (normalizedUri.scheme == 'wss' || normalizedUri.scheme == 'ws') {
    return normalizedUri
        .replace(scheme: normalizedUri.scheme == 'wss' ? 'https' : 'http')
        .toString();
  }
  return normalizedUri.toString();
}
