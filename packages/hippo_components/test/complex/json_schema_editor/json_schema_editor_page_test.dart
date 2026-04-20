import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: ComponentsLocalizations.localizationsDelegates,
    supportedLocales: ComponentsLocalizations.supportedLocales,
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: child,
  );
}

void main() {
  testWidgets('does not render the explanation guide inline on desktop', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = JsonSchemaEditorController(
      featureOptions: const JsonSchemaEditorFeatureOptions(
        arrayOptions: JsonSchemaEditorArrayFeatureOptions(uniqueItems: false),
      ),
      extensionOptions: JsonSchemaEditorExtensionOptions(
        configurableExtensions: [
          JsonSchemaEditorExtensionField(
            key: 'x-token',
            label: (_) => 'Token',
            description: (_) => 'Authorization metadata for this schema node.',
          ),
        ],
      ),
      initialSchema: JsonSchema.fromNode(
        const JsonSchemaObjectNode(
          title: 'Account schema',
          properties: {'name': JsonSchemaStringNode(title: 'Name')},
        ),
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        JsonSchemaEditorPage(
          title: 'JSON Schema Editor',
          controller: controller,
          explanationDescription: 'Custom schema guide text',
          onSave: (context, schema) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('json-schema-explaination-page')), findsNothing);
    expect(find.text('JSON Schema Guide'), findsNothing);
    expect(find.text('Custom schema guide text'), findsNothing);
    expect(find.text('General concept'), findsNothing);
    expect(find.text('Node types'), findsNothing);
    expect(find.text('Supported capabilities'), findsNothing);
    expect(find.text('Configured extensions'), findsNothing);
    expect(find.text('Token'), findsNothing);
  });

  testWidgets('opens the guide route from the root schema actions menu', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = JsonSchemaEditorController(
      featureOptions: const JsonSchemaEditorFeatureOptions(
        arrayOptions: JsonSchemaEditorArrayFeatureOptions(uniqueItems: false),
      ),
      extensionOptions: JsonSchemaEditorExtensionOptions(
        configurableExtensions: [
          JsonSchemaEditorExtensionField(
            key: 'x-token',
            label: (_) => 'Token',
            description: (_) => 'Authorization metadata for this schema node.',
          ),
        ],
      ),
      initialSchema: JsonSchema.fromNode(
        const JsonSchemaObjectNode(
          title: 'Account schema',
          properties: {'name': JsonSchemaStringNode(title: 'Name')},
        ),
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        JsonSchemaEditorPage(
          title: 'JSON Schema Editor',
          controller: controller,
          explanationDescription: 'Custom schema guide text',
          onSave: (context, schema) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guide'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('json-schema-explaination-page')), findsOneWidget);
    expect(find.text('JSON Schema Guide'), findsWidgets);
    expect(find.text('Custom schema guide text'), findsOneWidget);
    expect(find.text('General concept'), findsOneWidget);
    expect(find.text('Node types'), findsOneWidget);
    expect(find.text('Supported capabilities'), findsOneWidget);
    expect(find.text('Configured extensions'), findsOneWidget);
    expect(find.text('Token'), findsWidgets);
    expect(find.text('Unique items'), findsNothing);
  });

  testWidgets('imports pasted JSON from the root schema actions menu', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(const JsonSchemaStringNode(title: 'Label')),
    );

    await tester.pumpWidget(
      _buildTestApp(
        JsonSchemaEditorPage(
          title: 'JSON Schema Editor',
          controller: controller,
          onSave: (context, schema) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from JSON'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('json-schema-import-page')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('json-schema-import-json-field')), '''
{
  "type": "object",
  "title": "Imported schema",
  "properties": {
    "enabled": {
      "type": "boolean",
      "default": true
    }
  },
  "required": ["enabled"]
}
''');
    tester
        .widget<PageHeaderTextAction>(find.byKey(const ValueKey('json-schema-import-action')))
        .onTap!();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('json-schema-import-page')), findsNothing);
    final schema = controller.schema as JsonSchemaObjectNode;
    expect(schema.title, 'Imported schema');
    expect(schema.required, contains('enabled'));
    expect(schema.properties['enabled'], isA<JsonSchemaBooleanNode>());
  });

  testWidgets('keeps the import page open for invalid JSON', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(const JsonSchemaStringNode(title: 'Label')),
    );

    await tester.pumpWidget(
      _buildTestApp(
        JsonSchemaEditorPage(
          title: 'JSON Schema Editor',
          controller: controller,
          onSave: (context, schema) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import from JSON'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('json-schema-import-json-field')), '[');
    tester
        .widget<PageHeaderTextAction>(find.byKey(const ValueKey('json-schema-import-action')))
        .onTap!();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('json-schema-import-page')), findsOneWidget);
    expect(find.textContaining('Unexpected end of input'), findsOneWidget);
    expect(controller.schema, isA<JsonSchemaStringNode>());
    expect((controller.schema as JsonSchemaStringNode).title, 'Label');
  });

  testWidgets('does not add a guide tab on smaller layouts', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(700, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(const JsonSchemaStringNode(title: 'Label')),
    );

    await tester.pumpWidget(
      _buildTestApp(
        JsonSchemaEditorPage(
          title: 'JSON Schema Editor',
          controller: controller,
          explanationDescription: 'Compact guide text',
          onSave: (context, schema) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editor'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Guide'), findsNothing);
    expect(find.byKey(const ValueKey('json-schema-explaination-page')), findsNothing);
    expect(find.text('Compact guide text'), findsNothing);
  });
}
