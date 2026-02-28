import 'dart:math' as math;
import 'dart:typed_data';

/// Utilities for PCM16 buffer normalization and basic metrics.
final class Pcm16AudioUtils {
  Pcm16AudioUtils._();

  static const int bytesPerSample = 2;
  static const double minDbfs = -90.0;
  static const double maxDbfs = 0.0;

  /// Returns an [Int16List] view over [pcm16Bytes] with optional byte offset/length.
  ///
  /// If the start offset is not aligned, the method returns an aligned copy.
  static Int16List asAlignedInt16List(
    Uint8List pcm16Bytes, {
    int byteOffset = 0,
    int? byteLength,
  }) {
    if (byteOffset < 0 || byteOffset > pcm16Bytes.lengthInBytes) {
      throw ArgumentError.value(
        byteOffset,
        'byteOffset',
        'Must be in range [0, ${pcm16Bytes.lengthInBytes}]',
      );
    }

    final effectiveByteLength = byteLength ?? (pcm16Bytes.lengthInBytes - byteOffset);
    if (effectiveByteLength < 0 || byteOffset + effectiveByteLength > pcm16Bytes.lengthInBytes) {
      throw ArgumentError.value(
        byteLength,
        'byteLength',
        'Invalid byte length for the given offset',
      );
    }

    if (effectiveByteLength == 0) {
      return Int16List(0);
    }

    if (effectiveByteLength.isOdd) {
      throw ArgumentError.value(
        byteLength,
        'byteLength',
        'PCM16 payload must have an even byte size',
      );
    }

    final absoluteByteOffset = pcm16Bytes.offsetInBytes + byteOffset;
    if (absoluteByteOffset.isEven) {
      return Int16List.view(
        pcm16Bytes.buffer,
        absoluteByteOffset,
        effectiveByteLength ~/ bytesPerSample,
      );
    }

    final aligned = Uint8List(effectiveByteLength);
    aligned.setRange(0, effectiveByteLength, pcm16Bytes, byteOffset);
    return Int16List.view(aligned.buffer, aligned.offsetInBytes, effectiveByteLength ~/ bytesPerSample);
  }

  /// Ensures that a byte buffer uses an even address offset.
  static Uint8List ensureEvenByteOffset(Uint8List bytes) {
    if (bytes.offsetInBytes.isEven) {
      return bytes;
    }

    final aligned = Uint8List(bytes.lengthInBytes);
    aligned.setRange(0, aligned.lengthInBytes, bytes);
    return aligned;
  }

  /// Returns RMS over normalized PCM16 bytes.
  static double rms(Uint8List pcm16Bytes) {
    final sampleCount = pcm16Bytes.lengthInBytes ~/ bytesPerSample;
    if (sampleCount <= 0) {
      return 0.0;
    }

    final samples = Int16List.view(pcm16Bytes.buffer, pcm16Bytes.offsetInBytes, sampleCount);
    var sumSquares = 0.0;
    for (final sample in samples) {
      final normalized = sample / 32768.0;
      sumSquares += normalized * normalized;
    }

    if (sumSquares <= 0) {
      return 0.0;
    }
    return math.sqrt(sumSquares / sampleCount);
  }

  /// Returns dBFS over normalized PCM16 bytes.
  static double dbfs(Uint8List pcm16Bytes, {double silenceDbfs = minDbfs}) {
    final rms = Pcm16AudioUtils.rms(pcm16Bytes);
    if (rms <= 0) {
      return silenceDbfs;
    }

    final dbfs = 20.0 * math.log(rms) / math.ln10;
    if (!dbfs.isFinite) {
      return silenceDbfs;
    }

    return dbfs.clamp(minDbfs, maxDbfs);
  }

  /// Concatenates frame buffers and optional trailing bytes.
  static Uint8List concatByteBlocks(List<Uint8List> blocks, {Uint8List? trailing}) {
    final trailingLength = trailing?.lengthInBytes ?? 0;
    final totalLength = blocks.fold<int>(0, (sum, frame) => sum + frame.lengthInBytes) + trailingLength;
    if (totalLength == 0) {
      return Uint8List(0);
    }

    final flattened = Uint8List(totalLength);
    var offset = 0;
    for (final frame in blocks) {
      flattened.setRange(offset, offset + frame.lengthInBytes, frame);
      offset += frame.lengthInBytes;
    }

    if (trailing != null && trailingLength > 0) {
      flattened.setRange(offset, offset + trailingLength, trailing);
    }

    return flattened;
  }

  static Uint8List buildPcm16WavHeader({
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

  /// Keeps shared metadata normalization behavior for native metadata readers.
  static int? toOptionalPositive(int? value) => (value == null || value <= 0) ? null : value;

  /// Keeps shared text normalization behavior for native metadata readers.
  static String? toOptionalText(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
