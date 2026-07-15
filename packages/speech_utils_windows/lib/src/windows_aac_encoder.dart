import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_metadata_ffi.dart';

import 'generated/windows_audio_encoder_bindings.dart' as bindings;

const _errorBufferBytes = 4096;

final class WindowsAacEncoderBackend implements NativeAacEncoderBackend {
  const WindowsAacEncoderBackend();

  static final _worker = NativeWorkerExecutor(
    entrypoint: _windowsAacWorkerMain,
    debugName: 'speech_utils Windows AAC',
  );

  @override
  String get platformLabel => 'Windows';

  @override
  bool isAvailable() => _healthcheck();

  @override
  Future<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  }) => _worker.execute<void>({
    'inputPath': inputPath,
    'outputPath': outputPath,
    'bitrateBps': bitrateBps,
  });
}

final class WindowsAudioMetadataBackend implements NativeAudioMetadataBackend {
  const WindowsAudioMetadataBackend();

  static final _worker = NativeWorkerExecutor(
    entrypoint: _windowsMetadataWorkerMain,
    debugName: 'speech_utils Windows metadata',
  );

  @override
  bool isAvailable() => runMetadataHealthcheck(
    bindings.speech_utils_windows_audio_metadata_healthcheck,
  );

  @override
  Future<AudioMetadata> readAudioMetadata({required String inputPath}) =>
      _worker.execute<AudioMetadata>(inputPath);
}

void _windowsMetadataWorkerMain(SendPort replyPort) {
  runNativeWorker(
    replyPort,
    (raw) => runMetadataRead(
      bindings.speech_utils_windows_read_audio_metadata,
      inputPath: raw! as String,
    ),
  );
}

void _windowsAacWorkerMain(SendPort replyPort) {
  runNativeWorker(replyPort, (raw) {
    final request = (raw! as Map<Object?, Object?>).cast<String, Object?>();
    _encode(
      inputPath: request['inputPath']! as String,
      outputPath: request['outputPath']! as String,
      bitrateBps: request['bitrateBps']! as int,
    );
    return null;
  });
}

bool _healthcheck() {
  final error = calloc<ffi.Char>(_errorBufferBytes);
  try {
    try {
      return bindings.speech_utils_windows_aac_encoder_healthcheck(
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

void _encode({
  required String inputPath,
  required String outputPath,
  required int bitrateBps,
}) {
  final input = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final output = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final error = calloc<ffi.Char>(_errorBufferBytes);
  try {
    final code = bindings.speech_utils_windows_encode_audio_file_to_aac(
      input,
      output,
      bitrateBps,
      error,
      _errorBufferBytes,
    );
    if (code != 0) {
      final details = error.cast<Utf8>().toDartString();
      throw AacEncodingException(
        'Windows native AAC encoder failed',
        exitCode: code,
        stderr: details.isEmpty ? null : details,
      );
    }
  } finally {
    calloc.free(input);
    calloc.free(output);
    calloc.free(error);
  }
}
