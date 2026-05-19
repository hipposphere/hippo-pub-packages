import 'dart:async';
import 'dart:typed_data';

import 'package:googleai_dart/googleai_dart.dart' as genai;

import '../live_audio_service.dart';
import '../live_audio_session.dart';
import '../models/live_audio_tool.dart';
import '../utils/audio.dart';
import 'gemini_live_audio_config.dart';

final class GeminiLiveAudioService implements LiveAudioService {
  const GeminiLiveAudioService(this.config);

  final GeminiLiveAudioConfig config;

  @override
  Future<GeminiLiveAudioSession> connect() => GeminiLiveAudioSession.connect(config);
}

final class GeminiLiveAudioSession implements LiveAudioSession {
  GeminiLiveAudioSession._({
    required genai.GoogleAIClient client,
    required genai.LiveClient liveClient,
    required genai.LiveSession session,
  }) : _client = client,
       _liveClient = liveClient,
       _session = session {
    _subscription = _session.messages.listen(
      _handleMessage,
      onError: (Object error, StackTrace stackTrace) {
        _events.add(LiveAudioError(provider: provider, message: error.toString(), rawEvent: error));
      },
      onDone: _events.close,
    );
  }

  final genai.GoogleAIClient _client;
  final genai.LiveClient _liveClient;
  final genai.LiveSession _session;
  final _events = StreamController<LiveAudioEvent>.broadcast();
  late final StreamSubscription<genai.BidiGenerateContentServerMessage> _subscription;
  var _audioEnded = false;
  var _closed = false;

  Stream<genai.BidiGenerateContentServerMessage> get messages => _session.messages;

  @override
  LiveAudioProvider get provider => LiveAudioProvider.gemini;

  @override
  Stream<LiveAudioEvent> get events => _events.stream;

  static Future<GeminiLiveAudioSession> connect(GeminiLiveAudioConfig config) async {
    final client = genai.GoogleAIClient(
      config: genai.GoogleAIConfig.googleAI(
        apiVersion: genai.ApiVersion.v1beta,
        authProvider: genai.ApiKeyProvider(config.apiKey),
        timeout: const Duration(seconds: 45),
      ),
    );
    final liveClient = client.createLiveClient();

    try {
      final session = await liveClient.connect(
        model: config.model,
        liveConfig: _liveConfig(config),
      );
      return GeminiLiveAudioSession._(client: client, liveClient: liveClient, session: session);
    } catch (error) {
      await liveClient.close();
      client.close();
      throw StateError('Gemini Live audio connection failed: $error');
    }
  }

  @override
  Future<void> sendText(String text) async {
    if (_closed || !_session.isConnected || text.trim().isEmpty) {
      return;
    }
    _session.sendText(text.trim());
  }

  @override
  Future<void> sendAudio(Uint8List bytes) async {
    if (_closed || !_session.isConnected || bytes.isEmpty) {
      return;
    }
    _session.sendAudio(bytes);
  }

  @override
  Future<void> commitAudio() => endAudioInput();

  @override
  Future<void> clearAudio() async {}

  @override
  Future<void> endAudioInput() async {
    if (_closed || !_session.isConnected || _audioEnded) {
      return;
    }
    _audioEnded = true;
    _session.signalAudioStreamEnd();
  }

  Future<void> signalActivityStart() async {
    if (_closed || !_session.isConnected) {
      return;
    }
    _session.signalActivityStart();
  }

  Future<void> signalActivityEnd() async {
    if (_closed || !_session.isConnected) {
      return;
    }
    _session.signalActivityEnd();
  }

