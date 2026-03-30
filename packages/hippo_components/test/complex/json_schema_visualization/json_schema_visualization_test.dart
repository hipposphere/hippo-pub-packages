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

  testWidgets('renders object properties in configured order and hides internal order metadata', (
    WidgetTester tester,
  ) async {
    final schema = JsonSchema({
      'type': 'object',
      'properties': {
        'first': {'type': 'string', 'title': 'First'},
        'second': {'type': 'string', 'title': 'Second'},
        'third': {'type': 'string', 'title': 'Third'},
      },
      jsonSchemaObjectPropertyOrderExtensionKey: ['third', 'first', 'second'],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JsonSchemaVisualization(schema: schema)),
      ),
    );
    await tester.pumpAndSettle();

    final thirdY = tester.getTopLeft(find.text('Third')).dy;
    final firstY = tester.getTopLeft(find.text('First')).dy;
    final secondY = tester.getTopLeft(find.text('Second')).dy;

    expect(thirdY, lessThan(firstY));
    expect(firstY, lessThan(secondY));
    expect(find.text(jsonSchemaObjectPropertyOrderExtensionKey), findsNothing);
  });
}
