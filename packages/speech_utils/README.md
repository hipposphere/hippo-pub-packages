# speech_utils

`speech_utils` provides three focused capabilities for PCM16 speech workflows:

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
  - live VAD segmentation to file-based `VoiceSegment` outputs (`XFile`)
  - input device listing (`listInputDevices`)
  - input-device routing via `AudioRecorderConfig.inputDeviceId` on platforms that support it
- No dependency on the legacy `record` package for microphone capture.
- Zero-copy snippet views (`Int16List.view`, `Uint8List.view`).

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

  final snippets = SpeechUtils.splitPcm16OnSilence(
    pcm16leBytes: pcm16leBytes,
    options: options,
    vadConfig: const SpeechVadConfig.preferTen(
      ten: TenVadConfig(threshold: 0.45),
    ),
  );

  final encoder = NativeAacEncoder();
  for (var i = 0; i < snippets.length; i++) {
    await encoder.encodePcm16BytesToAac(
      pcm16leBytes: snippets[i].asBytesView(),
      sampleRateHz: options.sampleRateHz,
      channelCount: options.channelCount,
      outputPath: 'snippet_$i.m4a',
      bitrateKbps: 48,
    );
  }
}
```

### Live stream mode

```dart
final snippets = SpeechUtils.splitPcm16StreamOnSilence(
  pcm16leStream: livePcmChunkStream,
  options: const PauseSplitOptions(
    sampleRateHz: 16000,
    channelCount: 1,
  ),
  vadConfig: const SpeechVadConfig.preferTen(
    ten: TenVadConfig(threshold: 0.45),
  ),
);

await for (final snippet in snippets) {
  // snippet is emitted as soon as a silence boundary is reached.
  print('snippet duration: ${snippet.duration}');
}
```

### Native recorder (FFI)

```dart
final recorder = NativeAudioRecorder();
final permissionGranted = await recorder.requestPermission();
if (!permissionGranted) {
  throw StateError('Microphone permission denied');
}

await recorder.start(
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

`start()` output encoding is controlled by `AudioRecorderConfig.encoding` and
supports `AudioEncoder.wav`, `AudioEncoder.pcm16bits`,
`AudioEncoder.aacLc`, `AudioEncoder.aacHe`, and `AudioEncoder.aacEld`.
For AAC outputs, the recorder captures native WAV and finalizes AAC on `stop()`.

Input device discovery/selection:

```dart
final devices = await recorder.listInputDevices();
final preferred = devices.where((d) => d.isDefault).toList();
final target = preferred.isNotEmpty ? preferred.first : (devices.isNotEmpty ? devices.first : null);

if (recorder.supportsInputSelection) {
  await recorder.start(
    outputPath: '/tmp/recording.wav',
    config: AudioRecorderConfig(
      sampleRateHz: 16000,
      channelCount: 1,
      inputDeviceId: target?.id,
    ),
  );
}
```

Stream mode:

```dart
final recorder = NativeAudioRecorder();
final pcmStream = await recorder.startStream(
  config: const AudioRecorderConfig(
    sampleRateHz: 16000,
    channelCount: 1,
    framesPerChunk: 1024,
    encoding: AudioEncodingConfig(
      // Used by higher-level recording helpers such as
      // startWithVadSegmentation(...).
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

Live VAD segmentation mode:

```dart
final recorder = NativeAudioRecorder();
final segments = await recorder.startWithVadSegmentation(
  outputDirectory: Directory('/tmp/segments'),
  splitOptions: const PauseSplitOptions(
    sampleRateHz: 16000,
    channelCount: 1,
    frameDuration: Duration(milliseconds: 20),
  ),
  config: const AudioRecorderConfig(
    sampleRateHz: 16000,
    channelCount: 1,
    encoding: AudioEncodingConfig(
      encoder: AudioEncoder.aacLc,
      bitrateBps: 64000,
    ),
  ),
  flushOnStop: true,
);

await for (final segment in segments) {
  print('segment #${segment.index}: ${segment.file.path}');
  print('duration: ${segment.metadata.duration}');
  print('speech probability: ${segment.voiceActivity.speechProbability}');
}
```

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
  - Android: `arm64-v8a`, `armeabi-v7a`
  - iOS: arm64 (device build)
- Ensure frame size in `PauseSplitOptions` matches TEN hop size.
  Example: 16kHz with `hopSize=256` means `frameDuration=16ms`.
- For unsupported platforms, `TenVadFfiBackend.tryCreate(...)` returns `null`.

## Platform notes

- Segmentation: works on any Dart platform.
- TEN VAD FFI: bundled via `hook/build.dart` for macOS, Windows x64, Android
  (`arm64-v8a`, `armeabi-v7a`), and iOS arm64 (device build).
- AAC encoding (`NativeAacEncoder`) without `ffmpeg` fallback:
  - macOS: bundled native AVFoundation encoder via Dart FFI
  - Windows: bundled native FFmpeg encoder (`libavcodec`) via Dart FFI
  - Android: bundled native NDK encoder via Dart FFI (expects PCM16 WAV input
    when calling `encodeAudioFileToAac`)
  - iOS: bundled native AVFoundation encoder via Dart FFI
- Audio metadata (`NativeAudioMetadataReader`) via bundled native FFI:
  - macOS: AVFoundation
  - Windows: FFmpeg (`libavformat`)
  - Android: MediaExtractor
  - iOS: AVFoundation
- Audio recording (`NativeAudioRecorder`) via bundled native FFI:
  - macOS: AVFoundation
  - Windows: miniaudio
  - iOS: AVFoundation

Windows FFmpeg build notes:

- The hook expects a prebuilt SDK in
  `third_party/ffmpeg/windows/{include,lib,bin}`.
- Missing FFmpeg SDK now fails Windows AAC/metadata native asset build.
- CI prebuild workflow:
  `.github/workflows/build_windows_ffmpeg_lib.yml` (manual trigger,
  uploads zipped `include/lib/bin` SDK artifact).
- Runtime DLLs in `bin/` are bundled automatically as native assets.
- See `third_party/ffmpeg/windows/README.md` for full details.

## Maintainers

Regenerate TEN bindings after changing bridge/header files:

```bash
cd packages/speech_utils
dart run ffigen --config ffigen.yaml
```

Run the Flutter example app:

```bash
cd packages/speech_utils/example
flutter run
```
