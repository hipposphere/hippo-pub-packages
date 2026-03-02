import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  group('JsonSchemaEditorController', () {
    test('initializes with default empty object root', () {
      final controller = JsonSchemaEditorController();
      final schema = controller.schema;

      expect(schema, isA<JsonSchemaObjectNode>());
      expect((schema as JsonSchemaObjectNode).properties, isEmpty);
    });

    test('supports immutable object mutations', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema.fromNode(
          const JsonSchemaObjectNode(
            properties: {'name': JsonSchemaStringNode()},
            required: {'name'},
          ),
        ),
      );

      final before = controller.schema as JsonSchemaObjectNode;
      controller.addProperty(objectPath: const JsonSchemaPath.root(), key: 'age');

      final afterAdd = controller.schema as JsonSchemaObjectNode;
      expect(afterAdd.properties.containsKey('age'), isTrue);
      expect(identical(before, afterAdd), isFalse);

      controller.renameProperty(
        objectPath: const JsonSchemaPath.root(),
        currentKey: 'age',
        nextKey: 'years',
      );
      expect((controller.schema as JsonSchemaObjectNode).properties.containsKey('years'), isTrue);
      expect((controller.schema as JsonSchemaObjectNode).properties.containsKey('age'), isFalse);

      controller.removeProperty(objectPath: const JsonSchemaPath.root(), key: 'name');
      final afterRemove = controller.schema as JsonSchemaObjectNode;
      expect(afterRemove.properties.containsKey('name'), isFalse);
      expect(afterRemove.required.contains('name'), isFalse);
    });

    test('validates diagnostics for invalid constraints', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema.fromNode(
          const JsonSchemaArrayNode(items: JsonSchemaNumberNode.number(), minItems: 5, maxItems: 2),
        ),
      );
      final diagnostics = controller.diagnostics;

      expect(diagnostics, isNotEmpty);
      expect(
        diagnostics.any(
          (item) => item.message.contains('minItems must not be greater than maxItems'),
        ),
        isTrue,
      );
    });

    test('reset restores the initial schema', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema.fromNode(const JsonSchemaStringNode(title: 'start')),
      );

      controller.setRoot(const JsonSchemaNumberNode.number(title: 'changed'));
      expect((controller.schema as JsonSchemaNumberNode).title, 'changed');

      controller.reset();
      expect((controller.schema as JsonSchemaStringNode).title, 'start');
    });

    test('supports boolean root nodes', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema.fromNode(
          const JsonSchemaBooleanNode(title: 'flag', defaultValue: false),
        ),
      );

      expect(controller.schema, isA<JsonSchemaBooleanNode>());
      expect((controller.schema as JsonSchemaBooleanNode).defaultValue, isFalse);

      controller.updateNode<JsonSchemaBooleanNode>(
        path: const JsonSchemaPath.root(),
        updater: (node) => node.copyWith(defaultValue: true),
      );

      expect((controller.schema as JsonSchemaBooleanNode).defaultValue, isTrue);
      expect(controller.toData()['type'], 'boolean');
    });

    test('sets required on a node path', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema.fromNode(
          const JsonSchemaObjectNode(
            properties: {
              'nested': JsonSchemaObjectNode(properties: {'flag': JsonSchemaBooleanNode()}),
            },
          ),
        ),
      );

      final nestedPath = const JsonSchemaPath.root().childProperty('nested');
      final requiredPath = nestedPath.childProperty('flag');
      controller.setRequiredForPath(nodePath: requiredPath, required: true);

      final schema = controller.schema as JsonSchemaObjectNode;
      final nested = schema.properties['nested'] as JsonSchemaObjectNode;
      expect(nested.required, contains('flag'));
    });
  });
}
