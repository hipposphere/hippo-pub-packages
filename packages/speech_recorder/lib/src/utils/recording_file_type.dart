import 'package:speech_utils/speech_utils.dart';

class RecordingFileType {
  static String fileExtensionFromAudioEncoder(AudioEncoder encoder) {
    return encoder.defaultFileExtension;
  }

  static String mimeTypeFromAudioEncoder(AudioEncoder encoder) {
    return encoder.defaultMimeType;
  }
}
