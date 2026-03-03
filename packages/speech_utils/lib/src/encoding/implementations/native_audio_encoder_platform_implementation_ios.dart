part of 'package:speech_utils/src/encoding/native_audio_encoder.dart';

final class _IosNativeAudioEncoderPlatformImplementation
    extends NativeAudioEncoderPlatformImplementation {
  const _IosNativeAudioEncoderPlatformImplementation()
    : super(platform: NativeAudioEncoderPlatform.iOS);

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
      function: apple_bindings.speech_utils_ios_encode_audio_file_to_aac,
      platform: 'iOS',
      inputPathPtr: inputPathPtr,
      outputPathPtr: outputPathPtr,
      bitrateBps: bitrateBps,
      errorPtr: errorPtr,
    );
  }
}
