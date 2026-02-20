import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

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
      _buildPcm16WavHeader(
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

Uint8List _buildPcm16WavHeader({
  required int sampleRateHz,
  required int channelCount,
  required int pcmDataByteLength,
}) {
  final header = Uint8List(44);
  final data = ByteData.sublistView(header);

  void writeAscii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      header[offset + i] = value.codeUnitAt(i);
    }
  }

  final byteRate = sampleRateHz * channelCount * 2;
  final blockAlign = channelCount * 2;
  final riffChunkSize = 36 + pcmDataByteLength;

  writeAscii(0, 'RIFF');
  data.setUint32(4, riffChunkSize, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, channelCount, Endian.little);
  data.setUint32(24, sampleRateHz, Endian.little);
  data.setUint32(28, byteRate, Endian.little);
  data.setUint16(32, blockAlign, Endian.little);
  data.setUint16(34, 16, Endian.little);
  writeAscii(36, 'data');
  data.setUint32(40, pcmDataByteLength, Endian.little);

  return header;
}
