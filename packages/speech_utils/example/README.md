# speech_utils_example

Flutter example app for `speech_utils`.

## What it demonstrates

- Multi-page demo shell:
  - **Integrated VAD + Compression**
  - **Simple Recorder + Waveform**
  - app-wide theme controls (system/light/dark via `hippo_components` app theme)
- Live microphone streaming with native FFI recorder:
  - `NativeAudioRecorder.startPcmStream(...)`
  - `AudioRecorderConfig(sampleRateHz: 16000, channelCount: 1, framesPerChunk: 1024)`
  - `SpeechUtils.splitPcm16StreamOnSilence(...)` emits snippets during active speaking
- Input routing:
  - list available native input devices
  - pass selected device ID via `AudioRecorderConfig.inputDeviceId` where supported
- Audio processing configuration:
  - processing preset selector (`voice`, `voiceIsolation`, `raw`, `music`)
  - iOS session-mode selection (`voiceChat`, `measurement`, etc.) + macOS queue-duration hint
  - per-feature overrides for noise suppression, echo cancellation, AGC, and high-pass filter (Windows/generic)
  - platform-resolved processing preview (`ios` / `macos` / `windows` / `generic`) in logs and UI
  - preferred processing latency hint
- Live UI:
  - real-time waveform while recording
  - speech/silence indicator from VAD frames (integrated page) and RMS-threshold detection (simple page)
  - chunk counter + RMS + dBFS loudness levels
  - snippet list once speech segments finish
  - playback for WAV and AAC snippets
- Optional compression flow:
  - auto-convert snippets to AAC
  - optional whole-recording AAC conversion on stop
  - visible file-size change stats (WAV -> AAC)
- VAD threshold tuning:
  - TEN preset selector (Sensitive/Balanced/Strict)
  - TEN threshold slider (when TEN live mode is enabled)
  - Energy VAD threshold sliders (primary/secondary RMS, zero-crossing rate)
- Synthetic API checks for all helpers:
  - `splitPcm16OnSilence`
  - `splitPcm16StreamOnSilence`
  - `splitPcm16AndWriteWavSnippets`
  - `splitPcm16AndEncodeAacSnippets`
  - `NativeAudioEncoder.encodePcm16BytesToAac`
  - `NativeAudioEncoder.encodePcm16FileToAac`
  - `NativeAudioEncoder.encodeAudioFileToAac`

## Platforms

- Android: microphone permission configured
- iOS: `NSMicrophoneUsageDescription` configured
- macOS: `NSMicrophoneUsageDescription` configured
- Windows/Linux/Web folders exist from Flutter scaffold

Note: bundled TEN VAD in `speech_utils` targets macOS, Windows x64, Android (`arm64-v8a`, `armeabi-v7a`), and iOS arm64 (device builds). On unsupported targets the app falls back to `EnergyVadBackend`.

## Run

```bash
cd packages/speech_utils/example
flutter run
```

Use:

- Open **Integrated VAD + Compression** for segmentation/compression and synthetic checks.
- Open **Simple Recorder + Waveform** for focused loudness/waveform recording with manual speech threshold.
- Recording uses the native recorder backend.
- Use the `Input device` dropdown (plus refresh) to inspect/select capture routes.
- If waveform is flat, check `Chunks`, `RMS`, and `dBFS` in the status card:
  - `Chunks` should increase continuously while recording.
  - `RMS` and `dBFS` should rise when speaking.
- Playback controls on each finished snippet (and whole recording after stop).
- `AAC options` to enable/disable automatic snippet or whole-recording conversion and compare file-size changes.
- `Audio processing` controls to tune noise cancellation / voice isolation behavior for each recorder mode.
- `VAD tuning` sliders to adjust live speech detection sensitivity.
- `Run Synthetic API Checks` to test all package functions.

## Integration Test: Mic Latency + VAD/AAC Pipeline

This repository includes a desktop integration test at:

- `integration_test/mic_pipeline_integration_test.dart`

What it validates:

- first non-empty microphone PCM chunk capture latency from `NativeAudioRecorder.startPcmStream(...)`
- end-to-end `startVadCapture(...)` pipeline with VAD + native AAC segment encoding
- encoded segment metadata through `NativeAudioMetadataReader`

Run on macOS:

```bash
cd packages/speech_utils/example
flutter test integration_test/mic_pipeline_integration_test.dart -d macos
```

Run on Windows:

```bash
cd packages/speech_utils/example
flutter test integration_test/mic_pipeline_integration_test.dart -d windows
```

Optional latency threshold tuning (milliseconds):

```bash
flutter test integration_test/mic_pipeline_integration_test.dart -d macos --dart-define=SPEECH_UTILS_MAX_FIRST_AUDIO_LATENCY_MS=800
```

Notes:

- The test requires an available microphone and granted microphone permission.
- The VAD pipeline test uses permissive Energy VAD thresholds so it still validates end-to-end flow in quiet environments.
