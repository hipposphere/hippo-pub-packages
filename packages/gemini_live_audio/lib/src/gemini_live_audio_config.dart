const defaultGeminiLiveModel = 'gemini-3.1-flash-live-preview';

const defaultGeminiLiveVoice = 'Kore';

const defaultGeminiSystemInstruction =
    'You are Callo, a concise and helpful phone assistant. Speak naturally, '
    'keep answers short, and ask a clarifying question only when needed.';

const defaultGeminiInitialPrompt = 'Greet the caller and ask how you can help.';

final class GeminiLiveAudioConfig {
  const GeminiLiveAudioConfig({
    required this.apiKey,
    this.model = defaultGeminiLiveModel,
    this.voiceName = defaultGeminiLiveVoice,
    this.systemInstruction = defaultGeminiSystemInstruction,
    this.initialPrompt = defaultGeminiInitialPrompt,
  });

  final String apiKey;
  final String model;
  final String voiceName;
  final String systemInstruction;
  final String initialPrompt;
}
