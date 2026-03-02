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

    test('stores additional extension fields on a node', () {
      final controller = JsonSchemaEditorController();

      controller.setNodeField(
        path: const JsonSchemaPath.root(),
        key: 'x-token',
        value: const {'enum': ['read', 'write']},
      );

      expect(controller.schema.extensions['x-token'], isA<Map>());
      expect((controller.schema.extensions['x-token'] as Map)['enum'], equals(['read', 'write']));

      controller.removeNodeField(
        path: const JsonSchemaPath.root(),
        key: 'x-token',
      );
      expect(controller.schema.extensions.containsKey('x-token'), isFalse);
    });

    test('filters configured extensions by node type', () {
      final controller = JsonSchemaEditorController(
        extensionOptions: JsonSchemaEditorExtensionOptions(
          configurableExtensionsForAllNodeTypes: [
            const JsonSchemaEditorExtensionField(
              key: 'x-shared',
              valueType: JsonSchemaEditorExtensionFieldType.string,
            ),
            JsonSchemaEditorExtensionField(
              key: 'x-obj-only',
              valueType: JsonSchemaEditorExtensionFieldType.string,
              applicableNodeTypes: const {JsonSchemaNodeType.object},
            ),
            JsonSchemaEditorExtensionField(
              key: 'x-number-only',
              valueType: JsonSchemaEditorExtensionFieldType.number,
              applicableNodeTypes: const {JsonSchemaNodeType.number},
            ),
          ],
        ),
      );

      final objectExtensions = controller
          .getConfiguredExtensions(JsonSchemaNodeType.object)
          .map((entry) => entry.key)
          .toSet();
      final stringExtensions = controller
          .getConfiguredExtensions(JsonSchemaNodeType.string)
          .map((entry) => entry.key)
          .toSet();
      final numberExtensions = controller
          .getConfiguredExtensions(JsonSchemaNodeType.number)
          .map((entry) => entry.key)
          .toSet();

      expect(objectExtensions, contains('x-shared'));
      expect(objectExtensions, contains('x-obj-only'));
      expect(objectExtensions, isNot(contains('x-number-only')));

      expect(stringExtensions, contains('x-shared'));
      expect(stringExtensions, isNot(contains('x-obj-only')));
      expect(stringExtensions, isNot(contains('x-number-only')));

      expect(numberExtensions, contains('x-shared'));
      expect(numberExtensions, contains('x-number-only'));
      expect(numberExtensions, isNot(contains('x-obj-only')));
    });

    test('supports extensions on nested non-object nodes', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema.fromNode(
          const JsonSchemaObjectNode(
            properties: {
              'name': JsonSchemaStringNode(extensions: {'x-token': 'token'}),
              'enabled': JsonSchemaBooleanNode(extensions: {'x-enabled': false}),
              'count': JsonSchemaNumberNode.number(extensions: {'x-priority': 1}),
              'list': JsonSchemaArrayNode(
                items: JsonSchemaStringNode(extensions: {'x-token': 'item'}),
                extensions: {'x-token': 'list'},
              ),
            },
          ),
        ),
      );

      final schema = controller.schema as JsonSchemaObjectNode;
      final nameNode = schema.properties['name'] as JsonSchemaStringNode;
      final boolNode = schema.properties['enabled'] as JsonSchemaBooleanNode;
      final numberNode = schema.properties['count'] as JsonSchemaNumberNode;
      final arrayNode = schema.properties['list'] as JsonSchemaArrayNode;
      final nestedItemNode = arrayNode.items as JsonSchemaStringNode;

      expect(nameNode.extensions['x-token'], equals('token'));
      expect(boolNode.extensions['x-enabled'], isFalse);
      expect(numberNode.extensions['x-priority'], equals(1));
      expect(arrayNode.extensions['x-token'], equals('list'));
      expect(nestedItemNode.extensions['x-token'], equals('item'));

      controller.setNodeField(
        path: const JsonSchemaPath.root().childProperty('name'),
        key: 'x-token',
        value: 'admin',
      );
      controller.setNodeField(
        path: const JsonSchemaPath.root().childProperty('count'),
        key: 'x-priority',
        value: 10,
      );
      controller.setNodeField(
        path: const JsonSchemaPath.root().childProperty('enabled'),
        key: 'x-enabled',
        value: true,
      );
      final updatedNameNode =
          (controller.schema as JsonSchemaObjectNode).properties['name'] as JsonSchemaStringNode;
      final updatedCountNode =
          (controller.schema as JsonSchemaObjectNode).properties['count'] as JsonSchemaNumberNode;
      final updatedBoolNode =
          (controller.schema as JsonSchemaObjectNode).properties['enabled'] as JsonSchemaBooleanNode;

      expect(updatedNameNode.extensions['x-token'], equals('admin'));
      expect(updatedCountNode.extensions['x-priority'], equals(10));
      expect(updatedBoolNode.extensions['x-enabled'], isTrue);
    });
  });
}
