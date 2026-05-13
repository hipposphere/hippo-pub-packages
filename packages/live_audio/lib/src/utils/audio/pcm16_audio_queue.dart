import 'dart:async';
import 'dart:typed_data';

final class Pcm16AudioQueue {
  Pcm16AudioQueue({
    this.sampleRate = 24000,
    this.channels = 1,
    this.frameDuration = const Duration(milliseconds: 20),
    this.emitFixedFrames = true,
  }) : _controller = StreamController<Uint8List>(sync: true);

  final int sampleRate;
  final int channels;
  final Duration frameDuration;
  final bool emitFixedFrames;
  final StreamController<Uint8List> _controller;
  final List<int> _buffer = <int>[];
  var _closed = false;

  Stream<Uint8List> get stream => _controller.stream;

  int get bytesPerSample => 2;

  int get frameSizeBytes {
    final samplesPerFrame = (sampleRate * frameDuration.inMicroseconds) ~/ 1000000;
    return samplesPerFrame * channels * bytesPerSample;
  }

  void add(List<int> chunk) {
    if (_closed || chunk.isEmpty) {
      return;
    }
    if (!emitFixedFrames) {
      _controller.add(Uint8List.fromList(chunk));
      return;
    }

    _buffer.addAll(chunk);
    final size = frameSizeBytes;
    while (_buffer.length >= size) {
      _controller.add(Uint8List.fromList(_buffer.take(size).toList(growable: false)));
      _buffer.removeRange(0, size);
    }
  }

  Future<void> addStream(Stream<List<int>> chunks) async {
    await for (final chunk in chunks) {
      add(chunk);
    }
  }

  Future<void> close({bool flush = true}) async {
    if (_closed) {
      return;
    }
    _closed = true;
    if (flush && _buffer.isNotEmpty) {
      final evenLength = _buffer.length - (_buffer.length % bytesPerSample);
      if (evenLength > 0) {
        _controller.add(Uint8List.fromList(_buffer.take(evenLength).toList(growable: false)));
      }
    }
    _buffer.clear();
    await _controller.close();
  }
}
