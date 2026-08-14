import '../transport.dart';
import 'tempo_models.dart';

/// Read-only client for Tempo trace retrieval, TraceQL search, and tag discovery.
final class TempoClient {
  const TempoClient(this._http);

  final ObservabilityHttpClient _http;

  Future<Map<String, Object?>> traceById(String traceId, {DateTime? start, DateTime? end}) async =>
      expectJsonObject(
        await _http.getJsonWithQuery(
          '/api/v2/traces/${Uri.encodeComponent(traceId)}',
          queryParameters: _range(start, end),
        ),
        'Tempo trace',
      );

  Future<TempoSearchResult> search(
    String traceQl, {
    DateTime? start,
    DateTime? end,
    int? limit,
  }) async => TempoSearchResult.fromJson(
    await _http.getJsonWithQuery(
      '/api/search',
      queryParameters: {
        'q': [traceQl],
        ..._range(start, end),
        if (limit != null) 'limit': ['$limit'],
      },
    ),
  );

  Future<List<String>> tagNames({
    TempoTagScope? scope,
    DateTime? start,
    DateTime? end,
    int? limit,
  }) async {
    final data = expectJsonObject(
      await _http.getJsonWithQuery(
        '/api/v2/search/tags',
        queryParameters: {
          if (scope != null) 'scope': [scope.name],
          ..._range(start, end),
          if (limit != null) 'limit': ['$limit'],
        },
      ),
      'Tempo tag names',
    );
    return [
      for (final item in expectJsonList(data['scopes'], 'Tempo tag scopes'))
        for (final tag in expectJsonList(
          expectJsonObject(item, 'Tempo tag scope')['tags'],
          'Tempo tags',
        ))
          _qualifiedTag(
            expectJsonObject(item, 'Tempo tag scope')['name'].toString(),
            tag.toString(),
          ),
    ];
  }

  Future<List<String>> tagValues(
    String tag, {
    DateTime? start,
    DateTime? end,
    String? traceQl,
    int? limit,
  }) async {
    final data = expectJsonObject(
      await _http.getJsonWithQuery(
        '/api/v2/search/tag/${Uri.encodeComponent(tag)}/values',
        queryParameters: {
          ..._range(start, end),
          if (traceQl != null) 'q': [traceQl],
          if (limit != null) 'limit': ['$limit'],
        },
      ),
      'Tempo tag values',
    );
    return expectJsonList(data['tagValues'], 'Tempo tag values')
        .map((item) => expectJsonObject(item, 'Tempo tag value')['value'].toString())
        .toList(growable: false);
  }
}

String _qualifiedTag(String scope, String name) => switch (scope) {
  'intrinsic' => name,
  'event' when name.contains(':') => name,
  _ => '$scope.$name',
};

enum TempoTagScope { resource, span, intrinsic, event, link, instrumentation }

Map<String, List<String>> _range(DateTime? start, DateTime? end) => {
  if (start != null) 'start': [unixSeconds(start)],
  if (end != null) 'end': [unixSeconds(end)],
};
