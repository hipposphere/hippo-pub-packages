import 'dart:convert';

import 'package:postgres_base_models/postgres_base_models.dart';
import 'package:test/test.dart';

class TestStringKeyId extends StringId {
  const TestStringKeyId(this.id);

  @override
  final String id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) {
    return other is TestStringKeyId && other.id == id;
  }
}

class TestIntKeyId extends IntId {
  const TestIntKeyId(this.id);

  @override
  final int id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) {
    return other is TestIntKeyId && other.id == id;
  }
}

void main() {
  group('KeyIdTest', () {
    test('checks that id is accessible', () {
      const StringId key = TestStringKeyId('123');

      expect(key.id, '123');
    });
    test('checks that the key is serialized correctly', () {
      const stringKey = TestStringKeyId('123456');
      const intKey = TestIntKeyId(123456);

      final dataMap = jsonDecode(jsonEncode({'stringKey': stringKey, 'intKey': intKey}));

      expect(dataMap['stringKey'], '123456');
      expect(dataMap['intKey'], 123456);
    });
  });
}
