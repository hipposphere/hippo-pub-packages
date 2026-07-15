# speech_utils

`speech_utils` is migrating in place to a federated package family. Public
shared types now live in `speech_utils_core`, and native recorder backends use
the contract from `speech_utils_platform_interface`. Existing native engines
remain the compatibility and performance baseline while their assets are
moved into endorsed platform packages. See [FEDERATION.md](FEDERATION.md).

`speech_utils` provides four focused capabilities for PCM16 speech workflows:

1. Split PCM16 recordings into snippets when silence is detected.
2. Encode/compress PCM16 snippets into AAC.
3. Read audio duration and basic metadata through bundled native FFI bridges.
4. Record microphone input through bundled native FFI bridges.

It is designed to avoid unnecessary copying by using typed-data views over the
original PCM buffers.

## Features

- Silence segmentation for PCM16 streams.
- Live stream segmentation for active recording pipelines.
- Default VAD selection: TEN VAD when compatible, otherwise Energy VAD.
- Bundled TEN VAD backend via Dart hooks/code-assets.
- AAC encoding through native platform tooling with helpers for:
  - PCM16 bytes -> AAC file
  - PCM16 raw file -> AAC file
  - Existing audio file -> AAC file
- Native audio metadata lookup:
  - duration
  - sample rate (if available)
  - channel count (if available)
  - bitrate (if available)
  - container format (if available)
  - codec (if available)
  - codec profile (if available)
- Native audio recorder (`NativeAudioRecorder`) with:
  - start/stop file recording (`.wav` PCM16)
  - start/stop live PCM16 stream recording
  - live segmented capture to file-based `VoiceSegment` outputs (`XFile`)
  - input device listing (`listInputDevices`)
  - input-device routing via `AudioRecorderConfig.inputDeviceId` on platforms that support it
- No dependency on the legacy `record` package for microphone capture.
- Zero-copy snippet views (`Int16List.view`, `Uint8List.view`).

On Windows and macOS, slow recorder control operations (permission, device
discovery, start, stop/finalization, reset, and warm-capture changes) run on a
single long-lived worker isolate. Desktop file encoding and metadata reads use
their own bounded workers. High-frequency PCM reads and amplitude polling stay
local to avoid cross-isolate audio-buffer copies.

## Install

```yaml
dependencies:
  speech_utils: any
```

## Usage

```dart
import 'dart:typed_data';

import 'package:speech_utils/speech_utils.dart';

Future<void> run(Uint8List pcm16leBytes) async {
  final options = PauseSplitOptions(
    sampleRateHz: 16000,
    channelCount: 1,
    minSilenceDuration: const Duration(milliseconds: 750),
  );
  final vad = SpeechUtils.resolveVadBackend(
    options: options,
    config: const SpeechVadConfig.preferTen(
      ten: TenVadConfig(threshold: 0.45),
    ),
  );

  try {
    final snippets = SpeechUtils.splitPcm16OnSilence(
      pcm16leBytes: pcm16leBytes,
      options: options,
      vadBackend: vad.backend,
    );

    final encoder = NativeAudioEncoder();
    for (var i = 0; i < snippets.length; i++) {
      await encoder.encodePcm16BytesToAac(
        pcm16leBytes: snippets[i].asBytesView(),
        sampleRateHz: options.sampleRateHz,
        channelCount: options.channelCount,
        outputPath: 'snippet_$i.m4a',
        bitrateKbps: 48,
      );
    }
  } finally {
    vad.backend.dispose();
  }
}
```

### Live stream mode

```dart
final options = const PauseSplitOptions(
  sampleRateHz: 16000,
  channelCount: 1,
);
final vad = SpeechUtils.resolveVadBackend(
  options: options,
  config: const SpeechVadConfig.preferTen(
    ten: TenVadConfig(threshold: 0.45),
  ),
);

final snippets = SpeechUtils.splitPcm16StreamOnSilence(
  pcm16leStream: livePcmChunkStream,
  options: options,
  vadBackend: vad.backend,
);

try {
  await for (final snippet in snippets) {
    // snippet is emitted as soon as a silence boundary is reached.
    print('snippet duration: ${snippet.duration}');
  }
} finally {
  vad.backend.dispose();
}
```

### Native recorder (FFI)

Recorder API naming:
- file capture: `startFileRecording(...)`
- raw PCM stream capture: `startPcmStream(...)`
- segmented capture session: `startSegmentedCapture(...)`

```dart
final recorder = NativeAudioRecorder();
final permissionGranted = await recorder.requestPermission();
if (!permissionGranted) {
  throw StateError('Microphone permission denied');
}

await recorder.startFileRecording(
  outputPath: '/tmp/recording.wav',
  config: const AudioRecorderConfig(
    sampleRateHz: 16000,
    channelCount: 1,
    encoding: AudioEncodingConfig(
      encoder: AudioEncoder.wav,
    ),
  ),
);

// ... later
await recorder.stop();
```

