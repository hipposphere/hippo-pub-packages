import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'aac_encoder.dart';
import '../generated/audio_encoder/android_audio_encoder_bindings.dart' as android_bindings;
import '../generated/audio_encoder/apple_audio_encoder_bindings.dart' as apple_bindings;
import '../generated/audio_encoder/windows_audio_encoder_bindings.dart' as windows_bindings;
import '../utils/pcm16_audio_utils.dart';

part 'errors/native_audio_encoder_exceptions.dart';
part 'native_audio_encoder_platform_implementations.dart';
part 'implementations/native_audio_encoder_platform_implementation_android.dart';
part 'implementations/native_audio_encoder_platform_implementation_ios.dart';
part 'implementations/native_audio_encoder_platform_implementation_macos.dart';
part 'implementations/native_audio_encoder_platform_implementation_windows.dart';

const _unsupportedNativeAudioEncoderMessage =
    'NativeAudioEncoder is currently supported on macOS (AVFoundation), '
    'Windows (FFmpeg/libavcodec), Android (NDK MediaCodec), and '
    'iOS (AVFoundation).';

/// AAC encoder that uses native platform tooling:
/// - macOS: bundled native AVFoundation bridge via Dart FFI
/// - Windows: bundled native FFmpeg/libavcodec bridge via Dart FFI
/// - Android: bundled native NDK bridge via Dart FFI (PCM16 WAV input path)
/// - iOS: bundled native AVFoundation bridge via Dart FFI
///
/// This encoder does not depend on an external `ffmpeg` command-line binary.
final class NativeAudioEncoder implements AacEncoder {
  /// Uses platform detection to select the default backend.
  NativeAudioEncoder()
    : this._(
        platformImplementation: _resolveNativeAudioEncoderPlatformImplementation(
          platform: _detectNativeAudioEncoderPlatform(),
          platformImplementation: null,
        ),
      );

  /// Uses a custom platform backend.
  NativeAudioEncoder.custom({
    required NativeAudioEncoderPlatformImplementation platformImplementation,
  }) : this._(platformImplementation: platformImplementation);

  NativeAudioEncoder._({required NativeAudioEncoderPlatformImplementation platformImplementation})
    : _platformImplementation = platformImplementation;

  final NativeAudioEncoderPlatformImplementation _platformImplementation;

  Future<bool> isAvailable() async {
    try {
      return _platformImplementation.isAvailable();
    } on Object {
      return false;
    }
  }

