import 'dart:async';
import 'dart:typed_data';

import 'package:speech_utils/speech_utils.dart';

const _unsupportedAudioRecorderMessage =
    'NativeAudioRecorder is currently supported on Android, macOS, Windows, Linux, and iOS.';

typedef StartFileHook =
    FutureOr<void> Function({
      required String outputPath,
      required int sampleRateHz,
      required int channelCount,
      required String? inputDeviceId,
    });

typedef StartStreamHook =
    FutureOr<void> Function({
      required int sampleRateHz,
      required int channelCount,
      required int framesPerChunk,
      required String? inputDeviceId,
    });

typedef ReadStreamHook = Uint8List Function({required int maxSamples});
typedef SetContinousRecordingHook =
    FutureOr<void> Function({required bool enabled, required AudioRecorderConfig config});

NativeAudioRecorder recorderFixture({
  required NativeAudioRecorderPlatform platform,
  bool Function()? availabilityFn,
  bool Function()? hasPermissionFn,
  FutureOr<bool> Function()? requestPermissionFn,
  List<InputDevice> Function()? listInputDevicesFn,
  StartFileHook? startFileFn,
  StartStreamHook? startPcmStreamFn,
  ReadStreamHook? readPcmStreamFn,
  SetContinousRecordingHook? setContinousRecordingFn,
  FutureOr<void> Function()? stopFn,
  FutureOr<void> Function()? resetFn,
  bool Function()? isRecordingFn,
  Amplitude Function()? getAmplitudeFn,
}) {
  final isUnsupportedPlatform = platform == NativeAudioRecorderPlatform.unsupported;

  return NativeAudioRecorder.custom(
    platformImplementation: _TestNativeAudioRecorderPlatformImplementation(
      platform: platform,
      supportsInputSelection: !isUnsupportedPlatform,
      capabilities: switch (platform) {
        NativeAudioRecorderPlatform.android => const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: false,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: false,
        ),
        NativeAudioRecorderPlatform.macOS => const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: false,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: true,
        ),
        NativeAudioRecorderPlatform.windows => const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: true,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: true,
        ),
        NativeAudioRecorderPlatform.linux => const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: true,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: true,
        ),
        NativeAudioRecorderPlatform.iOS => const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: false,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: true,
        ),
        NativeAudioRecorderPlatform.unsupported => const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: false,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: false,
        ),
      },
      availabilityFn: availabilityFn ?? () => !isUnsupportedPlatform,
      hasPermissionFn:
          hasPermissionFn ??
          () {
            if (isUnsupportedPlatform) {
              throw const NativeAudioRecorderUnsupportedPlatformException(
                _unsupportedAudioRecorderMessage,
              );
            }
            return true;
          },
      requestPermissionFn:
          requestPermissionFn ??
          () {
            if (isUnsupportedPlatform) {
              throw const NativeAudioRecorderUnsupportedPlatformException(
                _unsupportedAudioRecorderMessage,
              );
            }
            return true;
          },
      listInputDevicesFn:
          listInputDevicesFn ??
          () {
            if (isUnsupportedPlatform) {
              throw const NativeAudioRecorderUnsupportedPlatformException(
                _unsupportedAudioRecorderMessage,
              );
            }
            return const <InputDevice>[];
          },
      startFileFn:
          startFileFn ??
          ({
            required outputPath,
            required sampleRateHz,
            required channelCount,
            required inputDeviceId,
          }) {
            if (isUnsupportedPlatform) {
              throw const NativeAudioRecorderUnsupportedPlatformException(
                _unsupportedAudioRecorderMessage,
              );
            }
          },
      startPcmStreamFn:
          startPcmStreamFn ??
          ({
            required sampleRateHz,
            required channelCount,
            required framesPerChunk,
            required inputDeviceId,
          }) {
            if (isUnsupportedPlatform) {
              throw const NativeAudioRecorderUnsupportedPlatformException(
                _unsupportedAudioRecorderMessage,
              );
            }
          },
      readPcmStreamFn:
          readPcmStreamFn ??
          ({required int maxSamples}) {
            if (isUnsupportedPlatform) {
              throw const NativeAudioRecorderUnsupportedPlatformException(
                _unsupportedAudioRecorderMessage,
              );
            }
            return Uint8List(0);
          },
      setContinousRecordingFn:
          setContinousRecordingFn ??
          ({required enabled, required config}) {
            if (isUnsupportedPlatform) {
              throw const NativeAudioRecorderUnsupportedPlatformException(
                _unsupportedAudioRecorderMessage,
              );
            }
          },
      stopFn:
          stopFn ??
          () {
            if (isUnsupportedPlatform) {
              throw const NativeAudioRecorderUnsupportedPlatformException(
                _unsupportedAudioRecorderMessage,
              );
            }
          },
      resetFn:
          resetFn ??
          () {
            if (isUnsupportedPlatform) {
              throw const NativeAudioRecorderUnsupportedPlatformException(
                _unsupportedAudioRecorderMessage,
              );
            }
          },
      isRecordingFn: isRecordingFn ?? () => false,
      getAmplitudeFn: getAmplitudeFn ?? () => const Amplitude(current: -90.0, max: -90.0),
    ),
  );
}

