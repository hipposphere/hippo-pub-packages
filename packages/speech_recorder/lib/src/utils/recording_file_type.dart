import 'package:record/record.dart';

class RecordingFileType {
  static String fileExtensionFromAudioEncoder(AudioEncoder encoder) {
    return switch (encoder) {
      .aacLc || .aacEld || .aacHe => 'm4a',
      .flac => 'flac',
      .opus => 'opus',
      .wav => 'wav',
      .pcm16bits => 'pcm',
      _ => 'wav',
    };
  }

  static String mimeTypeFromAudioEncoder(AudioEncoder encoder) {
    return switch (encoder) {
      .aacLc || .aacEld || .aacHe => 'audio/aac',
      .flac => 'audio/flac',
      .opus => 'audio/opus',
      .wav => 'audio/wav',
      .pcm16bits => 'audio/wav',
      _ => 'audio/wav',
    };
  }
}
