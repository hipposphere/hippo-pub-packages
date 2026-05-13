import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart' as openai;
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;

import '../live_audio_service.dart';
import '../live_audio_session.dart';
import 'openai_realtime_config.dart';

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
    session._connection.send(_sessionUpdate(config));
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
    _connection.createResponse(modalities: const ['audio']);
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
      _connection.createResponse(modalities: const ['audio']);
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

  Future<void> sendToolResponse({
    required String callId,
    required Map<String, dynamic> output,
  }) async {
    if (_closed) {
      return;
    }
    _connection.sendFunctionOutput(callId, jsonEncode(output));
    _connection.createResponse(modalities: const ['audio']);
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
              rawEvent: event,
            ),
          );
        }
      case realtime.ResponseOutputItemDoneEvent(:final item):
        _emitToolCallFromItem(item, event);
      case realtime.ResponseDoneEvent():
        _events.add(LiveAudioTurnComplete(provider: provider, rawEvent: event));
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
      LiveAudioToolCall(
        provider: provider,
        name: name,
        id: item['call_id'] as String? ?? item['id'] as String?,
        arguments: arguments is String && arguments.isNotEmpty
            ? jsonDecode(arguments) as Map<String, dynamic>
            : const <String, dynamic>{},
        rawEvent: rawEvent,
      ),
    );
  }
}

Map<String, dynamic> _sessionUpdate(OpenAIRealtimeConfig config) {
  final session = <String, dynamic>{
    'type': 'realtime',
    'model': config.model,
    if (config.instructions != null) 'instructions': config.instructions,
    'output_modalities': ['audio'],
    'audio': {
      'input': {
        'format': _format(config.inputFormat),
        if (config.enableInputTranscription)
          'transcription': {
            if (config.transcriptionPrompt != null) 'prompt': config.transcriptionPrompt,
            if (config.transcriptionLanguage != null) 'language': config.transcriptionLanguage,
          },
        'turn_detection': config.enableServerVad
            ? {
                'type': 'server_vad',
                'create_response': config.createResponseFromVad,
                'interrupt_response': true,
              }
            : null,
      },
      'output': {
        'format': _format(config.outputFormat),
        if (config.voice != null) 'voice': config.voice,
      },
    },
    if (config.tools.isNotEmpty)
      'tools': config.tools.map((tool) => tool.toOpenAIJson()).toList(growable: false),
    if (config.temperature != null) 'temperature': config.temperature,
    ...?config.extraSession,
  };

  return {'type': 'session.update', 'session': session};
}

Map<String, dynamic> _format(LiveAudioInputFormat format) {
  return {
    'type': format.format.mimeType,
    if (format.format == LiveAudioFormat.pcm16) 'rate': format.sampleRate,
  };
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
