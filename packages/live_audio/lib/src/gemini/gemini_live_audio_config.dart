import 'package:googleai_dart/googleai_dart.dart' as genai;

final class GeminiLiveAudioModels {
  const GeminiLiveAudioModels._();

  static const gemini31FlashLivePreview = 'gemini-3.1-flash-live-preview';
}

final class GeminiLiveAudioVoices {
  const GeminiLiveAudioVoices._();

  static const kore = 'Kore';
}

final class GeminiLiveAudioConfig {
  const GeminiLiveAudioConfig({
    required this.apiKey,
    required this.model,
    this.voiceName,
    this.systemInstruction,
    this.enableInputTranscription = true,
    this.enableOutputTranscription = true,
    this.tools = const [],
  });

  final String apiKey;
  final String model;
  final String? voiceName;
  final String? systemInstruction;
  final bool enableInputTranscription;
  final bool enableOutputTranscription;
  final List<genai.Tool> tools;
}
