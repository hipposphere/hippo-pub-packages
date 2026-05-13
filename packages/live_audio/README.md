# live_audio

Abstracted live audio service integrations for Dart applications.

This package provides a provider-neutral live audio session API for Hipposphere
voice workflows. It includes concrete integrations for Gemini Live and OpenAI
Realtime speech-to-speech sessions, plus PCM utilities for realtime pipelines.

## Features

- Connects to Gemini Live with API-key authentication through `googleai_dart`.
- Connects to OpenAI Realtime over WebSocket for server-side audio sessions.
- Sends text prompts, PCM audio chunks, tool responses, commit, clear, and close
  commands through a common `LiveAudioSession` interface.
- Emits normalized output audio chunks, input/output transcriptions, text
  deltas, tool calls, turn completion, errors, and raw provider events.
- Includes a PCM 24 kHz to 16 kHz downsampler for little-endian 16-bit audio.

## Usage

```dart
import 'package:live_audio/live_audio.dart';

Future<void> startGeminiLiveAudio(String apiKey, String initialPrompt) async {
  final config = GeminiLiveAudioConfig(
    apiKey: apiKey,
    model: GeminiLiveAudioModels.gemini31FlashLivePreview,
    voiceName: GeminiLiveAudioVoices.kore,
    systemInstruction: 'You are a concise phone assistant.',
  );
  final session = await GeminiLiveAudioService(config).connect();

  try {
    await session.sendText(initialPrompt);

    await for (final event in session.events) {
      switch (event) {
        case LiveAudioOutputChunk(:final bytes):
          // Play provider audio bytes.
          break;
        case LiveAudioTranscript(:final kind, :final text):
          // Show input or output transcript text.
          break;
        case _:
          break;
      }
    }
  } finally {
    await session.close();
  }
}
```

## Dart Edge WebSocket Handler

Mount a drop-in live-audio socket on any Dart Edge router:

```dart
import 'package:dart_edge_http_server/dart_edge_http_server.dart';
import 'package:live_audio/live_audio.dart';

void mountLiveAudio(Router<AppServices> api) {
  api.liveAudioWebSocket(
    '/live-audio',
    service: (socket) {
      return OpenAIRealtimeService(
        OpenAIRealtimeConfig(
          apiKey: socket.services.openAiApiKey,
          model: OpenAIRealtimeModels.gptRealtime2,
          voice: OpenAIRealtimeVoices.marin,
          instructions: 'You are a concise voice assistant.',
        ),
      );
    },
  );
}
```

Client frames:

- Binary frames are treated as raw audio chunks.
- JSON `{ "type": "audio", "audio": "<base64>" }` sends audio.
- JSON `{ "type": "text", "text": "Hello" }` sends text.
- JSON `{ "type": "commit_audio" }` commits buffered audio.
- JSON `{ "type": "clear_audio" }` clears buffered audio.
- JSON `{ "type": "end_audio_input" }` ends the audio input stream.
- JSON `{ "type": "cancel_response" }` cancels OpenAI Realtime output.
- JSON `{ "type": "close" }` closes the provider session and socket.

By default output audio chunks are sent as binary frames, while transcripts,
text deltas, tool calls, errors, and lifecycle events are sent as JSON.

OpenAI Realtime uses 24 kHz mono PCM input by default:

```dart
final session = await OpenAIRealtimeService(
  OpenAIRealtimeConfig(
    apiKey: apiKey,
    model: OpenAIRealtimeModels.gptRealtime2,
    voice: OpenAIRealtimeVoices.marin,
    instructions: 'You are a concise phone assistant.',
    transcriptionLanguage: 'en',
  ),
).connect();

await session.sendAudio(pcm24kChunk);
await session.commitAudio();
```

Customize Gemini through `GeminiLiveAudioConfig`:

```dart
final config = GeminiLiveAudioConfig(
  apiKey: apiKey,
  model: GeminiLiveAudioModels.gemini31FlashLivePreview,
  voiceName: GeminiLiveAudioVoices.kore,
  systemInstruction: 'You are a concise phone assistant.',
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