`startFileRecording()` output encoding is controlled by `AudioRecorderConfig.encoding` and
supports `AudioEncoder.wav`, `AudioEncoder.pcm16bits`,
`AudioEncoder.aacLc`, `AudioEncoder.aacHe`, and `AudioEncoder.aacEld`.
For AAC outputs on Apple platforms (`macOS`/`iOS`), recording writes directly to `.m4a`.
On iOS this is backed by `AVAudioRecorder` (AAC-LC), while non-Apple platforms keep the
WAV-then-encode finalization path on `stop()`.

Input device discovery/selection:

```dart
final devices = await recorder.listInputDevices();
final preferred = devices.where((d) => d.isDefault).toList();
final target = preferred.isNotEmpty ? preferred.first : (devices.isNotEmpty ? devices.first : null);

if (recorder.supportsInputSelection) {
  await recorder.startFileRecording(
    outputPath: '/tmp/recording.wav',
    config: AudioRecorderConfig(
      sampleRateHz: 16000,
      channelCount: 1,
      inputDeviceId: target?.id,
    ),
  );
}
```

Processing + platform-specific config:

```dart
await recorder.startFileRecording(
  outputPath: '/tmp/recording.wav',
  config: const AudioRecorderConfig(
    sampleRateHz: 16000,
    channelCount: 1,
    processing: AudioProcessingConfig(
      preset: AudioCapturePreset.voiceIsolation,
      windows: WindowsAudioProcessingConfig(
        usePresetDefaults: true,
        enableNoiseSuppression: true,
        enableEchoCancellation: true,
        enableAutomaticGainControl: true,
      ),
    ),
    iosConfig: IosAudioRecorderConfig(
      sessionMode: IosAudioSessionMode.voiceChat,
      allowBluetoothInput: true,
      defaultToSpeaker: false,
    ),
    macosConfig: MacosAudioRecorderConfig(
      processingQueueDuration: Duration(milliseconds: 40),
    ),
    windowsConfig: WindowsAudioRecorderConfig(
      captureCategory: WindowsCaptureCategory.communications,
      useCommunicationsDevice: true,
    ),
  ),
);
```

`processing`, `iosConfig`, `macosConfig`, and `windowsConfig` are best-effort hints and may
be applied partially depending on platform/backend capabilities.
`processing.preferredLatency` is mapped to native capture buffering where possible
(iOS I/O buffer hint, macOS recorder queue budget, and Windows period-size hint).
On iOS, stream capture and PCM/WAV file capture use `AVAudioEngine` input taps.
iOS processing is session-mode driven via `IosAudioRecorderConfig.sessionMode`
(for example `voiceChat` or `measurement`). If `sessionMode` is omitted, mode
selection defaults to `defaultMode`. Per-feature suppression/cancellation toggles
are not applied on iOS/macOS recorder backends.

Stream mode:

```dart
final recorder = NativeAudioRecorder();
final pcmStream = await recorder.startPcmStream(
  config: const AudioRecorderConfig(
    sampleRateHz: 16000,
    channelCount: 1,
    framesPerChunk: 1024,
    encoding: AudioEncodingConfig(
      // Used by higher-level recording helpers such as startSegmentedCapture(...).
      encoder: AudioEncoder.aacLc,
      bitrateBps: 64000,
    ),
  ),
);

await for (final pcmChunk in pcmStream) {
  // PCM16 little-endian bytes.
}
```

Amplitude updates (record-style API):

```dart
final subscription = recorder
    .onAmplitudeChanged(const Duration(milliseconds: 200))
    .listen((amplitude) {
  print('current=${amplitude.current} dBFS, max=${amplitude.max} dBFS');
});

final latest = await recorder.getAmplitude();
print('latest=${latest.current} dBFS');

await subscription.cancel();
```

Live segmented capture mode:

```dart
final recorder = NativeAudioRecorder();
final capture = await recorder.startSegmentedCapture(
  SegmentedAudioCaptureRequest(
    splitMode: AudioSegmentSplitMode.vad,
    split: const PauseSplitOptions(
      sampleRateHz: 16000,
      channelCount: 1,
      frameDuration: Duration(milliseconds: 20),
    ),
    audio: const AudioRecorderConfig(
      sampleRateHz: 16000,
      channelCount: 1,
      framesPerChunk: 256,
    ),
    output: SegmentedAudioCaptureOutputConfig(
      outputDirectory: Directory('/tmp/segments'),
      segmentEncoding: const AudioEncodingConfig(
        encoder: AudioEncoder.aacLc,
        bitrateBps: 64000,
      ),
      emitFullRecordingOnStop: true,
      fullRecordingEncoding: const AudioEncodingConfig(
        encoder: AudioEncoder.wav,
      ),
      fullRecordingFileStem: 'recording_full',
    ),
    telemetry: const SegmentedAudioCaptureTelemetryConfig(
      speechHoldDuration: Duration(milliseconds: 320),
    ),
  ),
);

capture.speechStates.listen((state) {
  print('speech detected: ${state.speechDetected}');
});

capture.segments.listen((segment) {
  print('segment #${segment.index}: ${segment.file.path}');
  print('duration: ${segment.metadata.duration}');
  print('speech probability: ${segment.voiceActivity.speechProbability}');
});

// ... later
final result = await capture.stop();
print('segments: ${result.segmentCount}');
if (result.fullRecording != null) {
  print('full recording: ${result.fullRecording!.file.path}');
}
```

