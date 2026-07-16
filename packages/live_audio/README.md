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
  deltas, thinking, interruption, tool calls, turn completion, errors, and raw
  provider events.
- Includes a PCM 24 kHz to 16 kHz downsampler for little-endian 16-bit audio.

## Usage

```dart
import 'package:agent_core/agent_core.dart';
import 'package:live_audio/live_audio.dart';

Future<void> startGeminiLiveAudio(
  String apiKey,
  String initialPrompt,
  AgentTool<Map<String, Object?>, Map<String, Object?>> lookupTool,
) async {
  final config = GeminiLiveAudioConfig(
    apiKey: apiKey,
    model: GeminiLiveAudioModels.gemini31FlashLivePreview,
    voiceName: GeminiLiveAudioVoices.kore,
    systemInstruction: 'You are a concise phone assistant.',
    tools: [lookupTool],
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
        case LiveAudioToolCallEvent(:final call):
          final result = await lookupTool.call(
            call.arguments,
            AgentToolCallContext(
              executionId: 'example-session',
              agentId: 'example-live-audio',
            ),
          );
          await session.sendToolResult(
            AgentToolResult<Object?>(
              callId: call.id,
              name: call.name,
              result: result,
            ),
          );
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
    bridgeOptions: LiveAudioDartEdgeWebSocketOptions(
      events: LiveAudioDartEdgeEventFilterConfig(
        sessionStarted: false,
        textDelta: false,
        toolCall: false,
        raw: false,
      ),
    ),
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

All normalized event types are enabled by default. Use
`LiveAudioDartEdgeEventFilterConfig` to disable whole event groups, or
`eventFilter` when the decision depends on event contents:

```dart
bridgeOptions: LiveAudioDartEdgeWebSocketOptions(
  events: LiveAudioDartEdgeEventFilterConfig(
    outputChunk: true,
    transcript: true,
    turnComplete: false,
  ),
  eventFilter: (event) {
    return event is LiveAudioOutputChunk ||
        event is LiveAudioTranscript && event.kind == LiveAudioTranscriptKind.input;
  },
),
```

Client frames:

- Binary frames are treated as raw audio chunks.
- JSON `{ "type": "audio", "audio": "<base64>" }` sends audio.
- JSON `{ "type": "text", "text": "Hello" }` sends text.
- JSON `{ "type": "commit_audio" }` commits buffered audio.
- JSON `{ "type": "clear_audio" }` clears buffered audio.
- JSON `{ "type": "end_audio_input" }` ends the audio input stream.
- JSON `{ "type": "cancel_response" }` cancels OpenAI Realtime output.
- JSON `{ "type": "tool_response", "id": "...", "name": "...", "response": ... }`
  sends a successful Agent tool result. Failed results additionally use an
  `"error"` string while retaining the same message type.
- JSON `{ "type": "close" }` closes the provider session and socket.

By default output audio chunks are sent as binary frames, while transcripts,
text deltas, tool calls, errors, and lifecycle events are sent as JSON.

On generated Dart Edge clients, wrap the connected socket for typed commands:

```dart
final socket = LiveAudioDartEdgeWebSocketClient(
  await client.connectWebSocket(invocation),
);

await socket.sendAudio(pcm24kChunk);
await socket.commitAudio();

socket.audioChunks().listen(playAudio);
socket.jsonEvents().listen(handleLiveAudioEventJson);
```

OpenAI Realtime uses 24 kHz mono PCM input by default:

```dart
final service = OpenAIRealtimeService(
  OpenAIRealtimeConfig(
    apiKey: apiKey,
    model: OpenAIRealtimeModels.gptRealtime2,
    voice: OpenAIRealtimeVoices.marin,
    instructions: 'You are a concise phone assistant.',
    transcriptionLanguage: 'en',
  ),
);
final session = await service.connect();

final outputAudio = session.events.outputAudioStream();
final callAudio = Pcm16StereoStreamCombiner(
  leftAudio: microphonePcm24kStream,
  rightAudio: outputAudio,
).chunks;

callAudio.listen(recordOrPlayStereoPcm16);
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

`Pcm16AudioQueue` serializes PCM16 chunks into one ordered playback stream. By
default it emits fixed 20 ms frames:

```dart
final queue = Pcm16AudioQueue(sampleRate: 24000, channels: 1);
session.events.outputAudioStream().listen(queue.add, onDone: queue.close);
queue.stream.listen(playPcm16);
```

`Pcm16StereoStreamCombiner` combines any two mono PCM16 streams into one pure
stereo PCM16 stream. This is detached from `LiveAudioService`, so it can combine
microphone audio, provider output, websocket audio, or any other PCM16 stream:

```dart
final callAudio = Pcm16StereoStreamCombiner(
  leftAudio: microphonePcm24kStream,
  rightAudio: session.events.outputAudioStream(),
).chunks;

callAudio.listen(recordStereoCallPcm16);
```

`Stream<LiveAudioEvent>.outputAudioStream()` is the lower-level helper for existing
sessions. By default it returns the assistant output audio as provided by the
service:

```dart
final outputAudio = session.events.outputAudioStream();
outputAudio.listen(playPcm16);
```

`audioRateFromMimeType` extracts a numeric sample rate from MIME strings that
include a `rate=` parameter.

## License

This package is proprietary Hipposphere UG software. See `LICENSE`.
