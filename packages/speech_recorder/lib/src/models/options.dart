import 'package:record/record.dart';
import 'package:speech_utils/speech_utils.dart';

import '../utils/recording_file_type.dart';
import 'streaming_options.dart';

class SpeechRecorderOptions {
  final String path;
  final RecordConfig recordConfig;
  final SpeechVadConfig? vadConfig;
  final SpeechRecorderStreamingOptions? streaming;
  final Duration amplitudeInterval;

  const SpeechRecorderOptions({
    required this.path,
    required this.recordConfig,
    this.vadConfig,
    this.streaming,
    this.amplitudeInterval = const Duration(milliseconds: 200),
  });

  String get mimeType =>
      RecordingFileType.mimeTypeFromAudioEncoder(recordConfig.encoder);

  String get fileExtension =>
      RecordingFileType.fileExtensionFromAudioEncoder(recordConfig.encoder);
}
