## Unreleased

- Breaking: remove `RecordConfig` and move recorder encoding options into
  `AudioRecorderConfig.encoding` (`AudioEncodingConfig`).
- Add `NativeAudioRecorder.startWithVadSegmentation(...)` for live VAD
  segmentation with file-based `VoiceSegment` output.
- Add reusable metadata models:
  - `AudioMetadata`
  - `VoiceActivityMetadata`
  - `AudioSegmentMetrics`
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
- Switch Windows native AAC/metadata FFI backend to FFmpeg (`libavcodec`/`libavformat`).
- Bundle Windows FFmpeg runtime DLLs from `third_party/ffmpeg/windows/bin` automatically in hook builds.
- Add Windows minimal-FFmpeg build-hook pipeline (`SPEECH_UTILS_WINDOWS_FFMPEG_AUTOBUILD=1`)
  to generate required `include/lib/bin` artifacts from source.

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

- Add `NativeAacEncoder` using native platform tooling:
  - macOS: `afconvert`
  - Windows: bundled native encoder via Dart FFI
  - Android: bundled native NDK encoder via Dart FFI
  - iOS: bundled native AVFoundation encoder via Dart FFI
- Make `SpeechUtils.splitPcm16AndEncodeAacSnippets` default to `NativeAacEncoder`.
- Add TEN VAD mobile bundles for Android (`arm64-v8a`, `armeabi-v7a`) and iOS arm64 (device).
- Update docs/example to use native AAC encoding without `ffmpeg` fallback.

## 0.1.0

- Add PCM16 silence-based splitting with pluggable VAD backends.
- Add lightweight Dart energy-based VAD backend.
- Add TEN VAD FFI backend with bundled macOS/Windows native assets.
- Add hook/code-assets build integration and generated `ffigen` bindings.
- Add AAC encoding helpers backed by `ffmpeg`.
