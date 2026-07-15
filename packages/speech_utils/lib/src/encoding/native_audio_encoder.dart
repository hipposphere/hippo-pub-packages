import 'dart:io';
import 'dart:typed_data';

import 'package:speech_utils_android/speech_utils_android.dart';
import 'package:speech_utils_ios/speech_utils_ios.dart';
import 'package:speech_utils_linux/speech_utils_linux.dart';
import 'package:speech_utils_macos/speech_utils_macos.dart';
import 'package:speech_utils_platform_interface/speech_utils_platform_interface.dart';
import 'package:speech_utils_windows/speech_utils_windows.dart';

import '../utils/pcm16_audio_utils.dart';

part 'errors/native_audio_encoder_exceptions.dart';
part 'native_audio_encoder_platform_implementations.dart';

const _unsupportedNativeAudioEncoderMessage =
    'NativeAudioEncoder is currently supported on macOS (AVFoundation), '
    'Windows/Linux (FFmpeg/libavcodec), Android (NDK MediaCodec), and '
    'iOS (AVFoundation).';

/// AAC encoder that uses native platform tooling:
/// - macOS: bundled native AVFoundation bridge via Dart FFI
/// - Windows: bundled native FFmpeg/libavcodec bridge via Dart FFI
/// - Linux: bundled native FFmpeg/libavcodec bridge via Dart FFI
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
  NativeAudioEncoder.custom({required NativeAacEncoderBackend platformImplementation})
    : this._(platformImplementation: platformImplementation);

  NativeAudioEncoder._({required this._platformImplementation});

  final NativeAacEncoderBackend _platformImplementation;

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
    _ensureEncoderSupported(_platformImplementation);
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
    _ensureEncoderSupported(_platformImplementation);
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
    _ensureEncoderSupported(_platformImplementation);
    if (bitrateKbps <= 0) {
      throw ArgumentError.value(bitrateKbps, 'bitrateKbps', 'Must be > 0');
    }
    if (await _pathsReferToSameFile(inputPath, outputPath)) {
      throw ArgumentError.value(outputPath, 'outputPath', 'Must not refer to the input file');
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
        'Failed to execute ${_platformImplementation.platformLabel} native AAC encoder: $error',
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

Future<bool> _pathsReferToSameFile(String firstPath, String secondPath) async {
  final firstAbsolute = File(firstPath).absolute.path;
  final secondAbsolute = File(secondPath).absolute.path;
  if (firstAbsolute == secondAbsolute) {
    return true;
  }
  try {
    if (!await File(firstAbsolute).exists() || !await File(secondAbsolute).exists()) {
      return false;
    }
    return await FileSystemEntity.identical(firstAbsolute, secondAbsolute);
  } on FileSystemException {
    return false;
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
