import 'package:record/record.dart';

class RecordingFileType {
  static String fileExtensionFromAudioEncoder(AudioEncoder encoder) {
    return switch (encoder) {
      AudioEncoder.aacLc => 'm4a',
      AudioEncoder.flac => 'flac',
      AudioEncoder.opus => 'opus',
      AudioEncoder.wav => 'wav',
      _ => 'wav',
    };
  }

  static String mimeTypeFromAudioEncoder(AudioEncoder encoder) {
    return switch (encoder) {
      AudioEncoder.aacLc => 'audio/m4a',
      AudioEncoder.flac => 'audio/flac',
      AudioEncoder.opus => 'audio/opus',
      AudioEncoder.wav => 'audio/wav',
      _ => 'audio/wav',
    };
  }
}
