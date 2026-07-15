# Federated migration

The existing `speech_utils` behavior is the baseline. Federation changes
ownership and package boundaries; it does not authorize replacing a working
native engine, codec, optimization, recovery path, or public behavior.

## Package graph

- `speech_utils_core`: pure-Dart public models and contracts.
- `speech_utils_platform_interface`: typed recorder backend boundary and
  registration point.
- `speech_utils`: app-facing orchestration, segmentation, VAD policy, codec
  policy, compatibility exports, and the future cleaner facade.
- `speech_utils_android`: Android `AudioRecord`/MediaRecorder and MediaCodec
  assets.
- `speech_utils_ios`: independent iOS AVFoundation/session implementation.
- `speech_utils_macos`: independent macOS AVFoundation/CoreAudio implementation.
- `speech_utils_windows`: miniaudio capture, WebRTC audio processing, bundled
  FFmpeg/libavcodec AAC and metadata.
- `speech_utils_linux`: miniaudio capture and bundled FFmpeg/libavcodec AAC.
- `speech_utils_web`: AudioWorklet capture and browser/WASM providers.
- `speech_utils_vad_ten`: TEN binaries, WASM, bindings, and health reporting.

The last seven packages are extracted in that order only when useful for
risk control; iOS and macOS remain independent implementations.

## Current boundary

`NativeAudioRecorder()` first uses a matching implementation registered with
`SpeechUtilsPlatform.instance`. Until a platform owner has been extracted, it
falls back to the existing in-package implementation. This keeps current apps
working while allowing one platform at a time to move behind the federated
contract.

Extracted and endorsed now:

- `speech_utils_macos`: AVFoundation recorder and persistent control worker.
- `speech_utils_ios`: independent AVFoundation/AVAudioSession recorder.
- `speech_utils_windows`: miniaudio, WebRTC processing, FFmpeg AAC, and
  metadata assets.
- `speech_utils_linux`: miniaudio and FFmpeg AAC assets.

Android is now extracted with its JNI classes, generated bindings,
AudioRecord/MediaRecorder paths, MediaCodec AAC, and permission behavior.
AAC and metadata native ownership also lives in every endorsed platform
package. TEN assets live in `speech_utils_vad_ten`. Web remains a new
implementation rather than a legacy move.

## Non-regression rules

1. Move existing tests and native-asset smoke tests with each backend.
2. Preserve Windows and Linux miniaudio until another backend wins the full
   hardware, crash, latency, and leak matrix.
3. Preserve Windows/Linux FFmpeg/libavcodec AAC. Do not replace it with Media
   Foundation.
4. Keep recorder control, codec finalization, and metadata work on their
   existing long-lived workers.
5. Keep hot PCM reads and amplitude polling bounded and out of method channels.
6. Preserve TEN-first VAD with typed fallback rather than swallowing failures.
7. Do not add `record`, `record_windows`, or another record-family dependency.
8. Do not remove the legacy fallback for a platform until its endorsed package
   passes the original unit/integration suite and native hardware gates.

## Validation

Run shared tests from their owning package directories so Dart native assets
are built and resolved correctly:

```sh
cd packages/speech_utils_platform_interface && dart test
cd ../speech_utils && flutter test test
```

Workspace-root analysis remains supported. Hardware integration tests under
`speech_utils/example/integration_test` are run separately on matching hosts.
