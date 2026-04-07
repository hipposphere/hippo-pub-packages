import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  testWidgets('renders editor and reacts to root type changes', (WidgetTester tester) async {
    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(const JsonSchemaStringNode(title: 'Label')),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JsonSchemaEditor(controller: controller, compactMode: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);

    controller.replaceNode(
      path: const JsonSchemaPath.root(),
      node: const JsonSchemaArrayNode(items: JsonSchemaStringNode(), minItems: 1, maxItems: 3),
    );
    await tester.pump();

    expect(controller.schema, isA<JsonSchemaArrayNode>());
    expect((controller.schema as JsonSchemaArrayNode).minItems, 1);

    controller.replaceNode(
      path: const JsonSchemaPath.root(),
      node: const JsonSchemaBooleanNode(title: 'Enabled', defaultValue: true),
    );
    await tester.pump();

    expect(controller.schema, isA<JsonSchemaBooleanNode>());
    expect((controller.schema as JsonSchemaBooleanNode).defaultValue, isTrue);
    expect(controller.toData()['type'], 'boolean');
  });

  testWidgets('reorders object properties from editor move buttons', (WidgetTester tester) async {
    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(
        const JsonSchemaObjectNode(
          properties: {
            'first': JsonSchemaStringNode(),
            'second': JsonSchemaStringNode(),
            'third': JsonSchemaStringNode(),
          },
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JsonSchemaEditor(controller: controller, compactMode: true)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Move property down').first);
    await tester.pumpAndSettle();

    final schema = controller.schema as JsonSchemaObjectNode;
    expect(schema.resolvedPropertyOrder, orderedEquals(['second', 'first', 'third']));
    expect(
      schema.extensions[jsonSchemaObjectPropertyOrderExtensionKey],
      orderedEquals(['second', 'first', 'third']),
    );
  });

  testWidgets('shows a card around every property block', (WidgetTester tester) async {
    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(
        const JsonSchemaObjectNode(
          properties: {
            'plain': JsonSchemaStringNode(),
            'nested': JsonSchemaObjectNode(properties: {'child': JsonSchemaStringNode()}),
            'list': JsonSchemaArrayNode(items: JsonSchemaStringNode()),
          },
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JsonSchemaEditor(controller: controller, compactMode: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('property-card-plain')), findsOneWidget);
    expect(find.byKey(const ValueKey('property-card-nested')), findsOneWidget);
    expect(find.byKey(const ValueKey('property-card-list')), findsOneWidget);
    expect(find.byKey(const ValueKey('property-card-child')), findsOneWidget);
  });

  testWidgets('shows JSON Pointer paths for nested array item editors', (
    WidgetTester tester,
  ) async {
    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(
        const JsonSchemaArrayNode(items: JsonSchemaArrayNode(items: JsonSchemaStringNode())),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JsonSchemaEditor(controller: controller, compactMode: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('/-'), findsOneWidget);
    expect(find.text('/-/-'), findsOneWidget);
  });

  testWidgets('shows only active capabilities and adds new ones from the modal', (
    WidgetTester tester,
  ) async {
    final controller = JsonSchemaEditorController(
      extensionOptions: JsonSchemaEditorExtensionOptions(
        allowAddExtensions: false,
        configurableExtensionsForAllNodeTypes: const [
          JsonSchemaEditorExtensionField(
            key: 'x-token',
            description: 'Authorization token for this node.',
          ),
        ],
      ),
      initialSchema: JsonSchema.fromNode(const JsonSchemaStringNode(title: 'Label')),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JsonSchemaEditor(controller: controller, compactMode: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enum (comma/line list)'), findsNothing);
    expect(find.text('Extensions'), findsNothing);
    expect(find.text('Capabilities'), findsNothing);

    await tester.tap(find.text('Add capability'));
    await tester.pumpAndSettle();

    expect(find.text('Enum'), findsOneWidget);
    expect(find.text('x-token'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsWidgets);

    final extensionTile = find.widgetWithText(Tile, 'x-token');
    await tester.ensureVisible(extensionTile);
    await tester.tap(extensionTile);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Extensions'), findsNothing);
    expect(find.text('Capabilities'), findsOneWidget);
    expect(find.text('x-token'), findsWidgets);
    expect(find.text('active'), findsNothing);

    await tester.tap(find.text('Add capability'));
    await tester.pumpAndSettle();
    final enumTile = find.widgetWithText(Tile, 'Enum');
    await tester.ensureVisible(enumTile);
    await tester.tap(enumTile);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Enum (comma/line list)'), findsOneWidget);
    expect(find.text('Capabilities'), findsOneWidget);
  });

  testWidgets('keeps enum capability visible when emptied until explicitly removed', (
    WidgetTester tester,
  ) async {
    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(const JsonSchemaStringNode(title: 'Label')),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JsonSchemaEditor(controller: controller, compactMode: true)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add capability'));
    await tester.pumpAndSettle();
    final enumTile = find.widgetWithText(Tile, 'Enum');
    await tester.ensureVisible(enumTile);
    await tester.tap(enumTile);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final enumField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == 'Enum (comma/line list)',
    );

    expect(enumField, findsOneWidget);

    await tester.enterText(enumField, '');
    await tester.pumpAndSettle();

    expect(enumField, findsOneWidget);
    expect((controller.schema as JsonSchemaStringNode).enumValues, isEmpty);

    await tester.tap(find.byTooltip('Remove capability'));
    await tester.pumpAndSettle();

    expect(enumField, findsNothing);
    expect((controller.schema as JsonSchemaStringNode).enumValues, isNull);

    await tester.tap(find.text('Add capability'));
    await tester.pumpAndSettle();

    expect(find.text('Enum'), findsOneWidget);
  });

  testWidgets('applies configured min and max lines to string extension field', (
    WidgetTester tester,
  ) async {
    final controller = JsonSchemaEditorController(
      extensionOptions: JsonSchemaEditorExtensionOptions(
        configurableExtensionsForAllNodeTypes: const [
          JsonSchemaEditorExtensionField(
            key: 'x-notes',
            valueType: JsonSchemaEditorExtensionFieldType.string,
            minLines: 2,
            maxLines: 5,
            applicableNodeTypes: {JsonSchemaNodeType.string},
          ),
        ],
      ),
      initialSchema: JsonSchema.fromNode(
        const JsonSchemaStringNode(extensions: {'x-notes': 'Line 1'}),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: JsonSchemaEditor(controller: controller, compactMode: true)),
      ),
    );
    await tester.pumpAndSettle();

    final extensionField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.labelText == 'x-notes',
      ),
    );

    expect(extensionField.minLines, 2);
    expect(extensionField.maxLines, 5);
  });
}
