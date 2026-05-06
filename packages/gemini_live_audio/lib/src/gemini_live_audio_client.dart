import 'dart:typed_data';

import 'package:googleai_dart/googleai_dart.dart' as genai;

import 'gemini_live_audio_config.dart';

final class GeminiLiveAudioClient {
  GeminiLiveAudioClient._({
    required genai.GoogleAIClient client,
    required genai.LiveClient liveClient,
    required genai.LiveSession session,
  }) : _client = client,
       _liveClient = liveClient,
       _session = session;

  final genai.GoogleAIClient _client;
  final genai.LiveClient _liveClient;
  final genai.LiveSession _session;
  var _audioEnded = false;
  var _closed = false;

  Stream<genai.BidiGenerateContentServerMessage> get messages =>
      _session.messages;

  static Future<GeminiLiveAudioClient> connect(
    GeminiLiveAudioConfig config,
  ) async {
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
      return GeminiLiveAudioClient._(
        client: client,
        liveClient: liveClient,
        session: session,
      );
    } catch (error) {
      await liveClient.close();
      client.close();
      throw StateError('Gemini Live audio connection failed: $error');
    }
  }

  Future<void> sendText(String text) async {
    if (_closed || !_session.isConnected || text.trim().isEmpty) {
      return;
    }
    _session.sendText(text.trim());
  }

  Future<void> sendAudio(Uint8List bytes) async {
    if (_closed || !_session.isConnected || bytes.isEmpty) {
      return;
    }
    _session.sendAudio(bytes);
  }

  Future<void> endAudioInput() async {
    if (_closed || !_session.isConnected || _audioEnded) {
      return;
    }
    _audioEnded = true;
    _session.signalAudioStreamEnd();
  }

  Future<void> sendToolResponse(genai.FunctionResponse response) async {
    if (_closed || !_session.isConnected) {
      return;
    }
    _session.sendToolResponse([response]);
  }

  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    await _session.close();
    await _liveClient.close();
    _client.close();
  }
}

genai.LiveConfig _liveConfig(GeminiLiveAudioConfig config) {
  return genai.LiveConfig(
    generationConfig: genai.LiveGenerationConfig.audioOnly(
      speechConfig: genai.SpeechConfig.withVoice(config.voiceName),
    ),
    systemInstruction: genai.Content(
      parts: [genai.TextPart(config.systemInstruction)],
    ),
    tools: const [
      genai.Tool(
        functionDeclarations: [
          genai.FunctionDeclaration(
            name: 'end_call',
            description:
                'End the current phone call after the caller has said goodbye, '
                'the conversation is complete, or the caller explicitly asks '
                'to hang up.',
            parameters: genai.Schema(
              type: genai.SchemaType.object,
              properties: {
                'reason': genai.Schema(
                  type: genai.SchemaType.string,
                  description: 'Short reason for ending the call.',
                ),
              },
            ),
          ),
        ],
      ),
    ],
    realtimeInputConfig: genai.RealtimeInputConfig.withVAD(
      activityHandling: genai.ActivityHandling.startOfActivityInterrupts,
    ),
  );
}
