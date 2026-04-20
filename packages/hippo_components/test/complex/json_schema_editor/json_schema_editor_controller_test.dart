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

    test('maintains property order metadata across add rename and remove', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema({
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
            'age': {'type': 'integer'},
          },
          jsonSchemaObjectPropertyOrderExtensionKey: ['age', 'name'],
        }),
      );

      controller.addProperty(objectPath: const JsonSchemaPath.root(), key: 'email');

      var schema = controller.schema as JsonSchemaObjectNode;
      expect(schema.resolvedPropertyOrder, orderedEquals(['age', 'name', 'email']));
      expect(
        schema.extensions[jsonSchemaObjectPropertyOrderExtensionKey],
        orderedEquals(['age', 'name', 'email']),
      );

      controller.renameProperty(
        objectPath: const JsonSchemaPath.root(),
        currentKey: 'name',
        nextKey: 'displayName',
      );

      schema = controller.schema as JsonSchemaObjectNode;
      expect(schema.resolvedPropertyOrder, orderedEquals(['age', 'displayName', 'email']));
      expect(
        schema.extensions[jsonSchemaObjectPropertyOrderExtensionKey],
        orderedEquals(['age', 'displayName', 'email']),
      );

      controller.removeProperty(objectPath: const JsonSchemaPath.root(), key: 'age');

      schema = controller.schema as JsonSchemaObjectNode;
      expect(schema.resolvedPropertyOrder, orderedEquals(['displayName', 'email']));
      expect(
        schema.extensions[jsonSchemaObjectPropertyOrderExtensionKey],
        orderedEquals(['displayName', 'email']),
      );
    });

    test('reorders properties while preserving required flags and node types', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema.fromNode(
          const JsonSchemaObjectNode(
            properties: {
              'first': JsonSchemaStringNode(),
              'second': JsonSchemaBooleanNode(),
              'third': JsonSchemaNumberNode.number(),
            },
            required: {'second'},
          ),
        ),
      );

      controller.movePropertyDown(objectPath: const JsonSchemaPath.root(), key: 'first');
      controller.movePropertyUp(objectPath: const JsonSchemaPath.root(), key: 'third');

      final schema = controller.schema as JsonSchemaObjectNode;
      expect(schema.resolvedPropertyOrder, orderedEquals(['second', 'third', 'first']));
      expect(schema.required, contains('second'));
      expect(schema.properties['second'], isA<JsonSchemaBooleanNode>());
      expect(schema.properties['third'], isA<JsonSchemaNumberNode>());
      expect(schema.properties['first'], isA<JsonSchemaStringNode>());
    });

    test('reorders nested objects independently', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema.fromNode(
          const JsonSchemaObjectNode(
            properties: {
              'top': JsonSchemaStringNode(),
              'nested': JsonSchemaObjectNode(
                properties: {'first': JsonSchemaStringNode(), 'second': JsonSchemaStringNode()},
              ),
              'tail': JsonSchemaStringNode(),
            },
          ),
        ),
      );

      controller.movePropertyUp(
        objectPath: const JsonSchemaPath.root().childProperty('nested'),
        key: 'second',
      );

      final schema = controller.schema as JsonSchemaObjectNode;
      final nested = schema.properties['nested'] as JsonSchemaObjectNode;

      expect(schema.resolvedPropertyOrder, orderedEquals(['top', 'nested', 'tail']));
      expect(nested.resolvedPropertyOrder, orderedEquals(['second', 'first']));
      expect(
        nested.extensions[jsonSchemaObjectPropertyOrderExtensionKey],
        orderedEquals(['second', 'first']),
      );
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

    test('supports custom validators with multiple diagnostics per node', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema.fromNode(const JsonSchemaStringNode()),
        customValidators: [
          (root) sync* {
            for (final visit in root.traverse()) {
              final node = visit.node;
              final path = visit.path;
              if ((node.description?.trim().isEmpty ?? true)) {
                yield JsonSchemaDiagnostic(
                  path: path,
                  message: 'Description is required.',
                  severity: JsonSchemaDiagnosticSeverity.warning,
                );
              }
              if (!node.extensions.containsKey('x-token')) {
                yield JsonSchemaDiagnostic(
                  path: path,
                  message: 'x-token extension is required.',
                  severity: JsonSchemaDiagnosticSeverity.warning,
                );
              }
            }
          },
        ],
      );

      expect(
        controller.diagnostics.map((item) => item.message),
        containsAll(['Description is required.', 'x-token extension is required.']),
      );

      controller.setNodeField(path: const JsonSchemaPath.root(), key: 'x-token', value: 'token');
      expect(
        controller.diagnostics.map((item) => item.message),
        contains('Description is required.'),
      );
      expect(
        controller.diagnostics.any((item) => item.message == 'x-token extension is required.'),
        isFalse,
      );

      controller.updateNode<JsonSchemaStringNode>(
        path: const JsonSchemaPath.root(),
        updater: (node) => node.copyWith(description: 'Has description'),
      );

      expect(controller.diagnostics, isEmpty);
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

    test('imports a root schema from JSON text', () {
      final controller = JsonSchemaEditorController(
        initialSchema: JsonSchema.fromNode(const JsonSchemaStringNode(title: 'start')),
      );

      controller.importJsonString('''
{
  "type": "object",
  "title": "Imported schema",
  "properties": {
    "enabled": {
      "type": "boolean",
      "default": true
    }
  },
  "required": ["enabled"],
  "x-token": {
    "values": ["read", "write"]
  }
}
''');

      final schema = controller.schema as JsonSchemaObjectNode;
      expect(schema.title, 'Imported schema');
      expect(schema.required, contains('enabled'));
      expect(schema.properties['enabled'], isA<JsonSchemaBooleanNode>());
      expect((schema.properties['enabled'] as JsonSchemaBooleanNode).defaultValue, isTrue);
      expect(schema.extensions['x-token'], isA<Map>());
      expect((schema.extensions['x-token'] as Map)['values'], equals(['read', 'write']));
    });

    test('rejects non-object JSON imports', () {
      final controller = JsonSchemaEditorController();

      expect(() => controller.importJsonString('[]'), throwsFormatException);
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
        value: const {
          'enum': ['read', 'write'],
        },
      );

      expect(controller.schema.extensions['x-token'], isA<Map>());
      expect((controller.schema.extensions['x-token'] as Map)['enum'], equals(['read', 'write']));

      controller.removeNodeField(path: const JsonSchemaPath.root(), key: 'x-token');
      expect(controller.schema.extensions.containsKey('x-token'), isFalse);
    });

    test('filters configured extensions by node type and scope', () {
      final controller = JsonSchemaEditorController(
        extensionOptions: JsonSchemaEditorExtensionOptions(
          configurableExtensions: [
            const JsonSchemaEditorExtensionField(
              key: 'x-shared',
              valueType: JsonSchemaEditorExtensionFieldType.string,
            ),
            const JsonSchemaEditorExtensionField(
              key: 'x-root-only',
              valueType: JsonSchemaEditorExtensionFieldType.string,
              applicableScopes: {JsonSchemaEditorExtensionFieldScope.root},
            ),
            const JsonSchemaEditorExtensionField(
              key: 'x-property-only',
              valueType: JsonSchemaEditorExtensionFieldType.string,
              applicableScopes: {JsonSchemaEditorExtensionFieldScope.objectProperty},
            ),
            const JsonSchemaEditorExtensionField(
              key: 'x-item-only',
              valueType: JsonSchemaEditorExtensionFieldType.string,
              applicableScopes: {JsonSchemaEditorExtensionFieldScope.arrayItem},
            ),
            const JsonSchemaEditorExtensionField(
              key: 'x-obj-root-only',
              valueType: JsonSchemaEditorExtensionFieldType.string,
              applicableNodeTypes: {JsonSchemaNodeType.object},
              applicableScopes: {JsonSchemaEditorExtensionFieldScope.root},
            ),
            const JsonSchemaEditorExtensionField(
              key: 'x-number-item-only',
              valueType: JsonSchemaEditorExtensionFieldType.number,
              applicableNodeTypes: {JsonSchemaNodeType.number},
              applicableScopes: {JsonSchemaEditorExtensionFieldScope.arrayItem},
            ),
          ],
        ),
      );

      final objectRootExtensions = controller
          .getConfiguredExtensions(JsonSchemaNodeType.object, path: const JsonSchemaPath.root())
          .map((entry) => entry.key)
          .toSet();
      final stringPropertyExtensions = controller
          .getConfiguredExtensions(
            JsonSchemaNodeType.string,
            path: const JsonSchemaPath.root().childProperty('name'),
          )
          .map((entry) => entry.key)
          .toSet();
      final numberItemExtensions = controller
          .getConfiguredExtensions(
            JsonSchemaNodeType.number,
            path: const JsonSchemaPath.root().childItems(),
          )
          .map((entry) => entry.key)
          .toSet();

      expect(objectRootExtensions, contains('x-shared'));
      expect(objectRootExtensions, contains('x-root-only'));
      expect(objectRootExtensions, contains('x-obj-root-only'));
      expect(objectRootExtensions, isNot(contains('x-property-only')));
      expect(objectRootExtensions, isNot(contains('x-item-only')));
      expect(objectRootExtensions, isNot(contains('x-number-item-only')));

      expect(stringPropertyExtensions, contains('x-shared'));
      expect(stringPropertyExtensions, contains('x-property-only'));
      expect(stringPropertyExtensions, isNot(contains('x-root-only')));
      expect(stringPropertyExtensions, isNot(contains('x-item-only')));
      expect(stringPropertyExtensions, isNot(contains('x-obj-root-only')));
      expect(stringPropertyExtensions, isNot(contains('x-number-item-only')));

      expect(numberItemExtensions, contains('x-shared'));
      expect(numberItemExtensions, contains('x-item-only'));
      expect(numberItemExtensions, contains('x-number-item-only'));
      expect(numberItemExtensions, isNot(contains('x-root-only')));
      expect(numberItemExtensions, isNot(contains('x-property-only')));
      expect(numberItemExtensions, isNot(contains('x-obj-root-only')));
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
          (controller.schema as JsonSchemaObjectNode).properties['enabled']
              as JsonSchemaBooleanNode;

      expect(updatedNameNode.extensions['x-token'], equals('admin'));
      expect(updatedCountNode.extensions['x-priority'], equals(10));
      expect(updatedBoolNode.extensions['x-enabled'], isTrue);
    });
  });
}
