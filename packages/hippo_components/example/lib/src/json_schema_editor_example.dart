import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

class JsonSchemaEditorExample extends StatelessWidget {
  const JsonSchemaEditorExample({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = JsonSchemaEditorController(
      customValidators: [
        (node) {
          final diagnostics = <JsonSchemaDiagnostic>[];
          node.traverse().forEach((traversed) {
            if (traversed.node.title == null || traversed.node.title!.length < 3) {
              diagnostics.add(
                JsonSchemaDiagnostic(
                  path: traversed.path,
                  message: 'Title must be at least 3 characters long',
                  severity: .warning,
                ),
              );
            }
          });

          return diagnostics;
        },
      ],
      featureOptions: JsonSchemaEditorFeatureOptions(
        arrayOptions: const JsonSchemaEditorArrayFeatureOptions(
          uniqueItems: false,
          maxItems: false,
          minItems: false,
        ),
        numberOptions: const JsonSchemaEditorNumberFeatureOptions(
          maximum: false,
          exclusiveMaximum: false,
          exclusiveMinimum: false,
          minimum: false,
          multipleOf: false,
        ),
        stringOptions: const JsonSchemaEditorStringFeatureOptions(
          pattern: false,
          maxLength: false,
          minLength: false,
          enumValues: true,
        ),
        objectOptions: const JsonSchemaEditorObjectFeatureOptions(additionalProperties: false),
      ),
      extensionOptions: JsonSchemaEditorExtensionOptions(
        allowAddExtensions: false,
        configurableExtensions: [
          JsonSchemaEditorExtensionField(
            key: 'x-root',
            label: (_) => 'Root',
            hint: translateLazy(en: 'Root', de: 'Wurzel', zh: '根节点'),
            valueType: JsonSchemaEditorExtensionFieldType.string,
            defaultValue: 'test',
            applicableScopes: {JsonSchemaEditorExtensionFieldScope.root},
          ),
          JsonSchemaEditorExtensionField(
            key: 'x-token',
            label: (_) => 'Token',
            description: translateLazy(
              en: 'This is the ideal token!',
              de: 'Dies ist das ideale Token!',
              zh: '这是理想的令牌。',
            ),
            valueType: JsonSchemaEditorExtensionFieldType.stringEnum,
            defaultValue: 'test',
            enumValues: ['test', 'token', 'admin'],
          ),
          JsonSchemaEditorExtensionField(
            key: 'x-enabled',
            label: (_) => 'Enabled marker',
            valueType: JsonSchemaEditorExtensionFieldType.boolean,
            defaultValue: false,
            applicableNodeTypes: const {JsonSchemaNodeType.boolean},
          ),
          JsonSchemaEditorExtensionField(
            key: 'x-priority',
            label: (_) => 'Priority',
            valueType: JsonSchemaEditorExtensionFieldType.number,
            defaultValue: 0,
            applicableNodeTypes: const {JsonSchemaNodeType.number, JsonSchemaNodeType.integer},
          ),
          JsonSchemaEditorExtensionField(
            key: 'x-object-label',
            label: (_) => 'Object label',
            hint: translateLazy(en: 'Object label', de: 'Objekt-Label', zh: '对象标签'),
            description: translateLazy(
              en: 'Label for object nodes',
              de: 'Label für Objektknoten',
              zh: '对象节点的标签',
            ),
            valueType: JsonSchemaEditorExtensionFieldType.string,
            defaultValue: 'object-level',
            applicableNodeTypes: const {JsonSchemaNodeType.object},
          ),
          JsonSchemaEditorExtensionField(
            key: 'x-string-label',
            label: (_) => 'String notes',
            hint: translateLazy(en: 'String notes', de: 'String-Notizen', zh: '字符串备注'),
            description: translateLazy(
              en: 'Multiline notes for string nodes',
              de: 'Mehrzeilige Notizen für String-Knoten',
              zh: '字符串节点的多行备注',
            ),
            valueType: JsonSchemaEditorExtensionFieldType.string,
            defaultValue: 'Line 1\nLine 2',
            minLines: 2,
            maxLines: 6,
            applicableNodeTypes: const {JsonSchemaNodeType.string},
          ),
        ],
      ),
      initialSchema: JsonSchema.fromNode(
        const JsonSchemaObjectNode(
          title: 'Example schema',
          extensions: {'x-token': 'test', 'x-object-label': 'object-level'},
          properties: {
            'name': JsonSchemaStringNode(
              title: 'Name',
              description: 'Display name of the entity.',
              minLength: 1,
              extensions: {'x-token': 'admin'},
            ),
            'enabled': JsonSchemaBooleanNode(
              title: 'Enabled',
              defaultValue: true,
              extensions: {'x-enabled': false},
            ),
            'score': JsonSchemaNumberNode.number(title: 'Score', extensions: {'x-priority': 5}),
            'nested': JsonSchemaArrayNode(
              title: 'Nested items',
              items: JsonSchemaStringNode(title: 'Item', extensions: {'x-token': 'item'}),
              extensions: {'x-priority': 2},
            ),
          },
          required: {'name'},
        ),
      ),
    );

    return JsonSchemaEditorPage(
      title: 'JSON Schema Editor',
      controller: controller,
      explanationDescription:
          'This example shows how the editor models a schema tree, which node types are '
          'available, and which built-in or custom capabilities are enabled in this setup.',
      onSave: (context, schema) async {
        return true;
      },
    );
  }
}
