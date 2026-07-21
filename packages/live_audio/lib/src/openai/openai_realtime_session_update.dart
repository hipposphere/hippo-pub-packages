import '../models/live_audio_format.dart';
import '../models/live_audio_tool_mapping.dart';
import 'openai_realtime_config.dart';

Map<String, dynamic> createOpenAIRealtimeSessionUpdate(OpenAIRealtimeConfig config) {
  final session = <String, dynamic>{
    'type': 'realtime',
    'model': config.model,
    if (config.instructions != null) 'instructions': config.instructions,
    'output_modalities': [config.outputModality.name],
    'audio': {
      'input': {
        'format': _format(config.inputFormat),
        if (config.enableInputTranscription)
          'transcription': {
            'model': config.transcriptionModel,
            if (config.transcriptionPrompt != null) 'prompt': config.transcriptionPrompt,
            if (config.transcriptionLanguage != null) 'language': config.transcriptionLanguage,
          },
        'turn_detection': config.enableServerVad
            ? {
                'type': 'server_vad',
                'create_response': config.createResponseFromVad,
                'interrupt_response': config.interruptResponseFromVad,
                if (config.serverVadThreshold != null)
                  'threshold': _serverVadThreshold(config.serverVadThreshold!),
                if (config.serverVadPrefixPaddingMs != null)
                  'prefix_padding_ms': _nonNegativeMilliseconds(
                    config.serverVadPrefixPaddingMs!,
                    'serverVadPrefixPaddingMs',
                  ),
                if (config.serverVadSilenceDurationMs != null)
                  'silence_duration_ms': _nonNegativeMilliseconds(
                    config.serverVadSilenceDurationMs!,
                    'serverVadSilenceDurationMs',
                  ),
              }
            : null,
      },
      'output': {
        'format': _format(config.outputFormat),
        if (config.voice != null) 'voice': config.voice,
      },
    },
    if (config.tools.isNotEmpty)
      'tools': config.tools.map(liveAudioOpenAIToolJson).toList(growable: false),
    if (config.temperature != null) 'temperature': config.temperature,
    ...?config.extraSession,
  };

  return {'type': 'session.update', 'session': session};
}

double _serverVadThreshold(double value) {
  if (!value.isFinite || value < 0 || value > 1) {
    throw ArgumentError.value(value, 'serverVadThreshold', 'Must be between 0 and 1.');
  }
  return value;
}

int _nonNegativeMilliseconds(int value, String name) {
  if (value < 0) {
    throw ArgumentError.value(value, name, 'Must not be negative.');
  }
  return value;
}

Map<String, dynamic> _format(LiveAudioInputFormat format) {
  return {
    'type': format.format.mimeType,
    if (format.format == LiveAudioFormat.pcm16) 'rate': format.sampleRate,
  };
}
