import 'package:postgres_models_builder/src/util.dart';

import 'database_column.dart';

class DatabaseTable {
  final String schemaName;
  final String tableName;
  final List<DatabaseColumn> columns;

  const DatabaseTable(this.schemaName, this.tableName, this.columns);

  String get dartClassName =>
      tableName.convertSnakeCaseToCamelCase().toUpperCaseFirst();

  String toSchemaTableName() {
    return '${schemaName.isEmpty ? '' : '"$schemaName".'}$tableName';
  }

  @override
  String toString() {
    return 'DatabaseTable(schemaName: $schemaName, tableName: $tableName, columns: ${columns.length})';
  }
}
