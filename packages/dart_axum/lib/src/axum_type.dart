import 'dart:convert';
import 'dart:typed_data';

import 'axum_codec.dart';
import 'axum_http.dart';
import 'axum_openapi.dart';

abstract interface class AxumOpenApiComponentProvider {
  const AxumOpenApiComponentProvider();

  Iterable<AxumSchemaComponent> get components;
}

abstract interface class AxumType<T>
    implements AxumBodyDecoder<T>, AxumBodyEncoder<T>, AxumOpenApiComponentProvider {
  const AxumType();
}

final class AxumJsonType<T> implements AxumType<T> {
  const AxumJsonType({
    required this.decodeJson,
    required this.encodeJson,
    required this.schema,
    List<AxumSchemaComponent> components = const <AxumSchemaComponent>[],
    this.contentType = 'application/json; charset=utf-8',
  }) : _primaryComponent = null,
       _components = components;

  AxumJsonType.component({
    required this.decodeJson,
    required this.encodeJson,
    required AxumSchemaComponent component,
    List<AxumSchemaComponent> components = const <AxumSchemaComponent>[],
    this.contentType = 'application/json; charset=utf-8',
  }) : schema = AxumSchema.referenceComponent(component.name),
       _primaryComponent = component,
       _components = components;

  final T Function(Object? value) decodeJson;
  final Object? Function(T value) encodeJson;

  @override
  final AxumSchema schema;

  @override
  final String contentType;

  final AxumSchemaComponent? _primaryComponent;
  final List<AxumSchemaComponent> _components;

  AxumSchema get definitionSchema => _primaryComponent?.schema ?? schema;

  @override
  Iterable<AxumSchemaComponent> get components sync* {
    if (_primaryComponent != null) {
      yield _primaryComponent;
    }
    yield* _components;
  }

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
      headers: <String, List<String>>{
        'content-type': <String>[contentType],
        ...singleValueHeaders(headers),
      },
    );
  }
}
