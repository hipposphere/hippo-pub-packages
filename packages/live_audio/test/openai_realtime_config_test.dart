import 'package:live_audio/src/openai/openai_realtime_config.dart';
import 'package:live_audio/src/openai/openai_realtime_session_update.dart';
import 'package:test/test.dart';

void main() {
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
}

Map<String, dynamic> _inputTranscription(OpenAIRealtimeConfig config) {
  return _audioInput(config)['transcription']! as Map<String, dynamic>;
}

Map<String, dynamic> _audioInput(OpenAIRealtimeConfig config) {
  final update = createOpenAIRealtimeSessionUpdate(config);
  final session = update['session']! as Map<String, dynamic>;
  final audio = session['audio']! as Map<String, dynamic>;
  return audio['input']! as Map<String, dynamic>;
}
