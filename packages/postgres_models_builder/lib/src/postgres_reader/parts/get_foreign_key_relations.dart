part of '../postgres_reader.dart';

Future<List<ForeignKeyRelation>> _getForeignKeyRelations({
  String schemaName = 'public',
  required dynamic Function(String sqlCommand) query,
}) async {
  final foreignKeyRes = await query(buildForeignKeyTableQuery(schemaName: schemaName));
  final foreignKeyRelationsList = List.of(foreignKeyRes).map((value) {
    return ForeignKeyRelation.fromMap(value);
  }).toList();
  return foreignKeyRelationsList;
}
