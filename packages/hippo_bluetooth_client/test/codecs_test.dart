import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_bluetooth_client/hippo_bluetooth_client.dart';

void main() {
  test('bytes codec roundtrip', () {
    const codec = BytesChannelCodec();
    final source = Uint8List.fromList(<int>[1, 2, 3, 255]);
    final encoded = codec.encode(source);
    final decoded = codec.decode(encoded);

    expect(decoded, source);
    expect(identical(decoded, source), isFalse);
  });

  test('utf8 codec roundtrip', () {
    const codec = Utf8ChannelCodec();
    const source = 'hippo-ble';
    final encoded = codec.encode(source);
    final decoded = codec.decode(encoded);

    expect(decoded, source);
  });

  test('typed json codec roundtrip', () {
    final codec = ChannelCodecs.json<_Payload>(
      fromJson: (json) => _Payload.fromJson(json as Map<String, dynamic>),
      toJson: (value) => value.toJson(),
    );

    final source = _Payload(id: 'abc', count: 42);
    final encoded = codec.encode(source);
    final decoded = codec.decode(encoded);

    expect(decoded.id, 'abc');
    expect(decoded.count, 42);
  });

  test('json map codec decodes object map', () {
    const codec = JsonMapChannelCodec();
    final encoded = codec.encode(<String, dynamic>{
      'hello': 'world',
      'count': 1,
    });

    final decoded = codec.decode(encoded);
    expect(decoded['hello'], 'world');
    expect(decoded['count'], 1);
  });
}

class _Payload {
  final String id;
  final int count;

  const _Payload({required this.id, required this.count});

  factory _Payload.fromJson(Map<String, dynamic> json) {
    return _Payload(id: json['id'] as String, count: json['count'] as int);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'count': count};
}
