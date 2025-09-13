class TableDefinition<TInsert, TUpdate, TRow> {
  final String schemaName;
  final String tableName;

  final TInsert Function(Map<String, dynamic> map) insertParser;
  final Map<String, dynamic> Function(TInsert insert) toInsertMap;
  final TUpdate Function(Map<String, dynamic> map) updateParser;
  final Map<String, dynamic> Function(TUpdate update) toUpdateMap;
  final TRow Function(Map<String, dynamic> map) rowParser;
  final Map<String, dynamic> Function(TRow row) toRowMap;

  const TableDefinition({
    required this.schemaName,
    required this.tableName,
    required this.insertParser,
    required this.toInsertMap,
    required this.updateParser,
    required this.toUpdateMap,
    required this.rowParser,
    required this.toRowMap,
  });
}
