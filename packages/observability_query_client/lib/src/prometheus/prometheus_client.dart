import '../transport.dart';
import 'prometheus_models.dart';

/// Read-only client for the Prometheus HTTP query API.
final class PrometheusClient {
  const PrometheusClient(this._http);

  final ObservabilityHttpClient _http;

  Future<PrometheusQueryResult> query(
    String expression, {
    DateTime? time,
    Duration? timeout,
    int? limit,
  }) => _query('/api/v1/query', expression, {
    if (time != null) 'time': [unixSeconds(time)],
    if (timeout != null) 'timeout': ['${timeout.inMilliseconds}ms'],
    if (limit != null) 'limit': ['$limit'],
  });

  Future<PrometheusQueryResult> queryRange(
    String expression, {
    required DateTime start,
    required DateTime end,
    required Duration step,
    Duration? timeout,
    int? limit,
  }) => _query('/api/v1/query_range', expression, {
    'start': [unixSeconds(start)],
    'end': [unixSeconds(end)],
    'step': ['${step.inMilliseconds}ms'],
    if (timeout != null) 'timeout': ['${timeout.inMilliseconds}ms'],
    if (limit != null) 'limit': ['$limit'],
  });

  Future<List<String>> metricNames({DateTime? start, DateTime? end}) =>
      _stringList('/api/v1/label/__name__/values', _range(start, end));

  Future<List<String>> labelNames({DateTime? start, DateTime? end}) =>
      _stringList('/api/v1/labels', _range(start, end));

  Future<List<String>> labelValues(String labelName, {DateTime? start, DateTime? end}) =>
      _stringList('/api/v1/label/${Uri.encodeComponent(labelName)}/values', _range(start, end));

  Future<List<Map<String, String>>> series({
    required List<String> matchers,
    DateTime? start,
    DateTime? end,
  }) async {
    if (matchers.isEmpty) {
      throw ArgumentError.value(matchers, 'matchers', 'At least one matcher is required.');
    }
    final response = await _http.getJsonWithQuery(
      '/api/v1/series',
      queryParameters: {'match[]': matchers, ..._range(start, end)},
    );
    final data = _data(response);
    return expectJsonList(data, 'Prometheus series')
        .map(
          (item) => expectJsonObject(
            item,
            'Prometheus series item',
          ).map((key, value) => MapEntry(key, '$value')),
        )
        .toList(growable: false);
  }

  Future<PrometheusQueryResult> _query(
    String path,
    String expression,
    Map<String, List<String>> parameters,
  ) async => PrometheusQueryResult.fromJson(
    await _http.getJsonWithQuery(
      path,
      queryParameters: {
        'query': [expression],
        ...parameters,
      },
    ),
  );

  Future<List<String>> _stringList(String path, Map<String, List<String>> parameters) async =>
      expectJsonList(
        _data(await _http.getJsonWithQuery(path, queryParameters: parameters)),
        'Prometheus data',
      ).map((item) => item.toString()).toList(growable: false);
}

Object? _data(Object? response) {
  final envelope = expectJsonObject(response, 'Prometheus');
  if (envelope['status'] != 'success') {
    throw PrometheusApiException(
      errorType: envelope['errorType']?.toString(),
      message: envelope['error']?.toString() ?? 'Prometheus request failed.',
    );
  }
  return envelope['data'];
}

Map<String, List<String>> _range(DateTime? start, DateTime? end) => {
  if (start != null) 'start': [unixSeconds(start)],
  if (end != null) 'end': [unixSeconds(end)],
};
