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

  /// Captures the full PCM stream and encodes it once when `stop()` is called.
  ///
  /// Disabled by default because this requires an additional encode pass.
  final bool encodeFullRecordingOnStop;

  /// Emits a single fallback segment on `stop()` when no segment was emitted.
  ///
  /// Disabled by default because this requires capturing full PCM and an
  /// additional encode pass.
  final bool emitStopFallbackSegmentIfEmpty;

  /// Includes a VAD-based probability estimate on each emitted segment.
  ///
  /// Disabled by default because this adds another per-segment VAD pass.
  final bool includeSpeechProbability;
  final String fileExtension;
  final String mimeType;
  final SpeechRecorderSegmentPathBuilder? segmentPathBuilder;
  final SpeechRecorderSegmentCallback? onSegmentFinished;

  const SpeechRecorderStreamingOptions({
    required this.pauseSplitOptions,
    this.vadConfig,
    this.encoder,
    this.bitrateKbps = 48,
    this.encodeFullRecordingOnStop = false,
    this.emitStopFallbackSegmentIfEmpty = false,
    this.includeSpeechProbability = false,
    this.fileExtension = 'm4a',
    this.mimeType = 'audio/mp4',
    this.segmentPathBuilder,
    this.onSegmentFinished,
  });
}
