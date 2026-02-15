import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_bluetooth_client/hippo_bluetooth_client.dart';

void main() {
  test('encode/decode chunk frame uses big-endian wire format', () {
    final frame = ChunkFrame(
      version: chunkWireVersion,
      sequence: 0x10203040,
      totalChunks: 3,
      chunkIndex: 1,
      payload: Uint8List.fromList(<int>[9, 8, 7]),
    );

    final encoded = encodeChunkFrame(frame);
    final decoded = decodeChunkFrame(encoded);

    expect(decoded.version, chunkWireVersion);
    expect(decoded.sequence, 0x10203040);
    expect(decoded.totalChunks, 3);
    expect(decoded.chunkIndex, 1);
    expect(decoded.payload, <int>[9, 8, 7]);
  });

  test('chunkPayload splits into expected chunks', () {
    final payload = Uint8List.fromList(
      List<int>.generate(10, (index) => index),
    );
    final chunks = chunkPayload(payload, maxChunkPayloadSize: 4);

    expect(chunks.length, 3);
    expect(chunks[0], <int>[0, 1, 2, 3]);
    expect(chunks[1], <int>[4, 5, 6, 7]);
    expect(chunks[2], <int>[8, 9]);
  });

  test('decodeChunkFrame throws on short frame', () {
    expect(
      () => decodeChunkFrame(Uint8List.fromList(<int>[1, 2, 3])),
      throwsA(isA<ChunkError>()),
    );
  });

  test('chunkPayload throws when max chunk size is invalid', () {
    expect(
      () => chunkPayload(Uint8List(1), maxChunkPayloadSize: 0),
      throwsA(isA<ChunkError>()),
    );
  });
}
