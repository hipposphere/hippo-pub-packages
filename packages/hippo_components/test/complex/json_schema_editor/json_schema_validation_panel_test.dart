import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_components/src/complex/json_schema_editor/widgets/json_schema_validation_panel.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  testWidgets('renders success state when no warnings are present', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: JsonSchemaValidationPanel(diagnostics: [])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Validation'), findsOneWidget);
    expect(find.text('No warnings detected'), findsOneWidget);
    expect(find.text('Schema looks good.'), findsOneWidget);
    expect(find.byKey(const ValueKey('validation-success-avatar')), findsOneWidget);
  });

  testWidgets('renders warning count and warning messages', (WidgetTester tester) async {
    const diagnostics = [
      JsonSchemaDiagnostic(
        path: JsonSchemaPath.root(),
        message: 'Title should not be empty.',
        severity: JsonSchemaDiagnosticSeverity.warning,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: JsonSchemaValidationPanel(diagnostics: diagnostics)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Validation'), findsOneWidget);
    expect(find.text('1 warning'), findsOneWidget);
    expect(find.text(r'$: Title should not be empty.'), findsOneWidget);
  });
}
