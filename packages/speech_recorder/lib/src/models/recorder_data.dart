import 'package:flutter/foundation.dart';
import 'package:hippo_utils/cross_file.dart';

class SpeechRecorderData {
  final XFile file;
  final Duration duration;
  final String fileExtension;
  final String mimeType;

  const SpeechRecorderData({
    required this.file,
    required this.duration,
    required this.mimeType,
    required this.fileExtension,
  });

  Future<Uint8List> readAudioBytes() async {
    return file.readAsBytes();
  }
}
