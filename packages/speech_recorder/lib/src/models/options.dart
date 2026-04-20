import 'package:speech_utils/speech_utils.dart';

import '../utils/recording_file_type.dart';

class SpeechRecorderOptions {
  final String path;
  final AudioRecorderConfig recordConfig;
  final Duration amplitudeInterval;

  const SpeechRecorderOptions({
    required this.path,
    required this.recordConfig,
    this.amplitudeInterval = const Duration(milliseconds: 200),
  });

  String get mimeType =>
      RecordingFileType.mimeTypeFromAudioEncoder(recordConfig.encoding.encoder);

  String get fileExtension => RecordingFileType.fileExtensionFromAudioEncoder(
    recordConfig.encoding.encoder,
  );
}
