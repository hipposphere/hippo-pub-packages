import 'dart:async';
import 'dart:typed_data';

import 'package:speech_utils_core/speech_utils_core.dart';

enum NativeAudioRecorderPlatform {
  android,
  macOS,
  windows,
  linux,
  iOS,
  web,
  unsupported,
}

final class NativeAudioRecorderCapabilities {
  const NativeAudioRecorderCapabilities({
    required this.supportsNoiseCancellation,
    required this.supportsEchoCancellation,
    required this.supportsVoiceIsolation,
  });

  final bool supportsNoiseCancellation;
  final bool supportsEchoCancellation;
  final bool supportsVoiceIsolation;
}

/// Platform-owned post-record AAC encoder.
///
/// Implementations also own their native assets and threading model. The
/// app-facing package only performs portable PCM/WAV preparation and policy.
abstract interface class NativeAacEncoderBackend {
  String get platformLabel;
  FutureOr<bool> isAvailable();
  FutureOr<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  });
}

abstract interface class NativeAudioMetadataBackend {
  FutureOr<bool> isAvailable();
  FutureOr<AudioMetadata> readAudioMetadata({required String inputPath});
}

/// Native recorder boundary owned by each federated platform package.
///
/// The app-facing package owns orchestration, segmentation, VAD, and output
/// policy. Implementations own microphone lifecycle and their native assets.
abstract class SpeechUtilsPlatform {
  const SpeechUtilsPlatform({
    required this.platform,
    required this.supportsInputSelection,
    required this.capabilities,
  });

  static SpeechUtilsPlatform instance = const UnsupportedSpeechUtilsPlatform();

  final NativeAudioRecorderPlatform platform;
  final bool supportsInputSelection;
  final NativeAudioRecorderCapabilities capabilities;

  NativeAacEncoderBackend? get aacEncoder => null;
  NativeAudioMetadataBackend? get metadataReader => null;

  FutureOr<bool> isAvailable();
  FutureOr<bool> hasPermission();
  FutureOr<bool> requestPermission();
  FutureOr<List<InputDevice>> listInputDevices();
  FutureOr<void> startFile({
    required String outputPath,
    required AudioRecorderConfig config,
  });
  FutureOr<void> startStream({required AudioRecorderConfig config});
  Uint8List readStream({required int maxSamples});
  FutureOr<void> stop();
  FutureOr<void> reset();
  FutureOr<void> setContinousRecording(
    bool enabled, {
    AudioRecorderConfig config = const AudioRecorderConfig(),
  }) {}
  bool isRecording();
  Amplitude getAmplitude();
}

final class UnsupportedSpeechUtilsPlatform extends SpeechUtilsPlatform {
  const UnsupportedSpeechUtilsPlatform()
    : super(
        platform: NativeAudioRecorderPlatform.unsupported,
        supportsInputSelection: false,
        capabilities: const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: false,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: false,
        ),
      );

  Never _unsupported() => throw UnsupportedError(
    'speech_utils has no registered implementation for this platform.',
  );

  @override
  bool isAvailable() => false;

  @override
  bool hasPermission() => _unsupported();

  @override
  FutureOr<bool> requestPermission() => _unsupported();

  @override
  List<InputDevice> listInputDevices() => _unsupported();

  @override
  FutureOr<void> startFile({
    required String outputPath,
    required AudioRecorderConfig config,
  }) => _unsupported();

  @override
  FutureOr<void> startStream({required AudioRecorderConfig config}) =>
      _unsupported();

  @override
  Uint8List readStream({required int maxSamples}) => _unsupported();

  @override
  FutureOr<void> stop() => _unsupported();

  @override
  FutureOr<void> reset() => _unsupported();

  @override
  bool isRecording() => false;

  @override
  Amplitude getAmplitude() => const Amplitude(current: -90.0, max: -90.0);
}
