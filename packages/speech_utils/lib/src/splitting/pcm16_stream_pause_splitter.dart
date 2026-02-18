import 'dart:collection';
import 'dart:typed_data';

import '../model/pause_split_options.dart';
import '../model/pcm16_snippet.dart';
import '../vad/energy_vad_backend.dart';
import '../vad/vad_backend.dart';

/// Stateful splitter for live PCM16 streams.
///
/// Feed chunks via [addChunk], and call [flush] when the input stream closes.
final class Pcm16StreamPauseSplitter {
  Pcm16StreamPauseSplitter({required this.options, VadBackend? vadBackend})
    : vadBackend = vadBackend ?? const EnergyVadBackend(),
      _frameByteCount = options.frameSampleCount * 2,
      _minSpeechFrames = _atLeastOne(options.framesFor(options.minSpeechDuration)),
      _minSilenceFrames = _atLeastOne(options.framesFor(options.minSilenceDuration)),
      _preSpeechFrames = options.framesFor(options.preSpeechPadding),
      _postSpeechFrames = options.framesFor(options.postSpeechPadding) {
    options.validate();
  }

  final PauseSplitOptions options;
  final VadBackend vadBackend;

  final int _frameByteCount;
  final int _minSpeechFrames;
  final int _minSilenceFrames;
  final int _preSpeechFrames;
  final int _postSpeechFrames;

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

    final workingBytes = _ensureEvenByteOffset(_mergeWithLeftover(chunk));
    final fullFrameCount = workingBytes.length ~/ _frameByteCount;
    final emitted = <Pcm16Snippet>[];

    for (var frameIndex = 0; frameIndex < fullFrameCount; frameIndex++) {
      final frameStart = frameIndex * _frameByteCount;
      final frameEnd = frameStart + _frameByteCount;
      final frameBytes = Uint8List.sublistView(workingBytes, frameStart, frameEnd);
      _consumeFrame(frameBytes, emitted);
    }

    final processedBytes = fullFrameCount * _frameByteCount;
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
    final emitted = <Pcm16Snippet>[];
    final trailingBytes = _leftoverBytes;
    _leftoverBytes = Uint8List(0);

    if (_inSegment) {
      final snippet = _emitCurrentSegment(forceFlush: true, trailingPartialBytes: trailingBytes);
      if (snippet != null) {
        emitted.add(snippet);
      }
    }

    _preSpeechFrameQueue.clear();
    return emitted;
  }

  void _consumeFrame(Uint8List frameBytes, List<Pcm16Snippet> emitted) {
    final alignedFrameBytes = _ensureEvenByteOffset(frameBytes);
    final frameSamples = Int16List.view(
      alignedFrameBytes.buffer,
      alignedFrameBytes.offsetInBytes,
      options.frameSampleCount,
    );
    final isSpeech = vadBackend.isSpeechFrame(
      frameSamples,
      startSampleOffset: 0,
      sampleCount: options.frameSampleCount,
      sampleRateHz: options.sampleRateHz,
      channelCount: options.channelCount,
    );

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
    if (_trailingSilenceFrames < _minSilenceFrames) {
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
    if (_speechFrameCount < _minSpeechFrames) {
      _resetCurrentSegmentState();
      return null;
    }

    final keptFrameCount = forceFlush ? _segmentFrames.length : _computeKeptFrameCountAfterTrim();
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
    );

    if (!forceFlush) {
      _seedPreSpeechBufferFromTrimmedFrames(keptFrameCount);
    }
    _resetCurrentSegmentState();
    return snippet;
  }

  int _computeKeptFrameCountAfterTrim() {
    final trimFrames = _trailingSilenceFrames - _postSpeechFrames;
    if (trimFrames <= 0) {
      return _segmentFrames.length;
    }
    final boundedTrimFrames = trimFrames > _segmentFrames.length
        ? _segmentFrames.length
        : trimFrames;
    return _segmentFrames.length - boundedTrimFrames;
  }

  void _seedPreSpeechBufferFromTrimmedFrames(int keptFrameCount) {
    if (_preSpeechFrames == 0) {
      return;
    }
    _preSpeechFrameQueue.clear();
    for (var i = keptFrameCount; i < _segmentFrames.length; i++) {
      _pushPreSpeechFrame(_segmentFrames[i]);
    }
  }

  void _pushPreSpeechFrame(Uint8List frameBytes) {
    if (_preSpeechFrames == 0) {
      return;
    }
    _preSpeechFrameQueue.add(frameBytes);
    while (_preSpeechFrameQueue.length > _preSpeechFrames) {
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

Uint8List _ensureEvenByteOffset(Uint8List bytes) {
  if (bytes.offsetInBytes.isEven) {
    return bytes;
  }

  final aligned = Uint8List(bytes.lengthInBytes);
  aligned.setRange(0, aligned.lengthInBytes, bytes);
  return aligned;
}

Uint8List _flattenFrames(List<Uint8List> frames, {Uint8List? trailingPartialBytes}) {
  final totalFrameBytes = frames.fold<int>(0, (sum, frame) => sum + frame.lengthInBytes);
  final trailingBytesLength = trailingPartialBytes?.lengthInBytes ?? 0;
  final flattened = Uint8List(totalFrameBytes + trailingBytesLength);

  var offset = 0;
  for (final frame in frames) {
    flattened.setRange(offset, offset + frame.lengthInBytes, frame);
    offset += frame.lengthInBytes;
  }
  if (trailingPartialBytes != null && trailingPartialBytes.isNotEmpty) {
    flattened.setRange(offset, offset + trailingPartialBytes.lengthInBytes, trailingPartialBytes);
  }

  return flattened;
}

int _atLeastOne(int value) => value <= 0 ? 1 : value;