  @override
  Future<void> sendToolResponse(LiveAudioToolResponse response) async {
    if (_closed || !_session.isConnected) {
      return;
    }
    _session.sendToolResponse([
      genai.FunctionResponse(id: response.id, name: response.name, response: response.responseJson),
    ]);
  }

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    await _subscription.cancel();
    await _events.close();
    await _session.close();
    await _liveClient.close();
    _client.close();
  }

  void _handleMessage(genai.BidiGenerateContentServerMessage message) {
    _events.add(LiveAudioRawEvent(provider: provider, rawEvent: message));

    switch (message) {
      case genai.BidiGenerateContentSetupComplete(:final sessionId):
        _events.add(
          LiveAudioSessionStarted(provider: provider, sessionId: sessionId, rawEvent: message),
        );
      case genai.BidiGenerateContentServerContent(
        :final modelTurn,
        :final turnComplete,
        :final interrupted,
        :final inputTranscription,
        :final outputTranscription,
      ):
        if (interrupted == true) {
          _events.add(LiveAudioInterrupted(provider: provider, rawEvent: message));
        }

        final inputText = inputTranscription?.text;
        if (inputText != null && inputText.isNotEmpty) {
          _events.add(
            LiveAudioTranscript(
              provider: provider,
              kind: LiveAudioTranscriptKind.input,
              text: inputText,
              rawEvent: message,
            ),
          );
        }

        final outputText = outputTranscription?.text;
        if (outputText != null && outputText.isNotEmpty) {
          _events.add(
            LiveAudioTranscript(
              provider: provider,
              kind: LiveAudioTranscriptKind.output,
              text: outputText,
              rawEvent: message,
            ),
          );
        }

        for (final part in modelTurn?.parts ?? const <genai.Part>[]) {
          switch (part) {
            case genai.TextPart(thought: true, :final text):
              _events.add(
                LiveAudioThinking(
                  provider: provider,
                  text: text.isEmpty ? null : text,
                  rawEvent: message,
                ),
              );
            case genai.TextPart(:final text):
              if (text.isNotEmpty) {
                _events.add(LiveAudioTextDelta(provider: provider, text: text, rawEvent: message));
              }
            case genai.InlineDataPart(:final inlineData)
                when inlineData.mimeType.startsWith('audio/'):
              _events.add(
                LiveAudioOutputChunk(
                  provider: provider,
                  bytes: Uint8List.fromList(inlineData.toBytes()),
                  format: LiveAudioInputFormat(
                    sampleRate: audioRateFromMimeType(inlineData.mimeType) ?? 24000,
                  ),
                  rawEvent: message,
                ),
              );
            case _:
              break;
          }
        }

        if (turnComplete ?? false) {
          _events.add(LiveAudioTurnComplete(provider: provider, rawEvent: message));
        }
      case genai.BidiGenerateContentToolCall(:final functionCalls):
        for (final call in functionCalls) {
          _events.add(
            LiveAudioToolCall(
              provider: provider,
              name: call.name,
              arguments: call.args ?? const <String, dynamic>{},
              id: call.id,
              rawEvent: message,
            ),
          );
        }
      case _:
        break;
    }
  }
}

genai.LiveConfig _liveConfig(GeminiLiveAudioConfig config) {
  return genai.LiveConfig(
    generationConfig: genai.LiveGenerationConfig.audioOnly(
      speechConfig: config.voiceName == null
          ? null
          : genai.SpeechConfig.withVoice(config.voiceName!),
    ),
    systemInstruction: config.systemInstruction == null
        ? null
        : genai.Content(parts: [genai.TextPart(config.systemInstruction!)]),
    tools: config.tools.isEmpty
        ? null
        : [
            genai.Tool(
              functionDeclarations: config.tools
                  .map(
                    (tool) => genai.FunctionDeclaration(
                      name: tool.name,
                      description: tool.description ?? '',
                      parameters: genai.Schema.fromJson(tool.parametersJson),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
    inputAudioTranscription: config.enableInputTranscription
        ? genai.AudioTranscriptionConfig.enabled()
        : null,
    outputAudioTranscription: config.enableOutputTranscription
        ? genai.AudioTranscriptionConfig.enabled()
        : null,
    realtimeInputConfig: _realtimeInputConfig(config.vad),
  );
}

genai.RealtimeInputConfig? _realtimeInputConfig(GeminiLiveAudioVadConfig? vad) {
  if (vad == null) {
    return null;
  }

  return genai.RealtimeInputConfig(
    automaticActivityDetection: vad.manual
        ? genai.AutomaticActivityDetection.manual()
        : genai.AutomaticActivityDetection.enabled(
            startSensitivity: _startSensitivity(vad.startSensitivity),
            endSensitivity: _endSensitivity(vad.endSensitivity),
            prefixPaddingMs: vad.prefixPaddingMs,
            silenceDurationMs: vad.silenceDurationMs,
          ),
    activityHandling: _activityHandling(vad.activityHandling),
    turnCoverage: _turnCoverage(vad.turnCoverage),
  );
}

genai.ActivityHandling _activityHandling(GeminiLiveAudioActivityHandling handling) =>
    switch (handling) {
      GeminiLiveAudioActivityHandling.startOfActivityInterrupts =>
        genai.ActivityHandling.startOfActivityInterrupts,
      GeminiLiveAudioActivityHandling.noInterruption => genai.ActivityHandling.noInterruption,
    };

genai.TurnCoverage? _turnCoverage(GeminiLiveAudioTurnCoverage? coverage) => switch (coverage) {
  null => null,
  GeminiLiveAudioTurnCoverage.onlyActivity => genai.TurnCoverage.turnIncludesOnlyActivity,
  GeminiLiveAudioTurnCoverage.allInput => genai.TurnCoverage.turnIncludesAllInput,
};

genai.StartSensitivity? _startSensitivity(GeminiLiveAudioVadSensitivity? sensitivity) =>
    switch (sensitivity) {
      null => null,
      GeminiLiveAudioVadSensitivity.high => genai.StartSensitivity.high,
      GeminiLiveAudioVadSensitivity.low => genai.StartSensitivity.low,
    };

genai.EndSensitivity? _endSensitivity(GeminiLiveAudioVadSensitivity? sensitivity) =>
    switch (sensitivity) {
      null => null,
      GeminiLiveAudioVadSensitivity.high => genai.EndSensitivity.high,
      GeminiLiveAudioVadSensitivity.low => genai.EndSensitivity.low,
    };