Use `splitMode: AudioSegmentSplitMode.manual` and call `capture.split()` when
the active segment should be closed manually.

### VAD config modes

```dart
const preferTen = SpeechVadConfig.preferTen(
  ten: TenVadConfig(threshold: 0.40),
  energy: EnergyVadConfig(
    primaryRmsThreshold: 0.006,
    secondaryRmsThreshold: 0.003,
    minZeroCrossingRate: 0.02,
  ),
);

const tenOnly = SpeechVadConfig.tenOnly(
  ten: TenVadConfig(threshold: 0.50),
);

const energyOnly = SpeechVadConfig.energyOnly(
  energy: EnergyVadConfig(
    primaryRmsThreshold: 0.015,
    secondaryRmsThreshold: 0.010,
    minZeroCrossingRate: 0.08,
  ),
);
```

### Native audio metadata

```dart
final metadataReader = NativeAudioMetadataReader();
final metadata = await metadataReader.readAudioMetadata(
  inputPath: '/tmp/recording.m4a',
);

print('durationMicros: ${metadata.duration.inMicroseconds}');
print('durationMs: ${(metadata.duration.inMicroseconds / 1000).toStringAsFixed(1)}');
print('sampleRateHz: ${metadata.sampleRateHz}');
print('channelCount: ${metadata.channelCount}');
print('bitrateBps: ${metadata.bitrateBps}');
print('containerFormat: ${metadata.containerFormat}');
print('codec: ${metadata.codec}');
print('codecProfile: ${metadata.codecProfile}');
```

## TEN VAD FFI

Use TEN VAD directly (bundled native asset):

```dart
final tenVad = TenVadFfiBackend(
  hopSize: 256,
  threshold: 0.5,
);
```

Notes:

- TEN VAD backend in this package expects mono, 16kHz PCM16.
- Native TEN VAD is bundled for:
  - macOS (universal binary: arm64 + x64)
  - Windows x64
  - Linux x64
  - Android: `arm64-v8a`, `armeabi-v7a`
  - iOS: arm64 (device build)
- Ensure frame size in `PauseSplitOptions` matches TEN hop size.
  Example: 16kHz with `hopSize=256` means `frameDuration=16ms`.
- For unsupported platforms, `TenVadFfiBackend.tryCreate(...)` returns `null`.

## Platform notes

- Segmentation: works on any Dart platform.
- TEN VAD FFI: bundled by `speech_utils_vad_ten` for macOS, Windows x64,
  Linux x64, Android (`arm64-v8a`, `armeabi-v7a`), and iOS arm64
  (device build).
- AAC encoding (`NativeAudioEncoder`) without `ffmpeg` fallback:
  - macOS: bundled native AVFoundation encoder via Dart FFI
  - Windows: bundled native FFmpeg encoder (`libavcodec`) via Dart FFI
  - Linux: bundled native FFmpeg encoder (`libavcodec`) via Dart FFI
  - Android: bundled native NDK encoder via Dart FFI (expects PCM16 WAV input
    when calling `encodeAudioFileToAac`)
  - iOS: bundled native AVFoundation encoder via Dart FFI
- Audio metadata (`NativeAudioMetadataReader`) via bundled native FFI:
  - macOS: AVFoundation
  - Windows: FFmpeg (`libavformat`)
  - Linux: FFmpeg (`libavformat`)
  - Android: MediaExtractor
  - iOS: AVFoundation
- Audio recording (`NativeAudioRecorder`) via bundled native FFI:
  - macOS: AVFoundation
  - Windows: miniaudio
  - Linux: miniaudio
  - iOS: AVFoundation

Windows/Linux FFmpeg platform-package build notes:

- The hook expects a prebuilt SDK in
  `speech_utils_windows/third_party/ffmpeg/windows/{include,lib,bin}` or
  `speech_utils_linux/third_party/ffmpeg/linux/{include,lib}`.
- Missing FFmpeg SDK now fails Windows/Linux AAC/metadata native asset build.
- CI prebuild workflow:
  `.github/workflows/build_windows_ffmpeg_lib.yml` (manual trigger,
  uploads zipped `include/lib/bin` SDK artifact).
- Build/verify the Linux SDK locally:
  `packages/speech_utils_linux/tool/build_linux_ffmpeg_sdk.sh`
  `packages/speech_utils_linux/tool/verify_linux_ffmpeg_bundle.sh`
- Windows runtime DLLs in `bin/` and Linux runtime `.so` files in `lib/` are
  bundled automatically as native assets.
- See the `third_party/ffmpeg` directories in `speech_utils_windows` and
  `speech_utils_linux` for full details.

## Maintainers

Regenerate TEN bindings after changing bridge/header files:

```bash
cd packages/speech_utils_vad_ten
dart run ffigen --config ffigen.yaml
```

Run the Flutter example app:

```bash
cd packages/speech_utils/example
flutter run
```
