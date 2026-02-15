import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_bluetooth_client/hippo_bluetooth_client.dart';

void main() {
  test('reassembles out-of-order frames', () {
    final reassembler = ChunkReassembler();

    final frame1 = ChunkFrame(
      version: chunkWireVersion,
      sequence: 9,
      totalChunks: 2,
      chunkIndex: 1,
      payload: Uint8List.fromList(<int>[3, 4]),
    );
    final frame0 = ChunkFrame(
      version: chunkWireVersion,
      sequence: 9,
      totalChunks: 2,
      chunkIndex: 0,
      payload: Uint8List.fromList(<int>[1, 2]),
    );

    final first = reassembler.addFrame(sessionId: 's1', frame: frame1);
    final second = reassembler.addFrame(sessionId: 's1', frame: frame0);

    expect(first, isNull);
    expect(second, <int>[1, 2, 3, 4]);
  });

  test('ignores duplicate chunk with same payload', () {
    final reassembler = ChunkReassembler();
    final frame = ChunkFrame(
      version: chunkWireVersion,
      sequence: 1,
      totalChunks: 2,
      chunkIndex: 0,
      payload: Uint8List.fromList(<int>[1]),
    );

    final first = reassembler.addFrame(sessionId: 's1', frame: frame);
    final duplicate = reassembler.addFrame(sessionId: 's1', frame: frame);

    expect(first, isNull);
    expect(duplicate, isNull);
  });

  test('throws on duplicate chunk with different payload', () {
    final reassembler = ChunkReassembler();
    final frameA = ChunkFrame(
      version: chunkWireVersion,
      sequence: 1,
      totalChunks: 2,
      chunkIndex: 0,
      payload: Uint8List.fromList(<int>[1]),
    );
    final frameB = ChunkFrame(
      version: chunkWireVersion,
      sequence: 1,
      totalChunks: 2,
      chunkIndex: 0,
      payload: Uint8List.fromList(<int>[2]),
    );

    reassembler.addFrame(sessionId: 's1', frame: frameA);

    expect(
      () => reassembler.addFrame(sessionId: 's1', frame: frameB),
      throwsA(isA<ChunkError>()),
    );
  });
}
