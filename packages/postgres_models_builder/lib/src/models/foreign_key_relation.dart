class ForeignKeyRelation {
  final String tableSchema;
  final String tableName;
  final String columnName;
  final String foreignTableSchema;
  final String foreignTableName;
  final String foreignColumnName;

  const ForeignKeyRelation({
    required this.tableSchema,
    required this.tableName,
    required this.columnName,
    required this.foreignTableSchema,
    required this.foreignTableName,
    required this.foreignColumnName,
  });

  factory ForeignKeyRelation.fromMap(dynamic map) {
    return ForeignKeyRelation(
      tableSchema: map['table_schema'],
      tableName: map['table_name'],
      columnName: map['column_name'],
      foreignTableSchema: map['foreign_table_schema'],
      foreignTableName: map['foreign_table_name'],
      foreignColumnName: map['foreign_column_name'],
    );
  }

  @override
  String toString() {
    return 'ForeignKeyRelation(tableSchema: $tableSchema, tableName: $tableName, columnName: $columnName, foreignTableSchema: $foreignTableSchema, foreignTableName: $foreignTableName, foreignColumnName: $foreignColumnName)';
  }
}
