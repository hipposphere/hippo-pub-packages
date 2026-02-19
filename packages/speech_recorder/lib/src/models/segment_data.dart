import 'dart:typed_data';

import 'package:hippo_utils/cross_file.dart';

class SpeechRecorderSegmentMetrics {
  final Duration encodingDuration;
  final Duration splitToCallbackLatency;
  final int pcmByteCount;
  final double? speechProbability;

  const SpeechRecorderSegmentMetrics({
    this.encodingDuration = Duration.zero,
    this.splitToCallbackLatency = Duration.zero,
    this.pcmByteCount = 0,
    this.speechProbability,
  });
}

class SpeechRecorderSegmentData {
  final int index;
  final XFile file;
  final Duration duration;
  final String fileExtension;
  final String mimeType;
  final int sampleRateHz;
  final int channelCount;
  final int? bitrateBps;
  final String? containerFormat;
  final String? codec;
  final String? codecProfile;
  final SpeechRecorderSegmentMetrics metrics;

  const SpeechRecorderSegmentData({
    required this.index,
    required this.file,
    required this.duration,
    required this.fileExtension,
    required this.mimeType,
    required this.sampleRateHz,
    required this.channelCount,
    this.bitrateBps,
    this.containerFormat,
    this.codec,
    this.codecProfile,
    this.metrics = const SpeechRecorderSegmentMetrics(),
  });

  Future<Uint8List> readAudioBytes() async {
    return file.readAsBytes();
  }
}
