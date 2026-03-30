import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  group('validateSchema', () {
    test('merges built-in and custom diagnostics and supports multiple warnings per node', () {
      const schema = JsonSchemaObjectNode(
        properties: {'name': JsonSchemaStringNode(enumValues: [])},
      );

      final diagnostics = validateSchema(
        schema,
        customValidators: [
          (root) sync* {
            for (final visit in root.traverse()) {
              final node = visit.node;
              final path = visit.path;
              if ((node.description?.trim().isEmpty ?? true)) {
                yield JsonSchemaDiagnostic(
                  path: path,
                  message: 'Description is required.',
                  severity: JsonSchemaDiagnosticSeverity.warning,
                );
              }
              if (!node.extensions.containsKey('x-token')) {
                yield JsonSchemaDiagnostic(
                  path: path,
                  message: 'x-token extension is required.',
                  severity: JsonSchemaDiagnosticSeverity.warning,
                );
              }
            }
          },
        ],
      );

      expect(diagnostics.any((item) => item.message == 'enum list should not be empty.'), isTrue);
      expect(
        diagnostics
            .where((item) => item.path == const JsonSchemaPath.root())
            .map((item) => item.message),
        containsAll(['Description is required.', 'x-token extension is required.']),
      );
      expect(
        diagnostics
            .where((item) => item.path == const JsonSchemaPath.root().childProperty('name'))
            .map((item) => item.message),
        containsAll([
          'Description is required.',
          'x-token extension is required.',
          'enum list should not be empty.',
        ]),
      );
    });
  });
}
