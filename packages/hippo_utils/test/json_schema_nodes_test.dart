import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  group('JsonSchemaObjectNode property ordering', () {
    test('parses and serializes explicit property order', () {
      final schema = JsonSchema({
        'type': 'object',
        'properties': {
          'first': {'type': 'string'},
          'second': {'type': 'string'},
          'third': {'type': 'string'},
        },
        jsonSchemaObjectPropertyOrderExtensionKey: ['third', 'first', 'second'],
      });

      final node = schema.node as JsonSchemaObjectNode;

      expect(node.resolvedPropertyOrder, orderedEquals(['third', 'first', 'second']));
      expect(
        node.orderedPropertyEntries.map((entry) => entry.key),
        orderedEquals(['third', 'first', 'second']),
      );

      final serialized = node.toJson();
      expect(
        (serialized['properties'] as Map<String, dynamic>).keys,
        orderedEquals(['third', 'first', 'second']),
      );
      expect(
        serialized[jsonSchemaObjectPropertyOrderExtensionKey],
        orderedEquals(['third', 'first', 'second']),
      );
    });

    test('normalizes missing and stale order entries deterministically', () {
      final schema = JsonSchema({
        'type': 'object',
        'properties': {
          'first': {'type': 'string'},
          'second': {'type': 'string'},
          'third': {'type': 'string'},
        },
        jsonSchemaObjectPropertyOrderExtensionKey: ['missing', 'second'],
      });

      final node = schema.node as JsonSchemaObjectNode;
      final roundTrip = JsonSchema.fromNode(node).node as JsonSchemaObjectNode;

      expect(node.resolvedPropertyOrder, orderedEquals(['second', 'first', 'third']));
      expect(roundTrip.resolvedPropertyOrder, orderedEquals(['second', 'first', 'third']));
      expect(
        roundTrip.extensions[jsonSchemaObjectPropertyOrderExtensionKey],
        orderedEquals(['second', 'first', 'third']),
      );
      expect(
        roundTrip.toJson()[jsonSchemaObjectPropertyOrderExtensionKey],
        orderedEquals(['second', 'first', 'third']),
      );
    });

    test('traverse yields root and children in stable schema order', () {
      const node = JsonSchemaObjectNode(
        properties: {
          'second': JsonSchemaArrayNode(items: JsonSchemaBooleanNode()),
          'first': JsonSchemaObjectNode(properties: {'child': JsonSchemaStringNode()}),
        },
        extensions: {
          jsonSchemaObjectPropertyOrderExtensionKey: ['first', 'second'],
        },
      );

      final visits = node.traverse().toList(growable: false);

      expect(
        visits.map((visit) => visit.path),
        orderedEquals([
          const JsonSchemaPath.root(),
          const JsonSchemaPath.root().childProperty('first'),
          const JsonSchemaPath.root().childProperty('first').childProperty('child'),
          const JsonSchemaPath.root().childProperty('second'),
          const JsonSchemaPath.root().childProperty('second').childItems(),
        ]),
      );
      expect(visits.first.node, same(node));
      expect(visits[1].node, isA<JsonSchemaObjectNode>());
      expect(visits.last.node, isA<JsonSchemaBooleanNode>());
    });
  });
}
