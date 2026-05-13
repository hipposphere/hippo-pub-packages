import '../models/live_audio_tool.dart';

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
    this.vad = const GeminiLiveAudioVadConfig.automatic(),
    this.tools = const [],
  });

  final String apiKey;
  final String model;
  final String? voiceName;
  final String? systemInstruction;
  final bool enableInputTranscription;
  final bool enableOutputTranscription;
  final GeminiLiveAudioVadConfig? vad;
  final List<LiveAudioTool> tools;
}

enum GeminiLiveAudioActivityHandling { startOfActivityInterrupts, noInterruption }

enum GeminiLiveAudioTurnCoverage { onlyActivity, allInput }

enum GeminiLiveAudioVadSensitivity { high, low }

final class GeminiLiveAudioVadConfig {
  const GeminiLiveAudioVadConfig.automatic({
    this.activityHandling = GeminiLiveAudioActivityHandling.startOfActivityInterrupts,
    this.turnCoverage,
    this.startSensitivity,
    this.endSensitivity,
    this.prefixPaddingMs,
    this.silenceDurationMs,
  }) : manual = false;

  const GeminiLiveAudioVadConfig.manual({
    this.activityHandling = GeminiLiveAudioActivityHandling.noInterruption,
    this.turnCoverage,
  }) : manual = true,
       startSensitivity = null,
       endSensitivity = null,
       prefixPaddingMs = null,
       silenceDurationMs = null;

  final bool manual;
  final GeminiLiveAudioActivityHandling activityHandling;
  final GeminiLiveAudioTurnCoverage? turnCoverage;
  final GeminiLiveAudioVadSensitivity? startSensitivity;
  final GeminiLiveAudioVadSensitivity? endSensitivity;
  final int? prefixPaddingMs;
  final int? silenceDurationMs;
}
