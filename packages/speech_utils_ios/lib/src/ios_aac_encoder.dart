import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_metadata_ffi.dart';

import 'generated/apple_audio_codec_bindings.dart' as bindings;
import 'generated/apple_audio_metadata_bindings.dart' as metadata_bindings;

const _errorBufferBytes = 4096;

final class IosAacEncoderBackend implements NativeAacEncoderBackend {
  const IosAacEncoderBackend();

  static final _worker = NativeWorkerExecutor(
    entrypoint: _iosAacWorkerMain,
    debugName: 'speech_utils iOS AAC',
  );

  @override
  String get platformLabel => 'iOS';

  @override
  bool isAvailable() => true;

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

final class IosAudioMetadataBackend implements NativeAudioMetadataBackend {
  const IosAudioMetadataBackend();

  static final _worker = NativeWorkerExecutor(
    entrypoint: _iosMetadataWorkerMain,
    debugName: 'speech_utils iOS metadata',
  );

  @override
  bool isAvailable() => true;

  @override
  Future<AudioMetadata> readAudioMetadata({required String inputPath}) =>
      _worker.execute<AudioMetadata>(inputPath);
}

void _iosMetadataWorkerMain(SendPort replyPort) {
  runNativeWorker(
    replyPort,
    (raw) => runMetadataRead(
      metadata_bindings.speech_utils_ios_read_audio_metadata,
      inputPath: raw! as String,
    ),
  );
}

void _iosAacWorkerMain(SendPort replyPort) {
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

void _encode({
  required String inputPath,
  required String outputPath,
  required int bitrateBps,
}) {
  final input = inputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final output = outputPath.toNativeUtf8(allocator: calloc).cast<ffi.Char>();
  final error = calloc<ffi.Char>(_errorBufferBytes);
  try {
    final code = bindings.speech_utils_ios_encode_audio_file_to_aac(
      input,
      output,
      bitrateBps,
      error,
      _errorBufferBytes,
    );
    if (code != 0) {
      final details = error.cast<Utf8>().toDartString();
      throw AacEncodingException(
        'iOS native AAC encoder failed',
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
