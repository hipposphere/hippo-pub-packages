import '../transport.dart';
import 'loki_models.dart';

/// Read-only client for Loki LogQL query and label-discovery APIs.
final class LokiClient {
  const LokiClient(this._http);

  final ObservabilityHttpClient _http;

  Future<LokiQueryResult> queryRange(
    String expression, {
    required DateTime start,
    required DateTime end,
    int? limit,
    LokiDirection direction = LokiDirection.backward,
  }) async => LokiQueryResult.fromJson(
    await _http.getJsonWithQuery(
      '/loki/api/v1/query_range',
      queryParameters: {
        'query': [expression],
        'start': [unixSeconds(start)],
        'end': [unixSeconds(end)],
        'direction': [direction.name.toUpperCase()],
        if (limit != null) 'limit': ['$limit'],
      },
    ),
  );

  Future<List<String>> labelNames({DateTime? start, DateTime? end}) =>
      _stringList('/loki/api/v1/labels', _range(start, end));

  Future<List<String>> labelValues(String labelName, {DateTime? start, DateTime? end}) =>
      _stringList(
        '/loki/api/v1/label/${Uri.encodeComponent(labelName)}/values',
        _range(start, end),
      );

  Future<List<String>> _stringList(String path, Map<String, List<String>> parameters) async {
    final response = expectJsonObject(
      await _http.getJsonWithQuery(path, queryParameters: parameters),
      'Loki',
    );
    if (response['status'] != 'success') {
      throw LokiApiException(response['error']?.toString() ?? 'Loki request failed.');
    }
    return expectJsonList(
      response['data'],
      'Loki data',
    ).map((item) => '$item').toList(growable: false);
  }
}

enum LokiDirection { forward, backward }

Map<String, List<String>> _range(DateTime? start, DateTime? end) => {
  if (start != null) 'start': [unixSeconds(start)],
  if (end != null) 'end': [unixSeconds(end)],
};
