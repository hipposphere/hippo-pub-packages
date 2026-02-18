import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'aac_encoder.dart';

typedef FfmpegCommandRunner =
    Future<FfmpegCommandResult> Function(
      String executable,
      List<String> arguments, {
      Uint8List? stdinBytes,
    });

final class FfmpegCommandResult {
  const FfmpegCommandResult({required this.exitCode, required this.stderr});

  final int exitCode;
  final String stderr;
}

/// AAC encoder implementation backed by an `ffmpeg` binary.
///
/// This is platform-portable for macOS and Windows as long as ffmpeg is
/// installed and discoverable.
final class FfmpegAacEncoder implements AacEncoder {
  FfmpegAacEncoder({this.ffmpegExecutable = 'ffmpeg', FfmpegCommandRunner? commandRunner})
    : _commandRunner = commandRunner ?? _defaultFfmpegCommandRunner;

  final String ffmpegExecutable;
  final FfmpegCommandRunner _commandRunner;

  Future<bool> isAvailable() async {
    try {
      final result = await _commandRunner(ffmpegExecutable, const ['-version']);
      return result.exitCode == 0;
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
    _validatePcmParams(sampleRateHz: sampleRateHz, channelCount: channelCount);
    if (pcm16leBytes.isEmpty) {
      throw ArgumentError.value(pcm16leBytes, 'pcm16leBytes', 'Cannot be empty');
    }

    final args = _buildPcmInputArgs(
      inputPath: 'pipe:0',
      sampleRateHz: sampleRateHz,
      channelCount: channelCount,
      bitrateKbps: bitrateKbps,
      outputPath: outputPath,
    );
    await _run(args, stdinBytes: pcm16leBytes);
  }

  @override
  Future<void> encodePcm16FileToAac({
    required String inputPath,
    required int sampleRateHz,
    required int channelCount,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    _validatePcmParams(sampleRateHz: sampleRateHz, channelCount: channelCount);
    final args = _buildPcmInputArgs(
      inputPath: inputPath,
      sampleRateHz: sampleRateHz,
      channelCount: channelCount,
      bitrateKbps: bitrateKbps,
      outputPath: outputPath,
    );
    await _run(args);
  }

  @override
  Future<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    if (bitrateKbps <= 0) {
      throw ArgumentError.value(bitrateKbps, 'bitrateKbps', 'Must be > 0');
    }

    final args = <String>[
      '-hide_banner',
      '-loglevel',
      'error',
      '-i',
      inputPath,
      '-vn',
      '-c:a',
      'aac',
      '-b:a',
      '${bitrateKbps}k',
      '-y',
      outputPath,
    ];
    await _run(args);
  }

  List<String> _buildPcmInputArgs({
    required String inputPath,
    required int sampleRateHz,
    required int channelCount,
    required int bitrateKbps,
    required String outputPath,
  }) {
    if (bitrateKbps <= 0) {
      throw ArgumentError.value(bitrateKbps, 'bitrateKbps', 'Must be > 0');
    }

    return <String>[
      '-hide_banner',
      '-loglevel',
      'error',
      '-f',
      's16le',
      '-ar',
      '$sampleRateHz',
      '-ac',
      '$channelCount',
      '-i',
      inputPath,
      '-vn',
      '-c:a',
      'aac',
      '-b:a',
      '${bitrateKbps}k',
      '-y',
      outputPath,
    ];
  }

  void _validatePcmParams({required int sampleRateHz, required int channelCount}) {
    if (sampleRateHz <= 0) {
      throw ArgumentError.value(sampleRateHz, 'sampleRateHz', 'Must be > 0');
    }
    if (channelCount <= 0) {
      throw ArgumentError.value(channelCount, 'channelCount', 'Must be > 0');
    }
  }

  Future<void> _run(List<String> args, {Uint8List? stdinBytes}) async {
    FfmpegCommandResult result;
    try {
      result = await _commandRunner(ffmpegExecutable, args, stdinBytes: stdinBytes);
    } on AacEncodingException {
      rethrow;
    } on Object catch (error) {
      throw AacEncodingException('Failed to execute ffmpeg command: $error');
    }

    if (result.exitCode != 0) {
      throw AacEncodingException(
        'ffmpeg exited with a non-zero code',
        exitCode: result.exitCode,
        stderr: result.stderr,
      );
    }
  }
}

Future<FfmpegCommandResult> _defaultFfmpegCommandRunner(
  String executable,
  List<String> arguments, {
  Uint8List? stdinBytes,
}) async {
  Process process;
  try {
    process = await Process.start(executable, arguments, runInShell: false);
  } on ProcessException catch (error) {
    throw AacEncodingException('Failed to start ffmpeg: ${error.message}');
  }

  final stderrFuture = process.stderr.transform(utf8.decoder).join();
  final stdoutDrainFuture = process.stdout.drain<void>();

  if (stdinBytes != null && stdinBytes.isNotEmpty) {
    process.stdin.add(stdinBytes);
  }
  await process.stdin.close();

  final exitCode = await process.exitCode;
  await stdoutDrainFuture;
  final stderr = await stderrFuture;
  return FfmpegCommandResult(exitCode: exitCode, stderr: stderr);
}
