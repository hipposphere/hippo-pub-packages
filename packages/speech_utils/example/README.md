# speech_utils_example

Flutter example app for `speech_utils`.

## What it demonstrates

- Live microphone streaming with `record`:
  - `AudioRecorder.startStream(...)`
  - PCM16 (`AudioEncoder.pcm16bits`) at 16kHz mono
  - `SpeechUtils.splitPcm16StreamOnSilence(...)` emits snippets during active speaking
- Live UI:
  - real-time waveform while recording
  - speech/silence indicator from VAD frames
  - chunk counter + RMS level to verify raw mic signal
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
  - `NativeAacEncoder.encodePcm16BytesToAac`
  - `NativeAacEncoder.encodePcm16FileToAac`
  - `NativeAacEncoder.encodeAudioFileToAac`

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

- `Start Live Stream` to capture mic PCM, view waveform/speech state, and generate snippets on silence boundaries.
- If waveform is flat, check `Chunks` and `RMS` in the status card:
  - `Chunks` should increase continuously while recording.
  - `RMS` should rise when speaking.
- Playback controls on each finished snippet (and whole recording after stop).
- `AAC options` to enable/disable automatic snippet or whole-recording conversion and compare file-size changes.
- `VAD tuning` sliders to adjust live speech detection sensitivity.
- `Run Synthetic API Checks` to test all package functions.
