import 'dart:math' as math;
import 'dart:typed_data';

import '../model/pause_split_options.dart';
import '../model/pcm16_snippet.dart';
import '../vad/energy_vad_backend.dart';
import '../vad/vad_backend.dart';

/// Splits PCM16 streams into snippets whenever silence is detected.
final class Pcm16PauseSplitter {
  Pcm16PauseSplitter({required this.options, VadBackend? vadBackend})
    : vadBackend = vadBackend ?? const EnergyVadBackend() {
    options.validate();
  }

  final PauseSplitOptions options;
  final VadBackend vadBackend;

  List<Pcm16Snippet> split(Uint8List pcm16leBytes, {int byteOffset = 0, int? byteLength}) {
    if (byteOffset < 0 || byteOffset > pcm16leBytes.lengthInBytes) {
      throw ArgumentError.value(
        byteOffset,
        'byteOffset',
        'Must be in range [0, ${pcm16leBytes.lengthInBytes}]',
      );
    }

    final effectiveByteLength = byteLength ?? (pcm16leBytes.lengthInBytes - byteOffset);
    if (effectiveByteLength < 0 || byteOffset + effectiveByteLength > pcm16leBytes.lengthInBytes) {
      throw ArgumentError.value(
        byteLength,
        'byteLength',
        'Invalid byte length for the given offset',
      );
    }
    if (effectiveByteLength == 0) {
      return const [];
    }
    if (effectiveByteLength.isOdd) {
      throw ArgumentError.value(
        byteLength,
        'byteLength',
        'PCM16 payload must have an even byte size',
      );
    }

    final absoluteByteOffset = pcm16leBytes.offsetInBytes + byteOffset;
    final effectiveByteCount = effectiveByteLength ~/ 2;
    final samples = absoluteByteOffset.isEven
        ? Int16List.view(pcm16leBytes.buffer, absoluteByteOffset, effectiveByteCount)
        : Int16List.view(
            _copyAlignedBytes(
              sourceBytes: pcm16leBytes,
              sourceStartOffset: byteOffset,
              byteLength: effectiveByteLength,
            ).buffer,
            0,
            effectiveByteCount,
          );
    final frameSampleCount = options.frameSampleCount;
    final totalFrames = samples.length ~/ frameSampleCount;
    if (totalFrames == 0) {
      return const [];
    }

    final minSpeechFrames = math.max(1, options.framesFor(options.minSpeechDuration));
    final minSilenceFrames = math.max(1, options.framesFor(options.minSilenceDuration));
    final preSpeechFrames = options.framesFor(options.preSpeechPadding);
    final postSpeechFrames = options.framesFor(options.postSpeechPadding);

    final snippets = <Pcm16Snippet>[];
    int? segmentStartFrame;
    var speechFrameCount = 0;
    var trailingSilenceFrames = 0;

    for (var frameIndex = 0; frameIndex < totalFrames; frameIndex++) {
      final frameStartSample = frameIndex * frameSampleCount;
      final isSpeech = vadBackend.isSpeechFrame(
        samples,
        startSampleOffset: frameStartSample,
        sampleCount: frameSampleCount,
        sampleRateHz: options.sampleRateHz,
        channelCount: options.channelCount,
      );

      if (isSpeech) {
        segmentStartFrame ??= _clampInt(frameIndex - preSpeechFrames, 0, totalFrames);
        speechFrameCount++;
        trailingSilenceFrames = 0;
        continue;
      }

      if (segmentStartFrame == null) {
        continue;
      }

      trailingSilenceFrames++;
      if (trailingSilenceFrames < minSilenceFrames) {
        continue;
      }

      final rawEndFrameExclusive = frameIndex - trailingSilenceFrames + 1 + postSpeechFrames;
      final segmentEndFrame = _clampInt(rawEndFrameExclusive, segmentStartFrame, totalFrames);
      _addSnippet(
        snippets: snippets,
        samples: samples,
        segmentStartFrame: segmentStartFrame,
        segmentEndFrameExclusive: segmentEndFrame,
        frameSampleCount: frameSampleCount,
        minSpeechFrames: minSpeechFrames,
        speechFrameCount: speechFrameCount,
      );

      segmentStartFrame = null;
      speechFrameCount = 0;
      trailingSilenceFrames = 0;
    }

    if (segmentStartFrame != null) {
      _addSnippet(
        snippets: snippets,
        samples: samples,
        segmentStartFrame: segmentStartFrame,
        segmentEndFrameExclusive: totalFrames,
        frameSampleCount: frameSampleCount,
        minSpeechFrames: minSpeechFrames,
        speechFrameCount: speechFrameCount,
      );
    }

    return snippets;
  }

  void _addSnippet({
    required List<Pcm16Snippet> snippets,
    required Int16List samples,
    required int segmentStartFrame,
    required int segmentEndFrameExclusive,
    required int frameSampleCount,
    required int minSpeechFrames,
    required int speechFrameCount,
  }) {
    if (speechFrameCount < minSpeechFrames) {
      return;
    }

    final startSampleOffset = segmentStartFrame * frameSampleCount;
    final endSampleOffsetExclusive = math.min(
      segmentEndFrameExclusive * frameSampleCount,
      samples.length,
    );
    if (endSampleOffsetExclusive <= startSampleOffset) {
      return;
    }

    snippets.add(
      Pcm16Snippet(
        sourceBuffer: samples.buffer,
        sourceByteOffset: samples.offsetInBytes,
        startSampleOffset: startSampleOffset,
        endSampleOffsetExclusive: endSampleOffsetExclusive,
        sampleRateHz: options.sampleRateHz,
        channelCount: options.channelCount,
      ),
    );
  }
}

int _clampInt(int value, int min, int max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}

Uint8List _copyAlignedBytes({
  required Uint8List sourceBytes,
  required int sourceStartOffset,
  required int byteLength,
}) {
  final aligned = Uint8List(byteLength);
  aligned.setRange(0, byteLength, sourceBytes, sourceStartOffset);
  return aligned;
}
