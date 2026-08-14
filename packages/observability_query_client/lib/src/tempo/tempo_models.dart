import '../transport.dart';

final class TempoTraceSummary {
  const TempoTraceSummary({
    required this.traceId,
    required this.rootServiceName,
    required this.rootTraceName,
    required this.startTimeUnixNano,
    required this.durationMs,
  });

  final String traceId;
  final String? rootServiceName;
  final String? rootTraceName;
  final String? startTimeUnixNano;
  final num? durationMs;

  factory TempoTraceSummary.fromJson(Object? value) {
    final json = expectJsonObject(value, 'Tempo trace summary');
    return TempoTraceSummary(
      traceId:
          json['traceID']?.toString() ??
          (throw const FormatException('Tempo trace has no traceID.')),
      rootServiceName: json['rootServiceName']?.toString(),
      rootTraceName: json['rootTraceName']?.toString(),
      startTimeUnixNano: json['startTimeUnixNano']?.toString(),
      durationMs: json['durationMs'] as num?,
    );
  }
}

final class TempoSearchResult {
  const TempoSearchResult({required this.traces});

  final List<TempoTraceSummary> traces;

  factory TempoSearchResult.fromJson(Object? value) {
    final json = expectJsonObject(value, 'Tempo search');
    return TempoSearchResult(
      traces: expectJsonList(
        json['traces'],
        'Tempo traces',
      ).map(TempoTraceSummary.fromJson).toList(growable: false),
    );
  }
}
