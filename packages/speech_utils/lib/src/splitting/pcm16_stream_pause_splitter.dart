import 'dart:collection';
import 'dart:typed_data';

import '../models/pause_split_options.dart';
import '../models/pcm16_snippet.dart';
import '../vad/vad_backend.dart';
import '../utils/pcm16_audio_utils.dart';
import 'pause_split_frame_policy.dart';

/// Stateful splitter for live PCM16 streams.
///
/// Feed chunks via [addChunk], and call [flush] when the input stream closes.
final class Pcm16StreamPauseSplitter {
  Pcm16StreamPauseSplitter({
    required this.options,
    required this.vadBackend,
    this.onFrameClassified,
  }) : _framePolicy = PauseSplitFramePolicy.fromOptions(options) {
    options.validate();
  }

  final PauseSplitOptions options;
  final VadBackend vadBackend;
  final void Function(bool isSpeech)? onFrameClassified;

  final PauseSplitFramePolicy _framePolicy;

  Uint8List _leftoverBytes = Uint8List(0);
  final ListQueue<Uint8List> _preSpeechFrameQueue = ListQueue<Uint8List>();
  final List<Uint8List> _segmentFrames = <Uint8List>[];

  bool _inSegment = false;
  int _speechFrameCount = 0;
  int _trailingSilenceFrames = 0;

  /// Adds one PCM16 chunk and returns any snippets that were completed.
  List<Pcm16Snippet> addChunk(Uint8List chunk) {
    if (chunk.isEmpty) {
      return const [];
    }

    final workingBytes = Pcm16AudioUtils.ensureEvenByteOffset(_mergeWithLeftover(chunk));
    final fullFrameCount = workingBytes.length ~/ _framePolicy.frameByteCount;
    final emitted = <Pcm16Snippet>[];

    for (var frameIndex = 0; frameIndex < fullFrameCount; frameIndex++) {
      final frameStart = frameIndex * _framePolicy.frameByteCount;
      final frameEnd = frameStart + _framePolicy.frameByteCount;
      final frameBytes = Uint8List.sublistView(workingBytes, frameStart, frameEnd);
      _consumeFrame(frameBytes, emitted);
    }

    final processedBytes = fullFrameCount * _framePolicy.frameByteCount;
    final remainingBytes = workingBytes.length - processedBytes;
    if (remainingBytes == 0) {
      _leftoverBytes = Uint8List(0);
    } else {
      _leftoverBytes = Uint8List(remainingBytes);
      _leftoverBytes.setRange(0, remainingBytes, workingBytes, processedBytes);
    }

    return emitted;
  }

  /// Flushes pending state at end-of-stream and emits a final snippet if needed.
  List<Pcm16Snippet> flush() {
    return _splitCurrentSegment(clearPreSpeechBuffer: true);
  }

  /// Forces the active segment to be emitted at the current stream position.
  ///
  /// If no speech segment is active, no snippet is emitted and buffered
  /// pre-speech padding is cleared so the manual boundary is respected.
  List<Pcm16Snippet> split() {
    return _splitCurrentSegment(clearPreSpeechBuffer: true);
  }

  List<Pcm16Snippet> _splitCurrentSegment({required bool clearPreSpeechBuffer}) {
    final emitted = <Pcm16Snippet>[];
    final trailingBytes = _leftoverBytes;
    _leftoverBytes = Uint8List(0);

    if (_inSegment) {
      final snippet = _emitCurrentSegment(forceFlush: true, trailingPartialBytes: trailingBytes);
      if (snippet != null) {
        emitted.add(snippet);
      }
    }

    if (clearPreSpeechBuffer) {
      _preSpeechFrameQueue.clear();
    }
    return emitted;
  }

  void _consumeFrame(Uint8List frameBytes, List<Pcm16Snippet> emitted) {
    final alignedFrameBytes = Pcm16AudioUtils.ensureEvenByteOffset(frameBytes);
    final frameSamples = Int16List.view(
      alignedFrameBytes.buffer,
      alignedFrameBytes.offsetInBytes,
      _framePolicy.frameSampleCount,
    );
    final isSpeech = vadBackend.isSpeechFrame(
      frameSamples,
      startSampleOffset: 0,
      sampleCount: _framePolicy.frameSampleCount,
      sampleRateHz: options.sampleRateHz,
      channelCount: options.channelCount,
    );
    onFrameClassified?.call(isSpeech);

    if (isSpeech) {
      _handleSpeechFrame(frameBytes);
      return;
    }

    _handleSilenceFrame(frameBytes, emitted);
  }

