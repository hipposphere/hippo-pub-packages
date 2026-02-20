import 'dart:async';

import 'package:speech_utils/speech_utils.dart';

import 'segment_data.dart';

typedef SpeechRecorderSegmentCallback =
    FutureOr<void> Function(SpeechRecorderSegmentData segment);

class SpeechRecorderStreamingOptions {
  final PauseSplitOptions pauseSplitOptions;
  final SpeechVadConfig? vadConfig;

  /// Includes a VAD-based probability estimate on each emitted segment.
  final bool includeSpeechProbability;
  final SpeechRecorderSegmentCallback? onSegmentFinished;

  const SpeechRecorderStreamingOptions({
    required this.pauseSplitOptions,
    this.vadConfig,
    this.includeSpeechProbability = false,
    this.onSegmentFinished,
  });
}
