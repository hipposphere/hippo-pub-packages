import 'dart:math' as math;
import 'dart:typed_data';

import 'vad_backend.dart';

/// Lightweight, dependency-free VAD using RMS + zero-crossing heuristics.
final class EnergyVadBackend extends VadBackend {
  const EnergyVadBackend({
    this.primaryRmsThreshold = 0.015,
    this.secondaryRmsThreshold = 0.010,
    this.minZeroCrossingRate = 0.08,
  });

  final double primaryRmsThreshold;
  final double secondaryRmsThreshold;
  final double minZeroCrossingRate;

  @override
  bool isSpeechFrame(
    Int16List interleavedPcm16Samples, {
    required int startSampleOffset,
    required int sampleCount,
    required int sampleRateHz,
    required int channelCount,
  }) {
    if (sampleCount <= 0 || channelCount <= 0) {
      return false;
    }

    final monoSampleCount = sampleCount ~/ channelCount;
    if (monoSampleCount <= 1) {
      return false;
    }

    var sumSquares = 0.0;
    var zeroCrossings = 0;
    var previous = 0.0;
    var hasPrevious = false;

    final end = startSampleOffset + sampleCount;
    for (var sampleIndex = startSampleOffset; sampleIndex < end; sampleIndex += channelCount) {
      final normalized = interleavedPcm16Samples[sampleIndex] / 32768.0;
      sumSquares += normalized * normalized;

      if (hasPrevious &&
          ((previous >= 0.0 && normalized < 0.0) || (previous < 0.0 && normalized >= 0.0))) {
        zeroCrossings++;
      }

      previous = normalized;
      hasPrevious = true;
    }

    final rms = math.sqrt(sumSquares / monoSampleCount);
    if (rms >= primaryRmsThreshold) {
      return true;
    }

    final zeroCrossingRate = zeroCrossings / (monoSampleCount - 1);
    return rms >= secondaryRmsThreshold && zeroCrossingRate >= minZeroCrossingRate;
  }
}