  void _handleSpeechFrame(Uint8List frameBytes) {
    if (!_inSegment) {
      _inSegment = true;
      _segmentFrames.addAll(_preSpeechFrameQueue);
      _preSpeechFrameQueue.clear();
    }

    _segmentFrames.add(frameBytes);
    _speechFrameCount++;
    _trailingSilenceFrames = 0;
  }

  void _handleSilenceFrame(Uint8List frameBytes, List<Pcm16Snippet> emitted) {
    if (!_inSegment) {
      _pushPreSpeechFrame(frameBytes);
      return;
    }

    _segmentFrames.add(frameBytes);
    _trailingSilenceFrames++;
    if (_trailingSilenceFrames < _framePolicy.minSilenceFrames) {
      return;
    }

    final snippet = _emitCurrentSegment(forceFlush: false);
    if (snippet != null) {
      emitted.add(snippet);
    }
  }

  Pcm16Snippet? _emitCurrentSegment({required bool forceFlush, Uint8List? trailingPartialBytes}) {
    if (!_inSegment) {
      return null;
    }
    if (_speechFrameCount < _framePolicy.minSpeechFrames) {
      _resetCurrentSegmentState();
      return null;
    }

    final keptFrameCount = forceFlush
        ? _segmentFrames.length
        : _framePolicy.keptFrameCountAfterTrim(
            totalFrameCount: _segmentFrames.length,
            trailingSilenceFrames: _trailingSilenceFrames,
          );
    if (keptFrameCount <= 0) {
      _resetCurrentSegmentState();
      return null;
    }

    final keptFrames = _segmentFrames.take(keptFrameCount).toList(growable: false);
    final bytes = _flattenFrames(
      keptFrames,
      trailingPartialBytes: forceFlush ? trailingPartialBytes : null,
    );
    final snippet = Pcm16Snippet(
      sourceBuffer: bytes.buffer,
      sourceByteOffset: bytes.offsetInBytes,
      startSampleOffset: 0,
      endSampleOffsetExclusive: bytes.lengthInBytes ~/ 2,
      sampleRateHz: options.sampleRateHz,
      channelCount: options.channelCount,
      speechFrameCount: _speechFrameCount,
      analyzedFrameCount: keptFrameCount,
    );

    if (!forceFlush) {
      _seedPreSpeechBufferFromTrimmedFrames(keptFrameCount);
    }
    _resetCurrentSegmentState();
    return snippet;
  }

  void _seedPreSpeechBufferFromTrimmedFrames(int keptFrameCount) {
    if (_framePolicy.preSpeechFrames == 0) {
      return;
    }
    _preSpeechFrameQueue.clear();
    for (var i = keptFrameCount; i < _segmentFrames.length; i++) {
      _pushPreSpeechFrame(_segmentFrames[i]);
    }
  }

  void _pushPreSpeechFrame(Uint8List frameBytes) {
    if (_framePolicy.preSpeechFrames == 0) {
      return;
    }
    _preSpeechFrameQueue.add(frameBytes);
    while (_preSpeechFrameQueue.length > _framePolicy.preSpeechFrames) {
      _preSpeechFrameQueue.removeFirst();
    }
  }

  void _resetCurrentSegmentState() {
    _inSegment = false;
    _speechFrameCount = 0;
    _trailingSilenceFrames = 0;
    _segmentFrames.clear();
  }

  Uint8List _mergeWithLeftover(Uint8List chunk) {
    if (_leftoverBytes.isEmpty) {
      return chunk;
    }

    final merged = Uint8List(_leftoverBytes.length + chunk.length);
    merged.setRange(0, _leftoverBytes.length, _leftoverBytes);
    merged.setRange(_leftoverBytes.length, merged.length, chunk);
    return merged;
  }
}

Uint8List _flattenFrames(List<Uint8List> frames, {Uint8List? trailingPartialBytes}) {
  return Pcm16AudioUtils.concatByteBlocks(frames, trailing: trailingPartialBytes);
}
