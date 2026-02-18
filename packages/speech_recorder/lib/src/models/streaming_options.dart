import 'dart:async';

import 'package:speech_utils/speech_utils.dart';

import 'segment_data.dart';

typedef SpeechRecorderSegmentPathBuilder =
    String Function(int segmentIndex, String fileExtension);

typedef SpeechRecorderSegmentCallback =
    FutureOr<void> Function(SpeechRecorderSegmentData segment);

class SpeechRecorderStreamingOptions {
  final PauseSplitOptions pauseSplitOptions;
  final SpeechVadConfig? vadConfig;
  final AacEncoder? encoder;
  final int bitrateKbps;
  final String fileExtension;
  final String mimeType;
  final SpeechRecorderSegmentPathBuilder? segmentPathBuilder;
  final SpeechRecorderSegmentCallback? onSegmentFinished;

  const SpeechRecorderStreamingOptions({
    required this.pauseSplitOptions,
    this.vadConfig,
    this.encoder,
    this.bitrateKbps = 48,
    this.fileExtension = 'm4a',
    this.mimeType = 'audio/mp4',
    this.segmentPathBuilder,
    this.onSegmentFinished,
  });
}
