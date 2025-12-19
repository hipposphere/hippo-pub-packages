import 'package:speech_recorder/speech_recorder.dart';

class SpeechRecorderOptions {
  final String path;
  final RecordConfig recordConfig;
  final Duration amplitudeInterval;

  const SpeechRecorderOptions({
    required this.path,
    required this.recordConfig,
    this.amplitudeInterval = const Duration(milliseconds: 200),
  });
}
