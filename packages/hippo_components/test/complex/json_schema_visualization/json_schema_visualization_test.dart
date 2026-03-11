import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  testWidgets('renders nested schema structure and extensions without internal scrolling', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final schema = JsonSchema.fromNode(
      const JsonSchemaObjectNode(
        title: 'Account schema',
        required: {'name'},
        extensions: {'x-group': 'public'},
        properties: {
          'name': JsonSchemaStringNode(
            title: 'Display name',
            minLength: 1,
            enumValues: ['Alice', 'Bob'],
            extensions: {'x-token': 'admin'},
          ),
          'flags': JsonSchemaArrayNode(
            title: 'Flags',
            uniqueItems: true,
            extensions: {'x-priority': 2},
            items: JsonSchemaBooleanNode(
              title: 'Flag item',
              defaultValue: true,
              extensions: {'x-enabled': false},
            ),
          ),
        },
      ),
    );

    const extensionOptions = JsonSchemaEditorExtensionOptions(
      configurableExtensions: {
        JsonSchemaNodeType.object: [
          JsonSchemaEditorExtensionField(key: 'x-group', description: 'Grouping metadata'),
        ],
        JsonSchemaNodeType.array: [
          JsonSchemaEditorExtensionField(
            key: 'x-priority',
            description: 'Priority ordering',
            valueType: JsonSchemaEditorExtensionFieldType.number,
          ),
        ],
        JsonSchemaNodeType.boolean: [
          JsonSchemaEditorExtensionField(
            key: 'x-enabled',
            description: 'Boolean feature marker',
            valueType: JsonSchemaEditorExtensionFieldType.boolean,
          ),
        ],
      },
      configurableExtensionsForAllNodeTypes: [
        JsonSchemaEditorExtensionField(key: 'x-token', description: 'Authorization token'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JsonSchemaVisualization(schema: schema, extensionOptions: extensionOptions),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Schema Overview'), findsOneWidget);
    expect(find.text('Account schema'), findsOneWidget);
    expect(find.text('Display name'), findsOneWidget);
    expect(find.text('Flags'), findsOneWidget);
    expect(find.text('Flag item'), findsOneWidget);
    expect(find.text('Enum Values'), findsOneWidget);
    expect(find.text('Authorization token'), findsOneWidget);
    expect(find.text('Grouping metadata'), findsOneWidget);
    expect(find.text('Priority ordering'), findsOneWidget);
    expect(find.text('Boolean feature marker'), findsOneWidget);
    expect(find.text(r'$.flags[]'), findsOneWidget);
    expect(find.byType(Scrollable), findsNothing);
  });
}
