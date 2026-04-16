import 'dart:convert';
import 'dart:typed_data';

import 'axum_http.dart';
import 'axum_openapi.dart';

abstract interface class AxumBodyDecoder<T> {
  const AxumBodyDecoder();

  T decode(AxumIncomingBody body);

  String? get contentType;

  AxumSchema? get schema;
}

abstract interface class AxumBodyEncoder<T> {
  const AxumBodyEncoder();

  AxumResponse encode(
    T value, {
    int statusCode = 200,
    Map<String, String> headers = const <String, String>{},
  });

  String? get contentType;

  AxumSchema? get schema;
}

final class AxumJsonCodec<T> implements AxumBodyDecoder<T>, AxumBodyEncoder<T> {
  const AxumJsonCodec({
    required this.decodeJson,
    required this.encodeJson,
    this.schema,
    this.contentType = 'application/json; charset=utf-8',
  });

  final T Function(Object? value) decodeJson;
  final Object? Function(T value) encodeJson;

  @override
  final AxumSchema? schema;

  @override
  final String contentType;

  @override
  T decode(AxumIncomingBody body) {
    return decodeJson(body.json());
  }

  @override
  AxumResponse encode(
    T value, {
    int statusCode = 200,
    Map<String, String> headers = const <String, String>{},
  }) {
    return AxumResponse(
      statusCode: statusCode,
      body: Uint8List.fromList(utf8.encode(jsonEncode(encodeJson(value)))),
      headers: {
        'content-type': <String>[contentType],
        ...singleValueHeaders(headers),
      },
    );
  }
}

final class AxumTextCodec implements AxumBodyDecoder<String>, AxumBodyEncoder<String> {
  const AxumTextCodec({
    this.schema = const AxumSchema.string(),
    this.contentType = 'text/plain; charset=utf-8',
    this.encoding = utf8,
  });

  @override
  final AxumSchema? schema;

  @override
  final String contentType;

  final Encoding encoding;

  @override
  String decode(AxumIncomingBody body) => body.text(encoding: encoding);

  @override
  AxumResponse encode(
    String value, {
    int statusCode = 200,
    Map<String, String> headers = const <String, String>{},
  }) {
    return AxumResponse.text(
      value,
      statusCode: statusCode,
      contentType: contentType,
      headers: headers,
    );
  }
}

final class AxumBinaryCodec implements AxumBodyDecoder<Uint8List>, AxumBodyEncoder<Uint8List> {
  const AxumBinaryCodec({
    this.schema = const AxumSchema.string(format: 'binary'),
    this.contentType = 'application/octet-stream',
  });

  @override
  final AxumSchema? schema;

  @override
  final String contentType;

  @override
  Uint8List decode(AxumIncomingBody body) => Uint8List.fromList(body.bytes);

  @override
  AxumResponse encode(
    Uint8List value, {
    int statusCode = 200,
    Map<String, String> headers = const <String, String>{},
  }) {
    return AxumResponse.bytes(
      value,
      statusCode: statusCode,
      contentType: contentType,
      headers: headers,
    );
  }
}
