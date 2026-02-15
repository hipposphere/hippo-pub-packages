import 'dart:typed_data';

import '../errors.dart';

/// Current chunk frame wire-version.
const int chunkWireVersion = 1;

/// Number of header bytes in each chunk frame.
const int chunkFrameHeaderSize = 9;

/// Wire-level frame for chunked payload transport.
class ChunkFrame {
  /// Wire format version.
  final int version;

  /// Sequence number (uint32 big-endian).
  final int sequence;

  /// Total chunk count (uint16 big-endian).
  final int totalChunks;

  /// Zero-based chunk index (uint16 big-endian).
  final int chunkIndex;

  /// Frame payload bytes.
  final Uint8List payload;

  /// Creates a [ChunkFrame].
  ChunkFrame({
    required this.version,
    required this.sequence,
    required this.totalChunks,
    required this.chunkIndex,
    required Uint8List payload,
  }) : payload = Uint8List.fromList(payload) {
    _validateFrame(this);
  }
}

/// Splits [payload] into fixed-size chunks.
///
/// Throws [ChunkError] if [maxChunkPayloadSize] is invalid or if the payload
/// would exceed uint16 chunk count constraints.
List<Uint8List> chunkPayload(
  Uint8List payload, {
  required int maxChunkPayloadSize,
}) {
  if (maxChunkPayloadSize <= 0) {
    throw const ChunkError('maxChunkPayloadSize must be greater than zero');
  }

  if (payload.isEmpty) {
    return <Uint8List>[Uint8List(0)];
  }

  final totalChunks = (payload.length / maxChunkPayloadSize).ceil();
  if (totalChunks > 0xFFFF) {
    throw ChunkError('Payload requires $totalChunks chunks, but max is 65535');
  }

  final out = <Uint8List>[];
  var offset = 0;
  while (offset < payload.length) {
    final end = (offset + maxChunkPayloadSize).clamp(0, payload.length);
    out.add(Uint8List.fromList(payload.sublist(offset, end)));
    offset = end;
  }
  return out;
}

/// Encodes a [ChunkFrame] into wire bytes.
Uint8List encodeChunkFrame(ChunkFrame frame) {
  _validateFrame(frame);

  final output = Uint8List(chunkFrameHeaderSize + frame.payload.length);
  final data = ByteData.sublistView(output);

  data.setUint8(0, frame.version);
  data.setUint32(1, frame.sequence, Endian.big);
  data.setUint16(5, frame.totalChunks, Endian.big);
  data.setUint16(7, frame.chunkIndex, Endian.big);
  output.setRange(chunkFrameHeaderSize, output.length, frame.payload);

  return output;
}

/// Decodes a wire-format chunk frame.
ChunkFrame decodeChunkFrame(Uint8List bytes) {
  if (bytes.length < chunkFrameHeaderSize) {
    throw ChunkError(
      'Chunk frame too short: ${bytes.length} bytes (minimum $chunkFrameHeaderSize)',
    );
  }

  final data = ByteData.sublistView(bytes);
  final frame = ChunkFrame(
    version: data.getUint8(0),
    sequence: data.getUint32(1, Endian.big),
    totalChunks: data.getUint16(5, Endian.big),
    chunkIndex: data.getUint16(7, Endian.big),
    payload: Uint8List.fromList(bytes.sublist(chunkFrameHeaderSize)),
  );

  return frame;
}

void _validateFrame(ChunkFrame frame) {
  if (frame.version != chunkWireVersion) {
    throw ChunkError(
      'Unsupported chunk version ${frame.version}. Expected $chunkWireVersion.',
    );
  }
  if (frame.sequence < 0 || frame.sequence > 0xFFFFFFFF) {
    throw ChunkError('Chunk sequence must fit uint32: ${frame.sequence}');
  }
  if (frame.totalChunks <= 0 || frame.totalChunks > 0xFFFF) {
    throw ChunkError(
      'totalChunks must be within 1..65535: ${frame.totalChunks}',
    );
  }
  if (frame.chunkIndex < 0 || frame.chunkIndex >= frame.totalChunks) {
    throw ChunkError(
      'chunkIndex must be within 0..${frame.totalChunks - 1}: ${frame.chunkIndex}',
    );
  }
}
