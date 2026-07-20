import '../live_audio_session.dart';
import 'package:agent_core/agent_core.dart';

final class OpenAIRealtimeModels {
  const OpenAIRealtimeModels._();

  static const gptRealtime2 = 'gpt-realtime-2';
  static const gptRealtime15 = 'gpt-realtime-1.5';
  static const gptRealtime = 'gpt-realtime';
  static const gptRealtime20250828 = 'gpt-realtime-2025-08-28';
  static const gptRealtimeMini = 'gpt-realtime-mini';
  static const gptRealtimeMini20251215 = 'gpt-realtime-mini-2025-12-15';
  static const gptRealtimeMini20251006 = 'gpt-realtime-mini-2025-10-06';
  static const gptRealtimeTranslate = 'gpt-realtime-translate';
  static const gptRealtimeWhisper = 'gpt-realtime-whisper';
}

final class OpenAIRealtimeVoices {
  const OpenAIRealtimeVoices._();

  static const marin = 'marin';
}

final class OpenAIRealtimeTranscriptionModels {
  const OpenAIRealtimeTranscriptionModels._();

  static const gpt4oMiniTranscribe = 'gpt-4o-mini-transcribe';
  static const gpt4oTranscribe = 'gpt-4o-transcribe';
  static const whisper1 = 'whisper-1';
}

enum OpenAIRealtimeOutputModality { audio, text }

final class OpenAIRealtimeConfig {
  const OpenAIRealtimeConfig({
    required this.apiKey,
    required this.model,
    this.voice,
    this.instructions,
    this.outputModality = OpenAIRealtimeOutputModality.audio,
    this.inputFormat = const LiveAudioInputFormat.pcm24k(),
    this.outputFormat = const LiveAudioInputFormat.pcm24k(),
    this.transcriptionModel = OpenAIRealtimeTranscriptionModels.gpt4oMiniTranscribe,
    this.transcriptionLanguage,
    this.transcriptionPrompt,
    this.enableInputTranscription = true,
    this.enableServerVad = true,
    this.createResponseFromVad = true,
    this.tools = const [],
    this.temperature,
    this.extraSession,
    this.baseUrl = 'https://api.openai.com/v1',
  });

  final String apiKey;
  final String model;
  final String? voice;
  final String? instructions;
  final OpenAIRealtimeOutputModality outputModality;
  final LiveAudioInputFormat inputFormat;
  final LiveAudioInputFormat outputFormat;
  final String transcriptionModel;
  final String? transcriptionLanguage;
  final String? transcriptionPrompt;
  final bool enableInputTranscription;
  final bool enableServerVad;
  final bool createResponseFromVad;
  final List<AgentTool<dynamic, dynamic>> tools;
  final double? temperature;
  final Map<String, dynamic>? extraSession;
  final String baseUrl;
}
