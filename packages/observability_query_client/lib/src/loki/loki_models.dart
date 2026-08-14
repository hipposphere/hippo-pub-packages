import '../transport.dart';

final class LokiLogEntry {
  const LokiLogEntry({required this.timestampNanoseconds, required this.line});

  final String timestampNanoseconds;
  final String line;
}

final class LokiStream {
  const LokiStream({required this.labels, required this.entries});

  final Map<String, String> labels;
  final List<LokiLogEntry> entries;
}

final class LokiQueryResult {
  const LokiQueryResult({required this.streams, required this.warnings});

  final List<LokiStream> streams;
  final List<String> warnings;

  factory LokiQueryResult.fromJson(Object? response) {
    final envelope = expectJsonObject(response, 'Loki');
    if (envelope['status'] != 'success') {
      throw LokiApiException(envelope['error']?.toString() ?? 'Loki query failed.');
    }
    final data = expectJsonObject(envelope['data'], 'Loki data');
    if (data['resultType'] != 'streams') {
      throw FormatException('Expected Loki streams result, got ${data['resultType']}.');
    }
    final streams = expectJsonList(data['result'], 'Loki streams')
        .map((item) {
          final stream = expectJsonObject(item, 'Loki stream');
          return LokiStream(
            labels: expectJsonObject(
              stream['stream'],
              'Loki labels',
            ).map((key, value) => MapEntry(key, '$value')),
            entries: expectJsonList(stream['values'], 'Loki values')
                .map((entry) {
                  final values = expectJsonList(entry, 'Loki log entry');
                  if (values.length < 2) {
                    throw const FormatException('Loki log entry must contain timestamp and line.');
                  }
                  return LokiLogEntry(timestampNanoseconds: '${values[0]}', line: '${values[1]}');
                })
                .toList(growable: false),
          );
        })
        .toList(growable: false);
    return LokiQueryResult(
      streams: streams,
      warnings: (envelope['warnings'] as List<Object?>? ?? const [])
          .map((item) => '$item')
          .toList(),
    );
  }
}

final class LokiApiException implements Exception {
  const LokiApiException(this.message);

  final String message;

  @override
  String toString() => 'LokiApiException: $message';
}
