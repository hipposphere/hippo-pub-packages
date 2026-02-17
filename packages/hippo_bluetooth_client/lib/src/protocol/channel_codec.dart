import 'dart:convert';
import 'dart:typed_data';

/// Encodes/decodes channel values to/from bytes.
abstract interface class ChannelCodec<T> {
  /// Encodes a value to bytes for transport.
  Uint8List encode(T value);

  /// Decodes bytes from transport into a typed value.
  T decode(Uint8List bytes);
}

/// Byte passthrough codec.
class BytesChannelCodec implements ChannelCodec<Uint8List> {
  /// Creates a byte passthrough codec.
  const BytesChannelCodec();

  @override
  Uint8List encode(Uint8List value) => Uint8List.fromList(value);

  @override
  Uint8List decode(Uint8List bytes) => Uint8List.fromList(bytes);
}

/// UTF-8 string codec.
class Utf8ChannelCodec implements ChannelCodec<String> {
  /// Creates a UTF-8 codec.
  const Utf8ChannelCodec();

  @override
  Uint8List encode(String value) => Uint8List.fromList(utf8.encode(value));

  @override
  String decode(Uint8List bytes) => utf8.decode(bytes);
}

/// JSON codec with custom typed mapper functions.
class JsonChannelCodec<T> implements ChannelCodec<T> {
  /// Creates a JSON codec for type [T].
  const JsonChannelCodec({required this.fromJson, required this.toJson});

  /// Converts decoded JSON object into [T].
  final T Function(Object? jsonValue) fromJson;

  /// Converts [T] to a JSON-encodable object.
  final Object? Function(T value) toJson;

  @override
  Uint8List encode(T value) {
    final encoded = jsonEncode(toJson(value));
    return Uint8List.fromList(utf8.encode(encoded));
  }

  @override
  T decode(Uint8List bytes) {
    final decoded = jsonDecode(utf8.decode(bytes));
    return fromJson(decoded);
  }
}

/// General JSON codec (`Map`, `List`, primitives, and `null`).
class JsonAnyChannelCodec implements ChannelCodec<dynamic> {
  /// Creates a broad JSON codec.
  const JsonAnyChannelCodec();

  @override
  Uint8List encode(dynamic value) {
    return Uint8List.fromList(utf8.encode(jsonEncode(value)));
  }

  @override
  dynamic decode(Uint8List bytes) {
    return jsonDecode(utf8.decode(bytes));
  }
}

/// Built-in codec helpers.
abstract final class ChannelCodecs {
  /// Raw bytes codec.
  static const BytesChannelCodec bytes = BytesChannelCodec();

  /// UTF-8 codec.
  static const Utf8ChannelCodec utf8 = Utf8ChannelCodec();

  /// General JSON codec.
  static const JsonAnyChannelCodec json = JsonAnyChannelCodec();

  /// Creates a typed JSON codec for [T].
  static JsonChannelCodec<T> typedJson<T>({
    required T Function(Object? jsonValue) fromJson,
    required Object? Function(T value) toJson,
  }) {
    return JsonChannelCodec<T>(fromJson: fromJson, toJson: toJson);
  }
}
