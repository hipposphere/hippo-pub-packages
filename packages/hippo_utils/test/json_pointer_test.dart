import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  group('JsonPointer', () {
    test('parses basic pointers correctly', () {
      final ptr = JsonPointer('/foo/1/bar');
      expect(ptr.segments, ['foo', '1', 'bar']);
      expect(ptr.isRoot, false);
      expect(ptr.toString(), '/foo/1/bar');
    });

    test('parses empty pointer as root', () {
      expect(JsonPointer('').isRoot, true);
      expect(JsonPointer('').segments, isEmpty);
      expect(JsonPointer.empty().isRoot, true);
      expect(JsonPointer.empty().toString(), '');
    });

    test('handles RFC 6901 escaping/unescaping', () {
      final ptr = JsonPointer('/a~1b');
      expect(ptr.segments, ['a/b']);
      expect(ptr.toString(), '/a~1b');

      final ptr2 = JsonPointer('/m~0n');
      expect(ptr2.segments, ['m~n']);
      expect(ptr2.toString(), '/m~0n');

      final ptr3 = JsonPointer.empty().child('a~b/c');
      expect(ptr3.toString(), '/a~0b~1c');
    });

    test('equality and hashcode', () {
      final p1 = JsonPointer('/a/b');
      final p2 = JsonPointer('/a/b');
      final p3 = JsonPointer('/a/c');

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
    });

    test('parent and child operations', () {
      final ptr = JsonPointer('/foo');
      final child = ptr.child('bar');
      expect(child.toString(), '/foo/bar');
      expect(child.parent(), ptr);
      expect(ptr.parent().isRoot, true);
    });
  });

  group('JsonPointerMap<T>', () {
    test('exact match works for set and get', () {
      final map = JsonPointerMap<String>();
      map.set(JsonPointer('/foo/1'), 'first');
      map.setString('/foo/2', 'second');

      expect(map.get(JsonPointer('/foo/1')), 'first');
      expect(map.getString('/foo/2'), 'second');
      expect(map.getString('/foo/3'), isNull);
    });

    test('match handles wildcards', () {
      final map = JsonPointerMap<String>();
      // Use '-' as a wildcard for array indices
      map.setString('/users/-/name', 'UserName Metadata');

      // Exact match
      map.setString('/users/exact/name', 'ExactName Metadata');

      // Should match specific item due to wildcard
      expect(map.match(JsonPointer('/users/0/name')), 'UserName Metadata');
      expect(map.match(JsonPointer('/users/99/name')), 'UserName Metadata');
      
      // Exact match should take precedence because it is checked first
      expect(map.match(JsonPointer('/users/exact/name')), 'ExactName Metadata');
      
      // Should not match shorter/longer segments
      expect(map.match(JsonPointer('/users/0')), isNull);
    });
  });
}