final class _TestNativeAudioRecorderPlatformImplementation
    extends NativeAudioRecorderPlatformImplementation {
  const _TestNativeAudioRecorderPlatformImplementation({
    required super.platform,
    required super.supportsInputSelection,
    required super.capabilities,
    required this.availabilityFn,
    required this.hasPermissionFn,
    required this.requestPermissionFn,
    required this.listInputDevicesFn,
    required this.startFileFn,
    required this.startPcmStreamFn,
    required this.readPcmStreamFn,
    required this.setContinousRecordingFn,
    required this.stopFn,
    required this.resetFn,
    required this.isRecordingFn,
    required this.getAmplitudeFn,
  });

  final bool Function() availabilityFn;
  final bool Function() hasPermissionFn;
  final FutureOr<bool> Function() requestPermissionFn;
  final List<InputDevice> Function() listInputDevicesFn;
  final StartFileHook startFileFn;
  final StartStreamHook startPcmStreamFn;
  final ReadStreamHook readPcmStreamFn;
  final SetContinousRecordingHook setContinousRecordingFn;
  final FutureOr<void> Function() stopFn;
  final FutureOr<void> Function() resetFn;
  final bool Function() isRecordingFn;
  final Amplitude Function() getAmplitudeFn;

  @override
  bool isAvailable() => availabilityFn();

  @override
  bool hasPermission() => hasPermissionFn();

  @override
  FutureOr<bool> requestPermission() => requestPermissionFn();

  @override
  List<InputDevice> listInputDevices() => listInputDevicesFn();

  @override
  FutureOr<void> startFile({required String outputPath, required AudioRecorderConfig config}) {
    return startFileFn(
      outputPath: outputPath,
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      inputDeviceId: config.inputDeviceId,
    );
  }

  @override
  FutureOr<void> startStream({required AudioRecorderConfig config}) {
    return startPcmStreamFn(
      sampleRateHz: config.sampleRateHz,
      channelCount: config.channelCount,
      framesPerChunk: config.framesPerChunk,
      inputDeviceId: config.inputDeviceId,
    );
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    return readPcmStreamFn(maxSamples: maxSamples);
  }

  @override
  FutureOr<void> setContinousRecording(
    bool enabled, {
    AudioRecorderConfig config = const AudioRecorderConfig(),
  }) {
    return setContinousRecordingFn(enabled: enabled, config: config);
  }

  @override
  FutureOr<void> stop() => stopFn();

  @override
  FutureOr<void> reset() => resetFn();

  @override
  bool isRecording() => isRecordingFn();

  @override
  Amplitude getAmplitude() => getAmplitudeFn();
}
