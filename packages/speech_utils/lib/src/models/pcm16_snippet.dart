import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

import '../utils/pcm16_audio_utils.dart';

/// A zero-copy view over a PCM16 snippet.
///
/// The snippet references the source buffer and only materializes views for
/// byte/sample access.
final class Pcm16Snippet {
  const Pcm16Snippet({
    required this.sourceBuffer,
    required this.sourceByteOffset,
    required this.startSampleOffset,
    required this.endSampleOffsetExclusive,
    required this.sampleRateHz,
    required this.channelCount,
    this.speechFrameCount,
    this.analyzedFrameCount,
  }) : assert(startSampleOffset >= 0),
       assert(endSampleOffsetExclusive >= startSampleOffset),
       assert(sampleRateHz > 0),
       assert(channelCount > 0),
       assert(speechFrameCount == null || speechFrameCount >= 0),
       assert(analyzedFrameCount == null || analyzedFrameCount >= 0),
       assert(
         speechFrameCount == null ||
             analyzedFrameCount == null ||
             speechFrameCount <= analyzedFrameCount,
       );

  final ByteBuffer sourceBuffer;
  final int sourceByteOffset;
  final int startSampleOffset;
  final int endSampleOffsetExclusive;
  final int sampleRateHz;
  final int channelCount;
  final int? speechFrameCount;
  final int? analyzedFrameCount;

  int get sampleCount => endSampleOffsetExclusive - startSampleOffset;
  int get frameCount => sampleCount ~/ channelCount;
  int get byteOffset => sourceByteOffset + (startSampleOffset * 2);
  int get byteLength => sampleCount * 2;

  Duration get duration {
    final micros = (frameCount * Duration.microsecondsPerSecond / sampleRateHz).round();
    return Duration(microseconds: micros);
  }

  /// Probability estimate from the original VAD segmentation pass when
  /// available, represented as `speechFrames / analyzedFrames`.
  double? get speechProbability {
    final speech = speechFrameCount;
    final analyzed = analyzedFrameCount;
    if (speech == null || analyzed == null || analyzed <= 0) {
      return null;
    }
    return speech / analyzed;
  }

  Int16List asSamplesView() {
    return Int16List.view(sourceBuffer, byteOffset, sampleCount);
  }

  Uint8List asBytesView() {
    return Uint8List.view(sourceBuffer, byteOffset, byteLength);
  }

  Future<XFile> writeRawPcm16(String path) async {
    final file = File(path);
    final sink = file.openWrite();
    sink.add(asBytesView());
    await sink.close();
    return XFile(path);
  }

  Future<XFile> writeWav(String path) async {
    final file = File(path);
    final sink = file.openWrite();
    sink.add(
      Pcm16AudioUtils.buildPcm16WavHeader(
        sampleRateHz: sampleRateHz,
        channelCount: channelCount,
        pcmDataByteLength: byteLength,
      ),
    );
    sink.add(asBytesView());
    await sink.close();
    return XFile(path, mimeType: 'audio/wav');
  }
}
