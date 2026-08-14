import 'dart:convert';

import 'package:http/http.dart' as http;

/// Shared, read-only HTTP transport for observability backends.
final class ObservabilityHttpClient {
  ObservabilityHttpClient({
    required Uri baseUri,
    required this.client,
    Map<String, String> headers = const {},
    this.timeout = const Duration(seconds: 10),
  }) : _baseUri = _normalizeBaseUri(baseUri),
       _headers = Map.unmodifiable(headers);

  final Uri _baseUri;
  final http.Client client;
  final Map<String, String> _headers;
  final Duration timeout;

  Future<Object?> getJson(String path) async {
    final response = await client
        .get(_baseUri.resolve(path.replaceFirst(RegExp(r'^/'), '')), headers: _headers)
        .timeout(timeout);
    final decoded = _decodeJson(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ObservabilityHttpException(
        statusCode: response.statusCode,
        uri: response.request?.url ?? _baseUri,
        body: decoded,
      );
    }
    return decoded;
  }

  Future<Object?> getJsonWithQuery(
    String path, {
    required Map<String, List<String>> queryParameters,
  }) async {
    final base = _baseUri.resolve(path.replaceFirst(RegExp(r'^/'), ''));
    final uri = base.replace(query: _encodeQuery(queryParameters));
    final response = await client.get(uri, headers: _headers).timeout(timeout);
    final decoded = _decodeJson(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ObservabilityHttpException(statusCode: response.statusCode, uri: uri, body: decoded);
    }
    return decoded;
  }

  static Uri _normalizeBaseUri(Uri uri) =>
      uri.path.endsWith('/') ? uri : uri.replace(path: '${uri.path}/');
}

String _encodeQuery(Map<String, List<String>> parameters) => parameters.entries
    .expand(
      (entry) => entry.value.map(
        (value) => '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(value)}',
      ),
    )
    .join('&');

final class ObservabilityHttpException implements Exception {
  const ObservabilityHttpException({
    required this.statusCode,
    required this.uri,
    required this.body,
  });

  final int statusCode;
  final Uri uri;
  final Object? body;

  @override
  String toString() => 'ObservabilityHttpException($statusCode, $uri)';
}

Object? _decodeJson(http.Response response) {
  if (response.body.isEmpty) return null;
  try {
    return jsonDecode(response.body);
  } on FormatException {
    return response.body;
  }
}

Map<String, Object?> expectJsonObject(Object? value, String source) {
  if (value is! Map) throw FormatException('$source did not return a JSON object.');
  return value.map((key, value) => MapEntry(key.toString(), value));
}

List<Object?> expectJsonList(Object? value, String source) {
  if (value is! List) throw FormatException('$source did not return a JSON list.');
  return List<Object?>.from(value);
}

String unixSeconds(DateTime value) => (value.toUtc().millisecondsSinceEpoch / 1000).toString();
