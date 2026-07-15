part of 'native_audio_encoder.dart';

enum NativeAudioEncoderPlatform { macOS, windows, linux, android, iOS, unsupported }

NativeAudioEncoderPlatform _detectNativeAudioEncoderPlatform() {
  if (Platform.isMacOS) return NativeAudioEncoderPlatform.macOS;
  if (Platform.isWindows) return NativeAudioEncoderPlatform.windows;
  if (Platform.isLinux) return NativeAudioEncoderPlatform.linux;
  if (Platform.isAndroid) return NativeAudioEncoderPlatform.android;
  if (Platform.isIOS) return NativeAudioEncoderPlatform.iOS;
  return NativeAudioEncoderPlatform.unsupported;
}

NativeAacEncoderBackend _resolveNativeAudioEncoderPlatformImplementation({
  required NativeAudioEncoderPlatform platform,
  NativeAacEncoderBackend? platformImplementation,
}) {
  if (platformImplementation != null) return platformImplementation;
  return switch (platform) {
    NativeAudioEncoderPlatform.macOS => SpeechUtilsMacos().aacEncoder,
    NativeAudioEncoderPlatform.windows => SpeechUtilsWindows().aacEncoder,
    NativeAudioEncoderPlatform.linux => SpeechUtilsLinux().aacEncoder,
    NativeAudioEncoderPlatform.android => const SpeechUtilsAndroid().aacEncoder,
    NativeAudioEncoderPlatform.iOS => const SpeechUtilsIos().aacEncoder,
    NativeAudioEncoderPlatform.unsupported => const _UnsupportedNativeAacEncoderBackend(),
  };
}

/// Compatibility seam for tests and applications that injected a custom
/// encoder before codec ownership moved to the federated platform packages.
abstract class NativeAudioEncoderPlatformImplementation implements NativeAacEncoderBackend {
  const NativeAudioEncoderPlatformImplementation({required this.platform});

  final NativeAudioEncoderPlatform platform;

  @override
  String get platformLabel => platform.label;

  void ensureSupported() {
    if (platform == NativeAudioEncoderPlatform.unsupported) {
      throw const NativeAudioEncoderUnsupportedPlatformException(
        _unsupportedNativeAudioEncoderMessage,
      );
    }
  }
}

final class _UnsupportedNativeAacEncoderBackend implements NativeAacEncoderBackend {
  const _UnsupportedNativeAacEncoderBackend();

  @override
  String get platformLabel => 'unsupported platform';

  @override
  bool isAvailable() => false;

  @override
  Never encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  }) => throw const NativeAudioEncoderUnsupportedPlatformException(
    _unsupportedNativeAudioEncoderMessage,
  );
}

void _ensureEncoderSupported(NativeAacEncoderBackend backend) {
  if (backend is _UnsupportedNativeAacEncoderBackend) {
    throw const NativeAudioEncoderUnsupportedPlatformException(
      _unsupportedNativeAudioEncoderMessage,
    );
  }
  if (backend is NativeAudioEncoderPlatformImplementation) {
    backend.ensureSupported();
  }
}

extension on NativeAudioEncoderPlatform {
  String get label => switch (this) {
    NativeAudioEncoderPlatform.macOS => 'macOS',
    NativeAudioEncoderPlatform.windows => 'Windows',
    NativeAudioEncoderPlatform.linux => 'Linux',
    NativeAudioEncoderPlatform.android => 'Android',
    NativeAudioEncoderPlatform.iOS => 'iOS',
    NativeAudioEncoderPlatform.unsupported => 'unsupported platform',
  };
}
