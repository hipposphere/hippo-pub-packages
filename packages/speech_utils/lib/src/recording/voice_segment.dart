import 'package:cross_file/cross_file.dart';

import '../model/audio_metadata.dart';
import '../model/audio_segment_metrics.dart';
import '../model/voice_activity_metadata.dart';

typedef NativeVoiceSegmentPathBuilder = String Function(int segmentIndex, String fileExtension);

final class VoiceSegment {
  const VoiceSegment({
    required this.index,
    required this.file,
    required this.fileExtension,
    required this.mimeType,
    required this.metadata,
    this.voiceActivity = const VoiceActivityMetadata(),
    this.metrics = const AudioSegmentMetrics(),
  });

  final int index;
  final XFile file;
  final String fileExtension;
  final String mimeType;
  final AudioMetadata metadata;
  final VoiceActivityMetadata voiceActivity;
  final AudioSegmentMetrics metrics;
}
