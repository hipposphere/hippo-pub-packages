part of '../postgres_reader.dart';

Future<List<DatabaseColumnEnum>> _getCheckConstraintEnums({
  required dynamic Function(String sqlCommand) query,
  required String schemaName,
}) async {
  final result = await query(buildCheckConstraintEnumQuery(schemaName));
  final columnEnums = <DatabaseColumnEnum>[];
  final seenColumns = <String>{};

  for (final row in result) {
    final tableName = row[CheckConstraintColumnNames.tableName]?.toString();
    final columnName = row[CheckConstraintColumnNames.columnName]?.toString();
    final constraintName = row[CheckConstraintColumnNames.constraintName]?.toString();
    final constraintDefinition = row[CheckConstraintColumnNames.constraintDefinition]?.toString();

    if (tableName == null ||
        columnName == null ||
        constraintName == null ||
        constraintDefinition == null) {
      continue;
    }

    final enumValues = parseEnumValuesFromCheckConstraint(constraintDefinition);
    if (enumValues == null) {
      continue;
    }

    final columnIdentifier = '$schemaName.$tableName.$columnName';
    if (!seenColumns.add(columnIdentifier)) {
      continue;
    }

    columnEnums.add(
      DatabaseColumnEnum(
        schemaName: schemaName,
        tableName: tableName,
        columnName: columnName,
        constraintName: constraintName,
        databaseEnum: DatabaseEnum(enumType: '${tableName}_${columnName}_enum', values: enumValues),
      ),
    );
  }

  return columnEnums;
}

String buildCheckConstraintEnumQuery(String schemaName) {
  return '''
SELECT
    n.nspname AS table_schema,
    c.relname AS table_name,
    a.attname AS column_name,
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid, true) AS constraint_definition
FROM pg_constraint con
JOIN pg_class c ON c.oid = con.conrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN LATERAL unnest(con.conkey) ck(attnum) ON true
JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = ck.attnum
WHERE con.contype = 'c'
  AND n.nspname = '$schemaName'
  AND array_length(con.conkey, 1) = 1
ORDER BY c.relname, a.attname, con.conname;
''';
}

class CheckConstraintColumnNames {
  static const tableName = 'table_name';
  static const columnName = 'column_name';
  static const constraintName = 'constraint_name';
  static const constraintDefinition = 'constraint_definition';
}
