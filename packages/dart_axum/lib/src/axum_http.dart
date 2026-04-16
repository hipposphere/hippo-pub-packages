import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

Map<String, List<String>> freezeStringMultiMap(
  Map<String, List<String>> values, {
  bool lowercaseKeys = true,
}) {
  final normalized = <String, List<String>>{};
  for (final entry in values.entries) {
    final key = lowercaseKeys ? entry.key.toLowerCase() : entry.key;
    normalized[key] = List<String>.unmodifiable(entry.value);
  }
  return UnmodifiableMapView<String, List<String>>(normalized);
}

Map<String, List<String>> singleValueHeaders(Map<String, String> values) {
  return {
    for (final entry in values.entries) entry.key: <String>[entry.value],
  };
}

enum AxumMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE'),
  options('OPTIONS'),
  head('HEAD');

  const AxumMethod(this.value);

  final String value;

  static AxumMethod parse(String value) {
    final upper = value.toUpperCase();
    return AxumMethod.values.firstWhere(
      (method) => method.value == upper,
      orElse: () => throw ArgumentError.value(value, 'value', 'Unsupported HTTP method'),
    );
  }
}

final class AxumHeaders {
  AxumHeaders(Map<String, List<String>> values) : _values = freezeStringMultiMap(values);

  final Map<String, List<String>> _values;

  Map<String, List<String>> get values => _values;

  String? first(String name) {
    final value = _values[name.toLowerCase()];
    if (value == null || value.isEmpty) {
      return null;
    }
    return value.first;
  }

  List<String> operator [](String name) => _values[name.toLowerCase()] ?? const <String>[];

  bool contains(String name) => _values.containsKey(name.toLowerCase());
}

final class AxumIncomingBody {
  AxumIncomingBody(Uint8List bytes) : bytes = Uint8List.fromList(bytes);

  final Uint8List bytes;

  bool get isEmpty => bytes.isEmpty;

  String text({Encoding encoding = utf8}) => encoding.decode(bytes);

  Object? json() => jsonDecode(text());
}

final class AxumResponse {
  AxumResponse({
    required this.statusCode,
    Uint8List? body,
    Map<String, List<String>> headers = const <String, List<String>>{},
  }) : body = Uint8List.fromList(body ?? Uint8List(0)),
       headers = freezeStringMultiMap(headers);

  factory AxumResponse.empty({
    int statusCode = 204,
    Map<String, String> headers = const <String, String>{},
  }) {
    return AxumResponse(statusCode: statusCode, headers: singleValueHeaders(headers));
  }

  factory AxumResponse.text(
    String value, {
    int statusCode = 200,
    String contentType = 'text/plain; charset=utf-8',
    Map<String, String> headers = const <String, String>{},
  }) {
    return AxumResponse(
      statusCode: statusCode,
      body: Uint8List.fromList(utf8.encode(value)),
      headers: {
        'content-type': <String>[contentType],
        ...singleValueHeaders(headers),
      },
    );
  }

  factory AxumResponse.html(
    String value, {
    int statusCode = 200,
    String contentType = 'text/html; charset=utf-8',
    Map<String, String> headers = const <String, String>{},
  }) {
    return AxumResponse.text(
      value,
      statusCode: statusCode,
      contentType: contentType,
      headers: headers,
    );
  }

  factory AxumResponse.json(
    Object? value, {
    int statusCode = 200,
    String contentType = 'application/json; charset=utf-8',
    Map<String, String> headers = const <String, String>{},
  }) {
    return AxumResponse(
      statusCode: statusCode,
      body: Uint8List.fromList(utf8.encode(jsonEncode(value))),
      headers: {
        'content-type': <String>[contentType],
        ...singleValueHeaders(headers),
      },
    );
  }

  factory AxumResponse.bytes(
    Uint8List value, {
    int statusCode = 200,
    String? contentType,
    Map<String, String> headers = const <String, String>{},
  }) {
    final normalizedHeaders = <String, List<String>>{
      ...singleValueHeaders(headers),
      if (contentType != null) 'content-type': <String>[contentType],
    };
    return AxumResponse(statusCode: statusCode, body: value, headers: normalizedHeaders);
  }

  final int statusCode;
  final Uint8List body;
  final Map<String, List<String>> headers;

  String? get contentType {
    final values = headers['content-type'];
    if (values == null || values.isEmpty) {
      return null;
    }
    return values.first;
  }
}

final class AxumHttpException implements Exception {
  AxumHttpException(
    this.statusCode, {
    this.message,
    this.body,
    this.headers = const <String, String>{},
    this.contentType,
  });

  final int statusCode;
  final String? message;
  final Object? body;
  final Map<String, String> headers;
  final String? contentType;

  AxumResponse toResponse() {
    final responseBody = body ?? <String, Object?>{'error': message ?? 'HTTP $statusCode'};
    if (responseBody is Uint8List) {
      return AxumResponse.bytes(
        responseBody,
        statusCode: statusCode,
        contentType: contentType,
        headers: headers,
      );
    }
    if (responseBody is String) {
      return AxumResponse.text(
        responseBody,
        statusCode: statusCode,
        contentType: contentType ?? 'text/plain; charset=utf-8',
        headers: headers,
      );
    }
    return AxumResponse.json(responseBody, statusCode: statusCode, headers: headers);
  }

  @override
  String toString() => 'AxumHttpException(statusCode: $statusCode, message: $message)';
}
