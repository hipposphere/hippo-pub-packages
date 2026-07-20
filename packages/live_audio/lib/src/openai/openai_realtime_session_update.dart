import '../models/live_audio_format.dart';
import '../models/live_audio_tool_mapping.dart';
import 'openai_realtime_config.dart';

Map<String, dynamic> createOpenAIRealtimeSessionUpdate(OpenAIRealtimeConfig config) {
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
            'model': config.transcriptionModel,
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
      'tools': config.tools.map(liveAudioOpenAIToolJson).toList(growable: false),
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
