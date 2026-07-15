## 0.2.24

- Prevent native workers from being restarted after final desktop app shutdown.

## 0.2.18

- Update `cross_file` to `^0.3.5+3` and `native_toolchain_c` to `^0.19.2`.
- Breaking: remove `RecordConfig` and move recorder encoding options into
  `AudioRecorderConfig.encoding` (`AudioEncodingConfig`).
- Breaking: rename `NativeAudioRecorder` entrypoints for consistency:
  - `start(...)` -> `startFileRecording(...)`
  - `startStream(...)` -> `startPcmStream(...)`
  - remove `startWithVadSegmentation(...)`, `startVadSegments(...)`, and
    `startVadPipeline(...)` in favor of `startSegmentedCapture(SegmentedAudioCaptureRequest)`.
- Breaking: consolidate Dart models under `lib/src/models/` and generated
  FFI bindings under `lib/src/generated/`.
- Add `NativeAudioRecorder.startSegmentedCapture(SegmentedAudioCaptureRequest)` with:
  - `segments` stream (`VoiceSegment`)
  - `speechStates` stream
  - `levels` stream
  - `frameDecisions` stream (optional)
  - `AudioSegmentSplitMode.vad` and `.manual`
  - `split()`, `pause()`, and `resume()` session controls
  - `stop()` result including optional full-recording artifact
- Add reusable metadata models:
  - `AudioMetadata`
  - `VoiceActivityMetadata`
  - `AudioSegmentMetrics`
- Breaking: remove implicit/default VAD backends from:
  - `Pcm16PauseSplitter`
  - `Pcm16StreamPauseSplitter`
  - `SpeechUtils.splitPcm16OnSilence(...)`
  - `SpeechUtils.splitPcm16StreamOnSilence(...)`
  - `SpeechUtils.splitPcm16AndWriteWavSnippets(...)`
  - `SpeechUtils.splitPcm16AndEncodeAacSnippets(...)`
  Callers must provide an explicit `VadBackend`.
- Breaking: file-based speech utils APIs now use `XFile` instead of `dart:io`
  `File` (`VoiceSegment.file`, snippet write helpers, and snippet split
  helpers that return file lists).
- Breaking: `NativeAudioMetadataReader.readAudioMetadata(...)` now returns
  `AudioMetadata` (replacing `NativeAudioMetadata`).
- Add `NativeAudioRecorder` for native FFI microphone capture:
  - start/stop file recording with `AudioRecorderConfig.encoding`
    (`wav`, `pcm16bits`, `aacLc`, `aacHe`, `aacEld`)
  - start/stop live PCM16 stream recording
  - `getAmplitude()` / `onAmplitudeChanged(...)` recorder amplitude API
- Add native recorder bridges for:
  - macOS (AVFoundation)
  - Windows (miniaudio)
  - iOS (AVFoundation)
- Breaking: replace Apple recorder backend implementation from `AVAudioEngine`
  to `AVCaptureSession` (`AVCaptureAudioDataOutput`) for stream/WAV capture.
- Breaking: iOS recorder processing is now session-mode driven
  (`IosAudioRecorderConfig.sessionMode`) instead of per-feature
  suppression/cancellation toggles.
- Breaking: remove `AppleAudioProcessingConfig` from `AudioProcessingConfig`.
  Apple processing configuration now lives in platform configs:
  `IosAudioRecorderConfig` and `MacosAudioRecorderConfig`.
- Change: `IosAudioRecorderConfig.sessionMode` is now optional; when omitted,
  iOS mode falls back to `AudioProcessingConfig.preset`.
- Switch Windows native AAC/metadata FFI backend to FFmpeg (`libavcodec`/`libavformat`).
- Bundle Windows FFmpeg runtime DLLs from `third_party/ffmpeg/windows/bin` automatically in hook builds.
- Add Windows minimal-FFmpeg CI pipeline to generate required `include/lib/bin`
  artifacts from source.
- Fix iOS native asset staging so switching between device and simulator builds
  no longer leaves stale `speech_utils` frameworks that require a clean build.

## 0.1.3

- Add `NativeAudioMetadataReader` for bundled FFI metadata reads:
  - Duration (microsecond precision)
  - Sample rate (when available)
  - Channel count (when available)
  - Bitrate (when available)
  - Container format (when available)
  - Codec (when available)
  - Codec profile (when available)
- Add native metadata bridges for:
  - macOS (AVFoundation)
  - Windows (native backend)
  - Android (MediaExtractor)
  - iOS (AVFoundation)

## 0.1.2

- Add `NativeAudioEncoder` using native platform tooling:
  - macOS: AVFoundation
  - Windows: bundled native encoder via Dart FFI
  - Android: bundled native NDK encoder via Dart FFI
  - iOS: bundled native AVFoundation encoder via Dart FFI
- Make `SpeechUtils.splitPcm16AndEncodeAacSnippets` default to `NativeAudioEncoder`.
- Add TEN VAD mobile bundles for Android (`arm64-v8a`, `armeabi-v7a`) and iOS arm64 (device).
- Update docs/example to use native AAC encoding without `ffmpeg` fallback.

## 0.1.0

- Add PCM16 silence-based splitting with pluggable VAD backends.
- Add lightweight Dart energy-based VAD backend.
- Add TEN VAD FFI backend with bundled macOS/Windows native assets.
- Add hook/code-assets build integration and generated `ffigen` bindings.
- Add AAC encoding helpers backed by `ffmpeg`.
## Unreleased

- Breaking: remove wake-word detection and voice-action capture APIs, models,
  bundled models, native sherpa-onnx runtimes, tests, and example UI.
- Fixed desktop native worker teardown so Windows app exit releases recorder,
  encoder, and metadata isolates instead of leaving the process running.
