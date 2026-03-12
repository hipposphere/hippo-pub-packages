part of 'native_audio_encoder.dart';

enum NativeAudioEncoderPlatform { macOS, windows, android, iOS, unsupported }

NativeAudioEncoderPlatform _detectNativeAudioEncoderPlatform() {
  if (Platform.isMacOS) {
    return NativeAudioEncoderPlatform.macOS;
  }
  if (Platform.isWindows) {
    return NativeAudioEncoderPlatform.windows;
  }
  if (Platform.isAndroid) {
    return NativeAudioEncoderPlatform.android;
  }
  if (Platform.isIOS) {
    return NativeAudioEncoderPlatform.iOS;
  }
  return NativeAudioEncoderPlatform.unsupported;
}

NativeAudioEncoderPlatformImplementation _resolveNativeAudioEncoderPlatformImplementation({
  required NativeAudioEncoderPlatform platform,
  NativeAudioEncoderPlatformImplementation? platformImplementation,
}) {
  if (platformImplementation != null) {
    return platformImplementation;
  }
  return switch (platform) {
    NativeAudioEncoderPlatform.macOS => const _MacosNativeAudioEncoderPlatformImplementation(),
    NativeAudioEncoderPlatform.windows => const _WindowsNativeAudioEncoderPlatformImplementation(),
    NativeAudioEncoderPlatform.android => const _AndroidNativeAudioEncoderPlatformImplementation(),
    NativeAudioEncoderPlatform.iOS => const _IosNativeAudioEncoderPlatformImplementation(),
    NativeAudioEncoderPlatform.unsupported =>
      const _UnsupportedNativeAudioEncoderPlatformImplementation(),
  };
}

abstract class NativeAudioEncoderPlatformImplementation {
  const NativeAudioEncoderPlatformImplementation({required this.platform});

  final NativeAudioEncoderPlatform platform;

  bool isAvailable();

  FutureOr<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  });

  void ensureSupported() {
    if (platform == NativeAudioEncoderPlatform.unsupported) {
      throw const NativeAudioEncoderUnsupportedPlatformException(
        _unsupportedNativeAudioEncoderMessage,
      );
    }
  }
}

final class _UnsupportedNativeAudioEncoderPlatformImplementation
    extends NativeAudioEncoderPlatformImplementation {
  const _UnsupportedNativeAudioEncoderPlatformImplementation()
    : super(platform: NativeAudioEncoderPlatform.unsupported);

  @override
  bool isAvailable() => false;

  @override
  FutureOr<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  }) {
    throw const NativeAudioEncoderUnsupportedPlatformException(
      _unsupportedNativeAudioEncoderMessage,
    );
  }
}

extension on NativeAudioEncoderPlatform {
  String get label {
    return switch (this) {
      NativeAudioEncoderPlatform.macOS => 'macOS',
      NativeAudioEncoderPlatform.windows => 'Windows',
      NativeAudioEncoderPlatform.android => 'Android',
      NativeAudioEncoderPlatform.iOS => 'iOS',
      NativeAudioEncoderPlatform.unsupported => 'unsupported platform',
    };
  }
}
