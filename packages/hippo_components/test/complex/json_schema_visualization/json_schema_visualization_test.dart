import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    expect(find.text('Account schema'), findsOneWidget);
    expect(find.text('Display name'), findsOneWidget);
    expect(find.text('Flags'), findsOneWidget);
    expect(find.text('Flag item'), findsOneWidget);
    expect(find.text('Enum Values'), findsOneWidget);
    expect(find.byKey(const ValueKey('section-count-Enum Values')), findsOneWidget);
    expect(find.text('Enum count'), findsNothing);
    expect(find.byIcon(Icons.account_tree_rounded), findsNothing);
    expect(find.text('Authorization token'), findsNothing);
    expect(find.text('Grouping metadata'), findsNothing);
    expect(find.text('Priority ordering'), findsNothing);
    expect(find.text('Boolean feature marker'), findsNothing);
    expect(find.text('configured'), findsNothing);
    expect(find.textContaining('x-group: public', findRichText: true), findsOneWidget);
    expect(find.textContaining('x-token: admin', findRichText: true), findsOneWidget);
    expect(find.textContaining('x-priority: 2', findRichText: true), findsOneWidget);
    expect(find.textContaining('x-enabled: false', findRichText: true), findsOneWidget);
    expect(find.byTooltip('Authorization token'), findsOneWidget);
    expect(find.byTooltip('Grouping metadata'), findsOneWidget);
    expect(find.byTooltip('Priority ordering'), findsOneWidget);
    expect(find.byTooltip('Boolean feature marker'), findsOneWidget);
    expect(find.textContaining('Properties:', findRichText: true), findsNothing);
    expect(find.textContaining('Required:', findRichText: true), findsNothing);
    expect(find.textContaining('Additional props:', findRichText: true), findsNothing);
    expect(find.byTooltip('2 properties'), findsOneWidget);
    expect(find.byTooltip('1 required properties'), findsOneWidget);
    expect(find.byTooltip('Additional properties allowed'), findsOneWidget);
    expect(find.text('/flags/-'), findsOneWidget);
    expect(find.byType(Scrollable), findsNothing);
  });

  testWidgets('copies the displayed JSON Pointer when the path chip is tapped', (
    WidgetTester tester,
  ) async {
    final schema = JsonSchema.fromNode(
      const JsonSchemaObjectNode(
        properties: {'flags': JsonSchemaArrayNode(items: JsonSchemaBooleanNode())},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JsonSchemaVisualization(schema: schema)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('/flags/-'));
    await tester.pump();

    final clipboardData = await Clipboard.getData('text/plain');
    expect(clipboardData?.text, '/flags/-');
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
