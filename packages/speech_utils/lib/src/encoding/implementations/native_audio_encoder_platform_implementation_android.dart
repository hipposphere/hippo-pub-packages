part of 'package:speech_utils/src/encoding/native_audio_encoder.dart';

final class _AndroidNativeAudioEncoderPlatformImplementation
    extends NativeAudioEncoderPlatformImplementation {
  const _AndroidNativeAudioEncoderPlatformImplementation()
    : super(platform: NativeAudioEncoderPlatform.android);

  @override
  bool isAvailable() => _isAndroidNativeAacAvailableViaFfi();

  @override
  void encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  }) {
    final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final outputPathPtr = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);

    try {
      final code = android_bindings.speech_utils_android_encode_wav_file_to_aac_m4a(
        inputPathPtr,
        outputPathPtr,
        bitrateBps,
        errorPtr,
        _nativeErrorBufferBytes,
      );
      if (code == 0) {
        return;
      }

      final stderr = errorPtr.cast<Utf8>().toDartString();
      throw AacEncodingException(
        'android native AAC encoder failed',
        exitCode: code,
        stderr: stderr.isEmpty ? null : stderr,
      );
    } finally {
      calloc.free(inputPathPtr);
      calloc.free(outputPathPtr);
      calloc.free(errorPtr);
    }
  }
}

bool _isAndroidNativeAacAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);
  try {
    try {
      final code = android_bindings.speech_utils_android_aac_encoder_healthcheck(
        errorPtr,
        _nativeErrorBufferBytes,
      );
      return code == 0;
    } on Object {
      return false;
    }
  } finally {
    calloc.free(errorPtr);
  }
}
