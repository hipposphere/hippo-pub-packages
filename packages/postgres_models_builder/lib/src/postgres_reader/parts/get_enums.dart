part of '../postgres_reader.dart';

Future<List<DatabaseEnum>> _getEnums({
  required dynamic Function(String sqlCommand) query,
  required String schemaName,
}) async {
  final enums = <DatabaseEnum>[];

  final result = (await query(buildEnumQuery(schemaName)));

  for (final enumData in result) {
    try {
      final String values = enumData['enum_values'];

      enums.add(
        DatabaseEnum(
          enumType: enumData['pg_type']['enum_name'],
          values: List<String>.from(values.split(', ').map((e) => e.trim())),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  return enums;
}

String buildEnumQuery(String schemaName) {
  return '''
SELECT n.nspname as schema_name, 
       t.typname as enum_name, 
       string_agg(e.enumlabel, ', ' ORDER BY e.enumsortorder) as enum_values
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
JOIN pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname = '$schemaName' -- Filter by schema
GROUP BY schema_name, enum_name
ORDER BY schema_name, enum_name;
''';
}
