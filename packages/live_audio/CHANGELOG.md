## 0.2.3

- Adds typed OpenAI server VAD controls for activation threshold, prefix
  padding, silence duration, and automatic response interruption.
- Preserves the existing OpenAI VAD behavior when the new controls are omitted.

## 0.2.1

- Adds the required transcription model to OpenAI Realtime input
  transcription configuration, defaulting to `gpt-4o-mini-transcribe`.

## 0.2.0

- Replaces the package-specific live audio tool descriptor, call, and response
  types with executable `agent_core` tools and shared Agent call/result models.
- Keeps live audio tool execution caller-controlled while allowing the same
  tools and schemas to be reused by text Agents.
- Preserves the existing `tool_call` and `tool_response` WebSocket wire message
  names and adds error results.

## 0.1.4

- Adds normalized `turnId` metadata to live audio output, text, transcript, thinking, interrupted, and turn-complete events.
- Update `openai_dart` to `^7.0.0`.

## 0.1.1

- Adds provider-neutral `LiveAudioSession.sendToolResponse`.
- Adds normalized `LiveAudioInterrupted` and `LiveAudioThinking` events.
- Adds Dart Edge socket support for tool response messages and the new events.

## 0.1.0

- Initial release.
- Replaces `gemini_live_audio` with the provider-neutral `live_audio` package.
- Adds normalized live audio session events and session commands.
- Adds Gemini Live audio-to-audio and transcription integration.
- Adds OpenAI Realtime WebSocket audio-to-audio and transcription integration.
- Keeps PCM audio utilities for realtime audio pipelines.
