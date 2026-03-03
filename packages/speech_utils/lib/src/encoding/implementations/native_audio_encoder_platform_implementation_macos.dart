part of 'package:speech_utils/src/encoding/native_audio_encoder.dart';

final class _MacosNativeAudioEncoderPlatformImplementation
    extends NativeAudioEncoderPlatformImplementation {
  const _MacosNativeAudioEncoderPlatformImplementation()
    : super(platform: NativeAudioEncoderPlatform.macOS);

  @override
  bool isAvailable() => _isAppleNativeAacAvailableViaFfi();

  @override
  void encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  }) {
    final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final outputPathPtr = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);

    _encodeAudioFileToAacViaAppleFfi(
      function: apple_bindings.speech_utils_macos_encode_audio_file_to_aac,
      platform: 'macOS',
      inputPathPtr: inputPathPtr,
      outputPathPtr: outputPathPtr,
      bitrateBps: bitrateBps,
      errorPtr: errorPtr,
    );
  }
}