  @override
  Future<void> encodePcm16BytesToAac({
    required Uint8List pcm16leBytes,
    required int sampleRateHz,
    required int channelCount,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    _platformImplementation.ensureSupported();
    _validatePcmParams(sampleRateHz: sampleRateHz, channelCount: channelCount);
    if (pcm16leBytes.isEmpty) {
      throw ArgumentError.value(pcm16leBytes, 'pcm16leBytes', 'Cannot be empty');
    }
    if (pcm16leBytes.length.isOdd) {
      throw ArgumentError.value(
        pcm16leBytes.length,
        'pcm16leBytes',
        'PCM16 byte length must be even',
      );
    }

    await _withTempDirectory((tempDir) async {
      final wavPath = '${tempDir.path}${Platform.pathSeparator}input.wav';
      await _writePcm16BytesAsWav(
        pcm16leBytes: pcm16leBytes,
        sampleRateHz: sampleRateHz,
        channelCount: channelCount,
        wavOutputPath: wavPath,
      );
      await encodeAudioFileToAac(
        inputPath: wavPath,
        outputPath: outputPath,
        bitrateKbps: bitrateKbps,
      );
    });
  }

  @override
  Future<void> encodePcm16FileToAac({
    required String inputPath,
    required int sampleRateHz,
    required int channelCount,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    _platformImplementation.ensureSupported();
    _validatePcmParams(sampleRateHz: sampleRateHz, channelCount: channelCount);

    final inputFile = File(inputPath);
    final inputLength = await inputFile.length();
    if (inputLength <= 0) {
      throw ArgumentError.value(inputPath, 'inputPath', 'PCM file cannot be empty');
    }
    if (inputLength.isOdd) {
      throw ArgumentError.value(inputPath, 'inputPath', 'PCM16 file length must be even');
    }

    await _withTempDirectory((tempDir) async {
      final wavPath = '${tempDir.path}${Platform.pathSeparator}input.wav';
      await _writePcm16FileAsWav(
        inputFile: inputFile,
        inputPcmByteLength: inputLength,
        sampleRateHz: sampleRateHz,
        channelCount: channelCount,
        wavOutputPath: wavPath,
      );
      await encodeAudioFileToAac(
        inputPath: wavPath,
        outputPath: outputPath,
        bitrateKbps: bitrateKbps,
      );
    });
  }

  @override
  Future<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    _platformImplementation.ensureSupported();
    if (bitrateKbps <= 0) {
      throw ArgumentError.value(bitrateKbps, 'bitrateKbps', 'Must be > 0');
    }

    final outputFile = File(outputPath);
    if (await outputFile.exists()) {
      await outputFile.delete();
    }

    try {
      await _platformImplementation.encodeAudioFileToAac(
        inputPath: inputPath,
        outputPath: outputPath,
        bitrateBps: bitrateKbps * 1000,
      );
    } on AacEncodingException {
      rethrow;
    } on Object catch (error) {
      throw AacEncodingException(
        'Failed to execute ${_platformImplementation.platform.label} native AAC encoder: $error',
      );
    }
  }

  void _validatePcmParams({required int sampleRateHz, required int channelCount}) {
    if (sampleRateHz <= 0) {
      throw ArgumentError.value(sampleRateHz, 'sampleRateHz', 'Must be > 0');
    }
    if (channelCount <= 0) {
      throw ArgumentError.value(channelCount, 'channelCount', 'Must be > 0');
    }
  }

  Future<void> _withTempDirectory(Future<void> Function(Directory tempDir) action) async {
    final tempDir = await Directory.systemTemp.createTemp('speech_utils_aac_');
    try {
      await action(tempDir);
    } finally {
      try {
        await tempDir.delete(recursive: true);
      } on Object {
        // Best-effort cleanup.
      }
    }
  }
}

Future<void> _writePcm16BytesAsWav({
  required Uint8List pcm16leBytes,
  required int sampleRateHz,
  required int channelCount,
  required String wavOutputPath,
}) async {
  final output = File(wavOutputPath);
  final sink = output.openWrite();
  sink.add(
    Pcm16AudioUtils.buildPcm16WavHeader(
      sampleRateHz: sampleRateHz,
      channelCount: channelCount,
      pcmDataByteLength: pcm16leBytes.length,
    ),
  );
  sink.add(pcm16leBytes);
  await sink.close();
}

Future<void> _writePcm16FileAsWav({
  required File inputFile,
  required int inputPcmByteLength,
  required int sampleRateHz,
  required int channelCount,
  required String wavOutputPath,
}) async {
  final output = File(wavOutputPath);
  final sink = output.openWrite();
  sink.add(
    Pcm16AudioUtils.buildPcm16WavHeader(
      sampleRateHz: sampleRateHz,
      channelCount: channelCount,
      pcmDataByteLength: inputPcmByteLength,
    ),
  );
  await sink.addStream(inputFile.openRead());
  await sink.close();
}

const _nativeErrorBufferBytes = 4096;

bool _isAppleNativeAacAvailableViaFfi() {
  return true;
}

typedef _AppleAacEncoderFfi =
    int Function(
      ffi.Pointer<ffi.Char> inputPathUtf8,
      ffi.Pointer<ffi.Char> outputPathUtf8,
      int bitrateBps,
      ffi.Pointer<ffi.Char> errorUtf8,
      int errorUtf8Capacity,
    );

void _encodeAudioFileToAacViaAppleFfi({
  required _AppleAacEncoderFfi function,
  required String platform,
  required ffi.Pointer<ffi.Char> inputPathPtr,
  required ffi.Pointer<ffi.Char> outputPathPtr,
  required int bitrateBps,
  required ffi.Pointer<ffi.Char> errorPtr,
}) {
  try {
    final code = function(
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
      '$platform native AAC encoder failed',
      exitCode: code,
      stderr: stderr.isEmpty ? null : stderr,
    );
  } finally {
    calloc.free(inputPathPtr);
    calloc.free(outputPathPtr);
    calloc.free(errorPtr);
  }
}
