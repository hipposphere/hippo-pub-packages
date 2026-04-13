import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_components/src/complex/json_schema_visualization/json_schema_visualization_panel.dart';
import 'package:hippo_utils/hippo_utils.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('switches between optimized and pure json preview modes', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(
        const JsonSchemaObjectNode(
          title: 'Account',
          properties: {'name': JsonSchemaStringNode(title: 'Name')},
        ),
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        JsonSchemaVisualizationPanel(controller: controller, schema: controller.toJsonSchema()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(JsonSchemaVisualization), findsOneWidget);

    await tester.tap(find.text('JSON'));
    await tester.pumpAndSettle();

    expect(find.byType(JsonSchemaVisualization), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.data != null &&
            widget.data!.contains('"type": "object"'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Optimized'));
    await tester.pumpAndSettle();

    expect(find.byType(JsonSchemaVisualization), findsOneWidget);
  });

  testWidgets('json preview reflects reordered properties', (WidgetTester tester) async {
    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(
        const JsonSchemaObjectNode(
          properties: {
            'first': JsonSchemaStringNode(title: 'First'),
            'second': JsonSchemaStringNode(title: 'Second'),
            'third': JsonSchemaStringNode(title: 'Third'),
          },
        ),
      ),
    );

    controller.movePropertyDown(objectPath: const JsonSchemaPath.root(), key: 'first');

    await tester.pumpWidget(
      _buildTestApp(
        JsonSchemaVisualizationPanel(controller: controller, schema: controller.toJsonSchema()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('JSON'));
    await tester.pumpAndSettle();

    final rawJsonWidget = tester.widget<SelectableText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.data != null &&
            widget.data!.contains('"properties"'),
      ),
    );
    final rawJson = rawJsonWidget.data!;

    expect(rawJson.indexOf('"second": {'), lessThan(rawJson.indexOf('"first": {')));
    expect(rawJson.indexOf('"first": {'), lessThan(rawJson.indexOf('"third": {')));
  });
}
