part of 'package:speech_utils/src/encoding/native_audio_encoder.dart';

final class _LinuxNativeAudioEncoderPlatformImplementation
    extends NativeAudioEncoderPlatformImplementation {
  const _LinuxNativeAudioEncoderPlatformImplementation()
    : super(platform: NativeAudioEncoderPlatform.linux);

  @override
  bool isAvailable() => _isLinuxNativeAacAvailableViaFfi();

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
      final hr = linux_bindings.speech_utils_linux_encode_audio_file_to_aac(
        inputPathPtr,
        outputPathPtr,
        bitrateBps,
        errorPtr,
        _nativeErrorBufferBytes,
      );
      if (hr != 0) {
        final stderr = errorPtr.cast<Utf8>().toDartString();
        throw AacEncodingException(
          'linux native AAC encoder failed',
          exitCode: hr,
          stderr: stderr.isEmpty ? null : stderr,
        );
      }
    } finally {
      calloc.free(inputPathPtr);
      calloc.free(outputPathPtr);
      calloc.free(errorPtr);
    }
  }
}

bool _isLinuxNativeAacAvailableViaFfi() {
  final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);
  try {
    try {
      final hr = linux_bindings.speech_utils_linux_aac_encoder_healthcheck(
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
