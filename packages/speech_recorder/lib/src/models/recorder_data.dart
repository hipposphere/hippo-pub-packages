import 'package:flutter/foundation.dart';
import 'package:hippo_utils/cross_file.dart';

class SpeechRecorderData {
  final XFile file;
  final Duration duration;
  final String fileExtension;
  final String mimeType;
  final int? sampleRateHz;
  final int? channelCount;
  final int? bitrateBps;
  final String? containerFormat;
  final String? codec;
  final String? codecProfile;

  const SpeechRecorderData({
    required this.file,
    required this.duration,
    required this.mimeType,
    required this.fileExtension,
    this.sampleRateHz,
    this.channelCount,
    this.bitrateBps,
    this.containerFormat,
    this.codec,
    this.codecProfile,
  });

  Future<Uint8List> readAudioBytes() async {
    return file.readAsBytes();
  }
}
