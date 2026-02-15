import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/normalize_openapi.dart <openapi-json-path>',
    );
    exitCode = 64;
    return;
  }

  final file = File(args.first);
  if (!file.existsSync()) {
    stderr.writeln('OpenAPI file does not exist: ${file.path}');
    exitCode = 66;
    return;
  }

  final raw = file.readAsStringSync();
  final root = jsonDecode(raw);

  if (root is! Map<String, dynamic>) {
    stderr.writeln('Expected OpenAPI root object to be a JSON object.');
    exitCode = 65;
    return;
  }

  var normalizedCount = 0;

  void normalizeNode(dynamic node) {
    if (node is List<dynamic>) {
      for (final child in node) {
        normalizeNode(child);
      }
      return;
    }

    if (node is! Map<String, dynamic>) {
      return;
    }

    final anyOf = node['anyOf'];
    if (anyOf is List<dynamic> && anyOf.length == 2) {
      Map<String, dynamic>? enumSchema;
      var hasNullSchema = false;

      for (final candidate in anyOf) {
        if (candidate is! Map<String, dynamic>) {
          continue;
        }

        final type = candidate['type'];
        if (type == 'null') {
          hasNullSchema = true;
          continue;
        }

        final enumValues = candidate['enum'];
        if (type == 'string' && enumValues is List<dynamic>) {
          enumSchema = candidate;
        }
      }

      if (enumSchema != null && hasNullSchema) {
        node
          ..remove('anyOf')
          ..['type'] = 'string'
          ..['enum'] = enumSchema['enum']
          ..['nullable'] = true;
        normalizedCount++;
      }
    }

    for (final child in node.values) {
      normalizeNode(child);
    }
  }

  normalizeNode(root);

  file.writeAsStringSync('${JsonEncoder.withIndent('  ').convert(root)}\n');
  stdout.writeln(
    'Normalized $normalizedCount nullable enum schemas in ${file.path}',
  );
}
