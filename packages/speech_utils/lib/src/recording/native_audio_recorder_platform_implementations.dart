part of 'native_audio_recorder.dart';

const _unsupportedAudioRecorderMessage =
    'NativeAudioRecorder is currently supported on macOS, Windows, and iOS.';

NativeAudioRecorderPlatform _detectNativeAudioRecorderPlatform() {
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
    NativeAudioRecorderPlatform.macOS => const _MacosNativeAudioRecorderPlatformImplementation(),
    NativeAudioRecorderPlatform.windows => const _WindowsNativeAudioRecorderPlatformImplementation(),
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
  bool requestPermission();
  List<InputDevice> listInputDevices();
  void startFile({required String outputPath, required AudioRecorderConfig config});
  void startStream({required AudioRecorderConfig config});
  Uint8List readStream({required int maxSamples});
  void stop();
  void reset();
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
  bool requestPermission() {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  List<InputDevice> listInputDevices() {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  void startFile({required String outputPath, required AudioRecorderConfig config}) {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  void startStream({required AudioRecorderConfig config}) {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  void stop() {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  void reset() {
    throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
  }

  @override
  bool isRecording() => false;

  @override
  Amplitude getAmplitude() => const Amplitude(current: -90.0, max: -90.0);
}
