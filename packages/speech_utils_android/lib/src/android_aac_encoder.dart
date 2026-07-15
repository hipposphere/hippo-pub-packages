import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_metadata_ffi.dart';

import 'generated/android_audio_encoder_bindings.dart' as bindings;

const _errorBufferBytes = 4096;

final class AndroidAacEncoderBackend implements NativeAacEncoderBackend {
  const AndroidAacEncoderBackend();

  static const _pollInterval = Duration(milliseconds: 40);

  @override
  String get platformLabel => 'Android';

  @override
  bool isAvailable() {
    final error = calloc<ffi.Char>(_errorBufferBytes);
    try {
      try {
        return bindings.speech_utils_android_aac_encoder_healthcheck(
              error,
              _errorBufferBytes,
            ) ==
            0;
      } on Object {
        return false;
      }
    } finally {
      calloc.free(error);
    }
  }

  @override
  Future<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  }) async {
    final input = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final output = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
    final task = calloc<ffi.Int64>();
    final error = calloc<ffi.Char>(_errorBufferBytes);
    int? handle;
    AacEncodingException? pendingError;
    try {
      final code = bindings
          .speech_utils_android_start_async_encode_wav_file_to_aac_m4a(
            input,
            output,
            bitrateBps,
            task,
            error,
            _errorBufferBytes,
          );
      if (code != 0) {
        throw _failure('Android native AAC encoder failed', code, error);
      }
      handle = task.value;
      final done = calloc<ffi.Int32>();
      final result = calloc<ffi.Int32>();
      try {
        while (true) {
          final status = bindings
              .speech_utils_android_get_async_encode_wav_file_to_aac_m4a_status(
                handle,
                done,
                result,
                error,
                _errorBufferBytes,
              );
          if (status != 0) {
            throw _failure('Android AAC status query failed', status, error);
          }
          if (done.value != 0) {
            if (result.value != 0) {
              throw _failure(
                'Android native AAC encoder failed',
                result.value,
                error,
              );
            }
            break;
          }
          await Future<void>.delayed(_pollInterval);
        }
      } finally {
        calloc.free(done);
        calloc.free(result);
      }
    } on AacEncodingException catch (exception) {
      pendingError = exception;
    } finally {
      if (handle != null) {
        final dispose = bindings
            .speech_utils_android_dispose_async_encode_wav_file_to_aac_m4a(
              handle,
              error,
              _errorBufferBytes,
            );
        if (dispose != 0 && pendingError == null) {
          pendingError = _failure(
            'Android AAC encoder cleanup failed',
            dispose,
            error,
          );
        }
      }
      calloc.free(input);
      calloc.free(output);
      calloc.free(task);
      calloc.free(error);
    }
    if (pendingError != null) throw pendingError;
  }
}

final class AndroidAudioMetadataBackend implements NativeAudioMetadataBackend {
  const AndroidAudioMetadataBackend();

  static final _worker = NativeWorkerExecutor(
    entrypoint: _androidMetadataWorkerMain,
    debugName: 'speech_utils Android metadata',
  );

  @override
  bool isAvailable() => runMetadataHealthcheck(
    bindings.speech_utils_android_audio_metadata_healthcheck,
  );

  @override
  Future<AudioMetadata> readAudioMetadata({required String inputPath}) =>
      _worker.execute<AudioMetadata>(inputPath);
}

void _androidMetadataWorkerMain(SendPort replyPort) {
  runNativeWorker(
    replyPort,
    (raw) => runMetadataRead(
      bindings.speech_utils_android_read_audio_metadata,
      inputPath: raw! as String,
    ),
  );
}

AacEncodingException _failure(
  String message,
  int code,
  ffi.Pointer<ffi.Char> error,
) {
  final details = error.cast<Utf8>().toDartString();
  return AacEncodingException(
    message,
    exitCode: code,
    stderr: details.isEmpty ? null : details,
  );
}
