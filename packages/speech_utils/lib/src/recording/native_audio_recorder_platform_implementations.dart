part of 'native_audio_recorder.dart';

const _unsupportedAudioRecorderMessage =
    'NativeAudioRecorder is currently supported on Android, macOS, Windows, Linux, and iOS.';

/// Compatibility injection seam. Production implementations now live only in
/// the endorsed platform packages and implement [SpeechUtilsPlatform]
/// directly.
abstract class NativeAudioRecorderPlatformImplementation extends SpeechUtilsPlatform {
  const NativeAudioRecorderPlatformImplementation({
    required super.platform,
    required super.supportsInputSelection,
    required super.capabilities,
  });

  void ensureSupported() {
    if (platform == NativeAudioRecorderPlatform.unsupported) {
      throw NativeAudioRecorderUnsupportedPlatformException(_unsupportedAudioRecorderMessage);
    }
  }
}

NativeAudioRecorderPlatform _detectNativeAudioRecorderPlatform() {
  if (Platform.isAndroid) return NativeAudioRecorderPlatform.android;
  if (Platform.isMacOS) return NativeAudioRecorderPlatform.macOS;
  if (Platform.isWindows) return NativeAudioRecorderPlatform.windows;
  if (Platform.isLinux) return NativeAudioRecorderPlatform.linux;
  if (Platform.isIOS) return NativeAudioRecorderPlatform.iOS;
  return NativeAudioRecorderPlatform.unsupported;
}

SpeechUtilsPlatform _resolveNativeAudioRecorderPlatformImplementation({
  required NativeAudioRecorderPlatform platform,
  SpeechUtilsPlatform? platformImplementation,
}) {
  if (platformImplementation != null) {
    return platformImplementation;
  }
  final registered = SpeechUtilsPlatform.instance;
  if (registered.platform == platform) {
    return registered;
  }
  return switch (platform) {
    NativeAudioRecorderPlatform.android => const SpeechUtilsAndroid(),
    NativeAudioRecorderPlatform.macOS => SpeechUtilsMacos(),
    NativeAudioRecorderPlatform.windows => SpeechUtilsWindows(),
    NativeAudioRecorderPlatform.linux => SpeechUtilsLinux(),
    NativeAudioRecorderPlatform.iOS => const SpeechUtilsIos(),
    NativeAudioRecorderPlatform.web ||
    NativeAudioRecorderPlatform.unsupported => const UnsupportedSpeechUtilsPlatform(),
  };
}
