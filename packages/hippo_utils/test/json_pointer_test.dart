import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:json_schema/json_schema.dart';

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

    test('reads nested values from decoded JSON documents', () {
      final json = {
        'user': {
          'name': 'Ada',
          'aliases': ['A', 'B'],
          'special': {
            'a/b': {'m~n': 42},
          },
        },
      };

      expect(JsonPointer('/user/name').read(json), 'Ada');
      expect(JsonPointer('/user/aliases/1').read(json), 'B');
      expect(JsonPointer('/user/special/a~1b/m~0n').read(json), 42);
      expect(JsonPointer.empty().read(json), same(json));
    });

    test('existsIn distinguishes null values from missing paths', () {
      final json = {
        'user': {'nickname': null},
      };

      expect(JsonPointer('/user/nickname').read(json), isNull);
      expect(JsonPointer('/user/nickname').existsIn(json), true);

      expect(JsonPointer('/user/missing').read(json), isNull);
      expect(JsonPointer('/user/missing').existsIn(json), false);
    });

    test('rejects invalid or out-of-bounds array lookups', () {
      final json = {
        'users': [
          {'name': 'Ada'},
        ],
      };

      expect(JsonPointer('/users/0/name').read(json), 'Ada');
      expect(JsonPointer('/users/1/name').existsIn(json), false);
      expect(JsonPointer('/users/01/name').existsIn(json), false);
      expect(JsonPointer('/users/-/name').existsIn(json), false);
    });

    test('top-level pointer lookup helpers resolve values from JSON documents', () {
      final json = {
        'user': {'name': 'Ada'},
      };

      expect(jsonValueAtPointer(json, '/user/name'), 'Ada');
      expect(jsonPointerExists(json, '/user/name'), true);
      expect(jsonPointerExists(json, '/user/missing'), false);
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

    test('seeded constructor populates map correctly', () {
      final map = JsonPointerMap<String>.seeded({'/foo/1': 'first', '/foo/2': 'second'});
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

  group('JsonSchemaPath', () {
    test('converts schema paths to JSON Pointer strings', () {
      expect(const JsonSchemaPath.root().toJsonPointerString(), '');
      expect(const JsonSchemaPath.root().childProperty('user').toJsonPointerString(), '/user');
      expect(
        const JsonSchemaPath.root().childProperty('users').childItems().toJsonPointerString(),
        '/users/-',
      );
      expect(
        const JsonSchemaPath.root()
            .childProperty('special')
            .childProperty('a/b')
            .childProperty('m~n')
            .toJsonPointerString(),
        '/special/a~1b/m~0n',
      );
    });
  });
}
