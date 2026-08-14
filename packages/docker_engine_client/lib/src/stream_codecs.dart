import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'models.dart';

Stream<JsonObject> decodeJsonLines(Stream<List<int>> input) => input
    .transform(utf8.decoder)
    .transform(const LineSplitter())
    .where((line) => line.trim().isNotEmpty)
    .map((line) => jsonObject(jsonDecode(line), source: 'Docker stream'));

Stream<DockerLogEntry> decodeDockerMultiplexedLogs(Stream<List<int>> input) async* {
  var buffer = Uint8List(0);
  await for (final chunk in input) {
    final combined = Uint8List(buffer.length + chunk.length)
      ..setRange(0, buffer.length, buffer)
      ..setRange(buffer.length, buffer.length + chunk.length, chunk);
    buffer = combined;

    while (buffer.length >= 8) {
      final length = ByteData.sublistView(buffer, 4, 8).getUint32(0);
      if (buffer.length < 8 + length) break;
      final stream = switch (buffer[0]) {
        0 => DockerLogStream.stdin,
        1 => DockerLogStream.stdout,
        2 => DockerLogStream.stderr,
        _ => DockerLogStream.unknown,
      };
      yield DockerLogEntry(stream: stream, bytes: buffer.sublist(8, 8 + length));
      buffer = Uint8List.fromList(buffer.sublist(8 + length));
    }
  }
  if (buffer.isNotEmpty) {
    throw const FormatException('Docker multiplexed log stream ended with an incomplete frame.');
  }
}
