import 'dart:typed_data';

/// Encodes PCM/audio input into AAC output.
abstract interface class AacEncoder {
  Future<void> encodePcm16BytesToAac({
    required Uint8List pcm16leBytes,
    required int sampleRateHz,
    required int channelCount,
    required String outputPath,
    int bitrateKbps,
  });

  Future<void> encodePcm16FileToAac({
    required String inputPath,
    required int sampleRateHz,
    required int channelCount,
    required String outputPath,
    int bitrateKbps,
  });

  Future<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    int bitrateKbps,
  });
}

final class AacEncodingException implements Exception {
  AacEncodingException(this.message, {this.exitCode, this.stderr});

  final String message;
  final int? exitCode;
  final String? stderr;

  @override
  String toString() {
    final details = <String>[
      message,
      if (exitCode != null) 'exitCode=$exitCode',
      if (stderr != null && stderr!.isNotEmpty) 'stderr=$stderr',
    ];
    return 'AacEncodingException: ${details.join(' | ')}';
  }
}
