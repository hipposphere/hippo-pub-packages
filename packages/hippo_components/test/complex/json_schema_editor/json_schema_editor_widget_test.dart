import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  testWidgets('renders editor and reacts to root type changes', (WidgetTester tester) async {
    final controller = JsonSchemaEditorController(
      initialSchema: JsonSchema.fromNode(
        const JsonSchemaStringNode(title: 'Label'),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JsonSchemaEditor(controller: controller, compactMode: true),
        ),
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
}
