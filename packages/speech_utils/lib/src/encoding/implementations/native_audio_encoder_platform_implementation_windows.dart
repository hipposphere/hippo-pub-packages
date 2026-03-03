part of 'package:speech_utils/src/encoding/native_audio_encoder.dart';

final class _WindowsNativeAudioEncoderPlatformImplementation
    extends NativeAudioEncoderPlatformImplementation {
  const _WindowsNativeAudioEncoderPlatformImplementation()
    : super(platform: NativeAudioEncoderPlatform.windows);

  @override
  bool isAvailable() => _isWindowsNativeAacAvailableViaFfi();

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
      final hr = windows_bindings.speech_utils_windows_encode_audio_file_to_aac(
        inputPathPtr,
        outputPathPtr,
        bitrateBps,
        errorPtr,
        _nativeErrorBufferBytes,
      );
      if (hr == 0) {
        return;
      }

      final stderr = errorPtr.cast<Utf8>().toDartString();
      throw AacEncodingException(
        'windows native AAC encoder failed',
        exitCode: hr,
        stderr: stderr.isEmpty ? null : stderr,
      );
    } finally {
      calloc.free(inputPathPtr);
      calloc.free(outputPathPtr);
      calloc.free(errorPtr);
    }
  }
}

bool _isWindowsNativeAacAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);
  try {
    try {
      final hr = windows_bindings.speech_utils_windows_aac_encoder_healthcheck(
        errorPtr,
        _nativeErrorBufferBytes,
      );
      return hr == 0;
    } on Object {
      return false;
    }
  } finally {
    calloc.free(errorPtr);
  }
}
