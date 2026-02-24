import 'dart:math' as math;

import '../models/pause_split_options.dart';

/// Derived frame-level settings shared by batch and stream pause splitters.
final class PauseSplitFramePolicy {
  PauseSplitFramePolicy.fromOptions(PauseSplitOptions options)
    : frameSampleCount = options.frameSampleCount,
      minSpeechFrames = _atLeastOne(options.framesFor(options.minSpeechDuration)),
      minSilenceFrames = _atLeastOne(options.framesFor(options.minSilenceDuration)),
      preSpeechFrames = options.framesFor(options.preSpeechPadding),
      postSpeechFrames = options.framesFor(options.postSpeechPadding);

  final int frameSampleCount;
  final int minSpeechFrames;
  final int minSilenceFrames;
  final int preSpeechFrames;
  final int postSpeechFrames;

  int get frameByteCount => frameSampleCount * 2;

  int trimmedTrailingFrames(int trailingSilenceFrames) {
    return math.max(0, trailingSilenceFrames - postSpeechFrames);
  }

  int keptFrameCountAfterTrim({required int totalFrameCount, required int trailingSilenceFrames}) {
    final trimFrames = trimmedTrailingFrames(trailingSilenceFrames);
    if (trimFrames >= totalFrameCount) {
      return 0;
    }
    return totalFrameCount - trimFrames;
  }

  static int _atLeastOne(int value) => value <= 0 ? 1 : value;
}
