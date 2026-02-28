import 'dart:math' as math;
import 'dart:typed_data';

import '../models/pause_split_options.dart';
import '../models/pcm16_snippet.dart';
import '../vad/vad_backend.dart';
import '../utils/pcm16_audio_utils.dart';
import 'pause_split_frame_policy.dart';

/// Splits PCM16 streams into snippets whenever silence is detected.
final class Pcm16PauseSplitter {
  Pcm16PauseSplitter({required this.options, required this.vadBackend}) {
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

    final samples = Pcm16AudioUtils.asAlignedInt16List(
      pcm16leBytes,
      byteOffset: byteOffset,
      byteLength: effectiveByteLength,
    );
    final framePolicy = PauseSplitFramePolicy.fromOptions(options);
    final frameSampleCount = framePolicy.frameSampleCount;
    final totalFrames = samples.length ~/ frameSampleCount;
    if (totalFrames == 0) {
      return const [];
    }

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
        segmentStartFrame ??= _clampInt(frameIndex - framePolicy.preSpeechFrames, 0, totalFrames);
        speechFrameCount++;
        trailingSilenceFrames = 0;
        continue;
      }

      if (segmentStartFrame == null) {
        continue;
      }

      trailingSilenceFrames++;
      if (trailingSilenceFrames < framePolicy.minSilenceFrames) {
        continue;
      }

      final rawEndFrameExclusive =
          (frameIndex + 1) - framePolicy.trimmedTrailingFrames(trailingSilenceFrames);
      final segmentEndFrame = _clampInt(rawEndFrameExclusive, segmentStartFrame, totalFrames);
      _addSnippet(
        snippets: snippets,
        samples: samples,
        segmentStartFrame: segmentStartFrame,
        segmentEndFrameExclusive: segmentEndFrame,
        frameSampleCount: frameSampleCount,
        minSpeechFrames: framePolicy.minSpeechFrames,
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
        minSpeechFrames: framePolicy.minSpeechFrames,
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

    final analyzedFrameCount = (endSampleOffsetExclusive - startSampleOffset) ~/ frameSampleCount;
    snippets.add(
      Pcm16Snippet(
        sourceBuffer: samples.buffer,
        sourceByteOffset: samples.offsetInBytes,
        startSampleOffset: startSampleOffset,
        endSampleOffsetExclusive: endSampleOffsetExclusive,
        sampleRateHz: options.sampleRateHz,
        channelCount: options.channelCount,
        speechFrameCount: speechFrameCount,
        analyzedFrameCount: analyzedFrameCount,
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
