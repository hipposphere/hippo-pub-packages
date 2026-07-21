import 'package:live_audio/src/openai/openai_realtime_config.dart';
import 'package:live_audio/src/openai/openai_realtime_session_update.dart';
import 'package:test/test.dart';

void main() {
  test('uses audio output by default', () {
    final session = _session(const OpenAIRealtimeConfig(apiKey: 'test', model: 'gpt-realtime'));

    expect(session['output_modalities'], ['audio']);
  });

  test('supports text-only output', () {
    final session = _session(
      const OpenAIRealtimeConfig(
        apiKey: 'test',
        model: 'gpt-realtime',
        outputModality: OpenAIRealtimeOutputModality.text,
      ),
    );

    expect(session['output_modalities'], ['text']);
  });

  test('includes the default model when input transcription is enabled', () {
    final transcription = _inputTranscription(
      const OpenAIRealtimeConfig(apiKey: 'test', model: 'gpt-realtime'),
    );

    expect(transcription, {'model': OpenAIRealtimeTranscriptionModels.gpt4oMiniTranscribe});
  });

  test('includes a configured transcription model and hints', () {
    final transcription = _inputTranscription(
      const OpenAIRealtimeConfig(
        apiKey: 'test',
        model: 'gpt-realtime',
        transcriptionModel: OpenAIRealtimeTranscriptionModels.gpt4oTranscribe,
        transcriptionLanguage: 'de',
        transcriptionPrompt: 'German clinic appointment terminology',
      ),
    );

    expect(transcription, {
      'model': OpenAIRealtimeTranscriptionModels.gpt4oTranscribe,
      'language': 'de',
      'prompt': 'German clinic appointment terminology',
    });
  });

  test('omits transcription configuration when it is disabled', () {
    final input = _audioInput(
      const OpenAIRealtimeConfig(
        apiKey: 'test',
        model: 'gpt-realtime',
        enableInputTranscription: false,
      ),
    );

    expect(input, isNot(contains('transcription')));
  });

  test('uses backward-compatible server VAD defaults', () {
    final turnDetection = _turnDetection(
      const OpenAIRealtimeConfig(apiKey: 'test', model: 'gpt-realtime'),
    );

    expect(turnDetection, {
      'type': 'server_vad',
      'create_response': true,
      'interrupt_response': true,
    });
  });

  test('includes configured server VAD tuning', () {
    final turnDetection = _turnDetection(
      const OpenAIRealtimeConfig(
        apiKey: 'test',
        model: 'gpt-realtime',
        createResponseFromVad: false,
        interruptResponseFromVad: false,
        serverVadThreshold: 0.7,
        serverVadPrefixPaddingMs: 250,
        serverVadSilenceDurationMs: 650,
      ),
    );

    expect(turnDetection, {
      'type': 'server_vad',
      'create_response': false,
      'interrupt_response': false,
      'threshold': 0.7,
      'prefix_padding_ms': 250,
      'silence_duration_ms': 650,
    });
  });

  test('rejects invalid server VAD tuning', () {
    expect(
      () => _turnDetection(
        const OpenAIRealtimeConfig(apiKey: 'test', model: 'gpt-realtime', serverVadThreshold: 1.1),
      ),
      throwsArgumentError,
    );
    expect(
      () => _turnDetection(
        const OpenAIRealtimeConfig(
          apiKey: 'test',
          model: 'gpt-realtime',
          serverVadSilenceDurationMs: -1,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('disables server VAD', () {
    final input = _audioInput(
      const OpenAIRealtimeConfig(apiKey: 'test', model: 'gpt-realtime', enableServerVad: false),
    );

    expect(input['turn_detection'], isNull);
  });
}

Map<String, dynamic> _turnDetection(OpenAIRealtimeConfig config) {
  return _audioInput(config)['turn_detection']! as Map<String, dynamic>;
}

Map<String, dynamic> _inputTranscription(OpenAIRealtimeConfig config) {
  return _audioInput(config)['transcription']! as Map<String, dynamic>;
}

Map<String, dynamic> _audioInput(OpenAIRealtimeConfig config) {
  final session = _session(config);
  final audio = session['audio']! as Map<String, dynamic>;
  return audio['input']! as Map<String, dynamic>;
}

Map<String, dynamic> _session(OpenAIRealtimeConfig config) {
  final update = createOpenAIRealtimeSessionUpdate(config);
  return update['session']! as Map<String, dynamic>;
}
