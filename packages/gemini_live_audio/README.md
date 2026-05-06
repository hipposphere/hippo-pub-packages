# gemini_live_audio

Live Gemini audio integration for Dart applications.

This package wraps the `googleai_dart` Live API setup used by Hipposphere
voice workflows. It provides configuration defaults for a phone-assistant style
session, helpers for connecting to a Gemini Live audio session, and PCM audio
utilities for realtime audio pipelines.

## Features

- Connects to Gemini Live with API-key authentication.
- Configures audio-only generation with a named Gemini voice.
- Sends text prompts, audio chunks, and tool responses to the live session.
- Exposes server messages from the Gemini bidirectional stream.
- Includes a PCM 24 kHz to 16 kHz downsampler for little-endian 16-bit audio.

## Usage

```dart
import 'package:gemini_live_audio/gemini_live_audio.dart';

Future<void> startGeminiLiveAudio(String apiKey) async {
  final config = GeminiLiveAudioConfig(apiKey: apiKey);
  final client = await GeminiLiveAudioClient.connect(config);

  try {
    await client.sendText(config.initialPrompt);

    await for (final message in client.messages) {
      // Handle Gemini Live server messages.
    }
  } finally {
    await client.close();
  }
}
```

Customize the model, voice, system instruction, or initial prompt through
`GeminiLiveAudioConfig`:

```dart
final config = GeminiLiveAudioConfig(
  apiKey: apiKey,
  model: 'gemini-3.1-flash-live-preview',
  voiceName: 'Kore',
  systemInstruction: 'You are a concise phone assistant.',
  initialPrompt: 'Greet the caller and ask how you can help.',
);
```

## Audio Helpers

`Pcm24kTo16kDownsampler` converts little-endian 16-bit PCM audio from 24 kHz to
16 kHz while preserving partial frames between chunks:

```dart
final downsampler = Pcm24kTo16kDownsampler();
final pcm16k = downsampler.convert(pcm24kChunk);
```

`audioRateFromMimeType` extracts a numeric sample rate from MIME strings that
include a `rate=` parameter.

## License

This package is proprietary Hipposphere UG software. See `LICENSE`.
