import '../transport.dart';

enum PrometheusResultType { vector, matrix, scalar, string }

final class PrometheusSample {
  const PrometheusSample({required this.timestamp, required this.value});

  final double timestamp;
  final String value;

  factory PrometheusSample.fromJson(Object? value) {
    final values = expectJsonList(value, 'Prometheus sample');
    if (values.length != 2) {
      throw const FormatException('Prometheus sample must contain timestamp and value.');
    }
    return PrometheusSample(timestamp: _number(values[0]), value: values[1].toString());
  }
}

final class PrometheusSeries {
  const PrometheusSeries({required this.labels, required this.values});

  final Map<String, String> labels;
  final List<PrometheusSample> values;
}

final class PrometheusQueryResult {
  const PrometheusQueryResult({required this.type, required this.series, required this.warnings});

  final PrometheusResultType type;
  final List<PrometheusSeries> series;
  final List<String> warnings;

  factory PrometheusQueryResult.fromJson(Object? response) {
    final envelope = expectJsonObject(response, 'Prometheus');
    if (envelope['status'] != 'success') {
      throw PrometheusApiException(
        errorType: envelope['errorType']?.toString(),
        message: envelope['error']?.toString() ?? 'Prometheus query failed.',
      );
    }
    final data = expectJsonObject(envelope['data'], 'Prometheus data');
    final type = PrometheusResultType.values.byName(data['resultType'].toString());
    final result = data['result'];
    final series = switch (type) {
      PrometheusResultType.vector => _vector(result),
      PrometheusResultType.matrix => _matrix(result),
      PrometheusResultType.scalar || PrometheusResultType.string => [
        PrometheusSeries(labels: const {}, values: [PrometheusSample.fromJson(result)]),
      ],
    };
    return PrometheusQueryResult(
      type: type,
      series: series,
      warnings: (envelope['warnings'] as List<Object?>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

final class PrometheusApiException implements Exception {
  const PrometheusApiException({required this.message, this.errorType});

  final String message;
  final String? errorType;

  @override
  String toString() => 'PrometheusApiException($errorType): $message';
}

List<PrometheusSeries> _vector(Object? value) => expectJsonList(value, 'Prometheus vector')
    .map((item) {
      final itemMap = expectJsonObject(item, 'Prometheus vector item');
      return PrometheusSeries(
        labels: _labels(itemMap['metric']),
        values: [PrometheusSample.fromJson(itemMap['value'])],
      );
    })
    .toList(growable: false);

List<PrometheusSeries> _matrix(Object? value) => expectJsonList(value, 'Prometheus matrix')
    .map((item) {
      final itemMap = expectJsonObject(item, 'Prometheus matrix item');
      return PrometheusSeries(
        labels: _labels(itemMap['metric']),
        values: expectJsonList(
          itemMap['values'],
          'Prometheus matrix values',
        ).map(PrometheusSample.fromJson).toList(growable: false),
      );
    })
    .toList(growable: false);

Map<String, String> _labels(Object? value) => expectJsonObject(
  value,
  'Prometheus labels',
).map((key, value) => MapEntry(key, value.toString()));

double _number(Object? value) => switch (value) {
  num() => value.toDouble(),
  String() => double.parse(value),
  _ => throw FormatException('Expected numeric timestamp, got $value.'),
};
