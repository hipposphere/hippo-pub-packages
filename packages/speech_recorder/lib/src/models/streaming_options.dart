import 'dart:async';

import 'package:speech_utils/speech_utils.dart';

import 'segment_data.dart';

typedef SpeechRecorderSegmentCallback =
    FutureOr<void> Function(SpeechRecorderSegmentData segment);

class SpeechRecorderStreamingOptions {
  final PauseSplitOptions? pauseSplitOptions;
  final SpeechVadConfig? vadConfig;

  /// How streaming recordings should be split into segments.
  final AudioSegmentSplitMode splitMode;

  /// Includes a VAD-based probability estimate on each emitted segment.
  final bool includeSpeechProbability;
  final SpeechRecorderSegmentCallback? onSegmentFinished;

  const SpeechRecorderStreamingOptions({
    this.pauseSplitOptions,
    this.vadConfig,
    this.splitMode = AudioSegmentSplitMode.vad,
    this.includeSpeechProbability = false,
    this.onSegmentFinished,
  });

  PauseSplitOptions resolvePauseSplitOptions(AudioRecorderConfig recordConfig) {
    return pauseSplitOptions ??
        PauseSplitOptions(
          sampleRateHz: recordConfig.sampleRateHz,
          channelCount: recordConfig.channelCount,
        );
  }
}
