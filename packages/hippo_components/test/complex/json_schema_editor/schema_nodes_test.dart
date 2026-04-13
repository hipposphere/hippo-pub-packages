import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  group('JsonSchemaNode', () {
    test('parses and serializes string node', () {
      final source = <String, dynamic>{
        'type': 'string',
        'title': 'Username',
        'minLength': 1,
        'maxLength': 24,
        'pattern': '[a-zA-Z]+',
      };
      final node = JsonSchemaNode.fromJson(source);

      expect(node, isA<JsonSchemaStringNode>());
      expect(node.toJson(), equals(source));
    });

    test('parses and serializes string enum', () {
      final source = <String, dynamic>{
        'type': 'string',
        'title': 'Status',
        'enum': ['active', 'inactive', 'pending'],
      };
      final node = JsonSchemaNode.fromJson(source);
      final stringNode = node as JsonSchemaStringNode;

      expect(stringNode, isA<JsonSchemaStringNode>());
      expect(stringNode.enumValues, equals(['active', 'inactive', 'pending']));
      expect(stringNode.toJson()['enum'], equals(['active', 'inactive', 'pending']));
    });

    test('parses string enum from comma/newline list', () {
      final source = <String, dynamic>{'type': 'string', 'enum': 'A, B\nC'};
      final node = JsonSchemaNode.fromJson(source);

      expect(node, isA<JsonSchemaStringNode>());
      expect((node as JsonSchemaStringNode).enumValues, equals(['A', 'B', 'C']));
    });

    test('parses and serializes boolean node', () {
      final source = <String, dynamic>{
        'type': 'boolean',
        'title': 'IsActive',
        'description': 'toggle',
        'default': true,
      };

      final node = JsonSchemaNode.fromJson(source);

      expect(node, isA<JsonSchemaBooleanNode>());
      expect(node.toJson(), equals(source));
      expect((node as JsonSchemaBooleanNode).defaultValue, isTrue);
    });

    test('infers boolean node from default value without explicit type', () {
      final source = <String, dynamic>{'title': 'Enabled', 'default': false};

      final node = JsonSchemaNode.fromJson(source);

      expect(node, isA<JsonSchemaBooleanNode>());
      expect((node as JsonSchemaBooleanNode).defaultValue, isFalse);
      expect(node.toJson()['type'], 'boolean');
    });

    test('parses and serializes number and integer nodes', () {
      final numberJson = <String, dynamic>{
        'type': 'number',
        'minimum': 0.5,
        'maximum': 15,
        'exclusiveMinimum': true,
      };
      final integerJson = <String, dynamic>{'type': 'integer', 'minimum': 1, 'maximum': 10};

      final numberNode = JsonSchemaNode.fromJson(numberJson);
      final integerNode = JsonSchemaNode.fromJson(integerJson);

      expect(numberNode, isA<JsonSchemaNumberNode>());
      expect(integerNode, isA<JsonSchemaNumberNode>());
      expect(numberNode.type, JsonSchemaNodeType.number);
      expect(integerNode.type, JsonSchemaNodeType.integer);
      expect(numberNode.toJson()['minimum'], equals(0.5));
      expect(integerNode.toJson()['maximum'], equals(10));
    });

    test('parses and serializes object node with required keys', () {
      final source = <String, dynamic>{
        'type': 'object',
        'title': 'Container',
        'properties': <String, dynamic>{
          'name': {'type': 'string'},
          'age': {'type': 'integer', 'minimum': 0},
        },
        'required': ['name'],
      };

      final node = JsonSchemaNode.fromJson(source);

      expect(node, isA<JsonSchemaObjectNode>());
      final json = node.toJson();
      expect(json['type'], 'object');
      expect(json['properties'], isA<Map<String, dynamic>>());
      expect((json['required'] as List<String>?)?.contains('name'), isTrue);
    });

    test('parses and serializes array node with items', () {
      final source = <String, dynamic>{
        'type': 'array',
        'items': {'type': 'string', 'minLength': 2},
        'minItems': 1,
        'maxItems': 10,
      };
      final node = JsonSchemaNode.fromJson(source);

      expect(node, isA<JsonSchemaArrayNode>());
      final json = node.toJson();
      expect(json['type'], 'array');
      expect(json['items'], isA<Map<String, dynamic>>());
      expect(json['minItems'], 1);
      expect(json['maxItems'], 10);
    });

    test('keeps unknown extension fields', () {
      final source = <String, dynamic>{
        'type': 'string',
        'title': 'Tokenized',
        'x-token': {
          'enum': ['read', 'write'],
        },
      };
      final node = JsonSchemaNode.fromJson(source);

      expect(node, isA<JsonSchemaStringNode>());
      expect((node as JsonSchemaStringNode).extensions['x-token'], isA<Map>());
      expect((node.extensions['x-token'] as Map)['enum'], equals(['read', 'write']));

      final json = node.toJson();
      expect(json['x-token'], isA<Map>());
      expect((json['x-token'] as Map)['enum'], equals(['read', 'write']));
    });
  });
}
