part of 'native_audio_recorder.dart';

const _unsupportedAudioRecorderMessage =
    'NativeAudioRecorder is currently supported on Android, macOS, Windows, and iOS.';

NativeAudioRecorderPlatform _detectNativeAudioRecorderPlatform() {
  if (Platform.isAndroid) {
    return NativeAudioRecorderPlatform.android;
  }
  if (Platform.isMacOS) {
    return NativeAudioRecorderPlatform.macOS;
  }
  if (Platform.isWindows) {
    return NativeAudioRecorderPlatform.windows;
  }
  if (Platform.isIOS) {
    return NativeAudioRecorderPlatform.iOS;
  }
  return NativeAudioRecorderPlatform.unsupported;
}

NativeAudioRecorderPlatformImplementation _resolveNativeAudioRecorderPlatformImplementation({
  required NativeAudioRecorderPlatform platform,
  NativeAudioRecorderPlatformImplementation? platformImplementation,
}) {
  if (platformImplementation != null) {
    return platformImplementation;
  }
  return switch (platform) {
    NativeAudioRecorderPlatform.android =>
      const _AndroidNativeAudioRecorderPlatformImplementation(),
    NativeAudioRecorderPlatform.macOS => const _MacosNativeAudioRecorderPlatformImplementation(),
    NativeAudioRecorderPlatform.windows =>
      const _WindowsNativeAudioRecorderPlatformImplementation(),
    NativeAudioRecorderPlatform.iOS => const _IosNativeAudioRecorderPlatformImplementation(),
    NativeAudioRecorderPlatform.unsupported =>
      const _UnsupportedNativeAudioRecorderPlatformImplementation(),
  };
}

abstract class NativeAudioRecorderPlatformImplementation {
  const NativeAudioRecorderPlatformImplementation({
    required this.platform,
    required this.supportsInputSelection,
    required this.capabilities,
  });

  final NativeAudioRecorderPlatform platform;
  final bool supportsInputSelection;
  final NativeAudioRecorderCapabilities capabilities;

  bool isAvailable();
  bool hasPermission();
  FutureOr<bool> requestPermission();
  List<InputDevice> listInputDevices();
  FutureOr<void> startFile({required String outputPath, required AudioRecorderConfig config});
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

  void ensureSupported() {
    if (platform == NativeAudioRecorderPlatform.unsupported) {
      throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
    }
  }
}

final class _UnsupportedNativeAudioRecorderPlatformImplementation
    extends NativeAudioRecorderPlatformImplementation {
  const _UnsupportedNativeAudioRecorderPlatformImplementation()
    : super(
        platform: NativeAudioRecorderPlatform.unsupported,
        supportsInputSelection: false,
        capabilities: const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: false,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: false,
        ),
      );

  @override
  bool isAvailable() => false;

  @override
  bool hasPermission() {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  FutureOr<bool> requestPermission() {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  List<InputDevice> listInputDevices() {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  FutureOr<void> startFile({required String outputPath, required AudioRecorderConfig config}) {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  FutureOr<void> startStream({required AudioRecorderConfig config}) {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  FutureOr<void> stop() {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  FutureOr<void> reset() {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  bool isRecording() => false;

  @override
  Amplitude getAmplitude() => const Amplitude(current: -90.0, max: -90.0);
}
