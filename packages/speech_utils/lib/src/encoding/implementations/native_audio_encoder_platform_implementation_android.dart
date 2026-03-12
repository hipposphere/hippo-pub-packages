part of 'package:speech_utils/src/encoding/native_audio_encoder.dart';

final class _AndroidNativeAudioEncoderPlatformImplementation
    extends NativeAudioEncoderPlatformImplementation {
  static const _asyncPollInterval = Duration(milliseconds: 40);

  const _AndroidNativeAudioEncoderPlatformImplementation()
    : super(platform: NativeAudioEncoderPlatform.android);

  @override
  bool isAvailable() => _isAndroidNativeAacAvailableViaFfi();

  @override
  Future<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  }) async {
    final inputPathPtr = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final outputPathPtr = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final taskHandlePtr = calloc<ffi.Int64>();
    final errorPtr = calloc<ffi.Char>(_nativeErrorBufferBytes);
    int? taskHandle;
    AacEncodingException? pendingError;

    try {
      final code = android_bindings.speech_utils_android_start_async_encode_wav_file_to_aac_m4a(
        inputPathPtr,
        outputPathPtr,
        bitrateBps,
        taskHandlePtr,
        errorPtr,
        _nativeErrorBufferBytes,
      );
      if (code != 0) {
        final stderr = errorPtr.cast<Utf8>().toDartString();
        throw AacEncodingException(
          'android native AAC encoder failed',
          exitCode: code,
          stderr: stderr.isEmpty ? null : stderr,
        );
      }
      taskHandle = taskHandlePtr.value;

      final donePtr = calloc<ffi.Int32>();
      final resultPtr = calloc<ffi.Int32>();
      try {
        while (true) {
          final statusCode = android_bindings
              .speech_utils_android_get_async_encode_wav_file_to_aac_m4a_status(
                taskHandle,
                donePtr,
                resultPtr,
                errorPtr,
                _nativeErrorBufferBytes,
              );
          if (statusCode != 0) {
            final stderr = errorPtr.cast<Utf8>().toDartString();
            throw AacEncodingException(
              'android native AAC encoder status query failed',
              exitCode: statusCode,
              stderr: stderr.isEmpty ? null : stderr,
            );
          }
          if (donePtr.value != 0) {
            final resultCode = resultPtr.value;
            if (resultCode != 0) {
              final stderr = errorPtr.cast<Utf8>().toDartString();
              throw AacEncodingException(
                'android native AAC encoder failed',
                exitCode: resultCode,
                stderr: stderr.isEmpty ? null : stderr,
              );
            }
            break;
          }

          await Future<void>.delayed(_asyncPollInterval);
        }
      } finally {
        calloc.free(donePtr);
        calloc.free(resultPtr);
      }
    } on AacEncodingException catch (error) {
      pendingError = error;
    } finally {
      if (taskHandle != null) {
        final disposeCode = android_bindings
            .speech_utils_android_dispose_async_encode_wav_file_to_aac_m4a(
              taskHandle,
              errorPtr,
              _nativeErrorBufferBytes,
            );
        if (disposeCode != 0 && pendingError == null) {
          final stderr = errorPtr.cast<Utf8>().toDartString();
          pendingError = AacEncodingException(
            'android native AAC encoder cleanup failed',
            exitCode: disposeCode,
            stderr: stderr.isEmpty ? null : stderr,
          );
        }
      }
      calloc.free(inputPathPtr);
      calloc.free(outputPathPtr);
      calloc.free(taskHandlePtr);
      calloc.free(errorPtr);
    }

    if (pendingError != null) {
      throw pendingError;
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
