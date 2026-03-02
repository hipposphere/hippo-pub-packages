import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

class JsonSchemaEditorExample extends StatelessWidget {
  const JsonSchemaEditorExample({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = JsonSchemaEditorController(
      featureOptions: JsonSchemaEditorFeatureOptions(
        arrayUniqueItems: false,
        arrayMaxItems: false,
        arrayMinItems: false,
        numberMaximum: false,
        numberExclusiveMaximum: false,
        numberExclusiveMinimum: false,
        numberMinimum: false,
        numberMultipleOf: false,
        stringPattern: false,
        stringMaxLength: false,
        stringMinLength: false,
        objectAdditionalProperties: false,
        stringEnum: true,
      ),
      extensionOptions: JsonSchemaEditorExtensionOptions(
        allowAddExtensions: false,
        configurableExtensionsForAllNodeTypes: [
          JsonSchemaEditorExtensionField(
            key: 'x-token',
            valueType: JsonSchemaEditorExtensionFieldType.stringEnum,
            defaultValue: 'test',
            enumValues: ['test', 'token', 'admin'],
          ),
          JsonSchemaEditorExtensionField(
            key: 'x-enabled',
            valueType: JsonSchemaEditorExtensionFieldType.boolean,
            defaultValue: false,
            applicableNodeTypes: const {JsonSchemaNodeType.boolean},
          ),
          JsonSchemaEditorExtensionField(
            key: 'x-priority',
            valueType: JsonSchemaEditorExtensionFieldType.number,
            defaultValue: 0,
            applicableNodeTypes: const {JsonSchemaNodeType.number, JsonSchemaNodeType.integer},
          ),
          JsonSchemaEditorExtensionField(
            key: 'x-object-label',
            description: 'Label for object nodes',
            valueType: JsonSchemaEditorExtensionFieldType.string,
            defaultValue: 'object-level',
            applicableNodeTypes: const {JsonSchemaNodeType.object},
          ),
          JsonSchemaEditorExtensionField(
            key: 'x-string-label',
            description: 'Label for string nodes',
            valueType: JsonSchemaEditorExtensionFieldType.string,
            defaultValue: 'string-level',
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

    return JsonSchemaEditorPage(title: 'JSON Schema Editor', controller: controller);
  }
}
