// ignore_for_file: prefer_interpolation_to_compose_strings

part of '../postgres_reader.dart';

Future<List<DatabaseTable>> _getTables({
  String schemaName = 'public',
  required dynamic Function(String sqlCommand) query,
  List<String>? tableNames,
  List<String>? omitTableNames,
  List<ForeignKeyRelation>? foreignKeyRelations,
}) async {
  tableNames ??= const <String>[];
  final rawQuery = buildColumnTypesQuery(tableNames: tableNames, schemaName: schemaName);

  Log.trace('executing the following query:\n$rawQuery');

  final res = await query(rawQuery);

  final resList = List.of(res).map((e) => e['']).toList();

  // for some reason the table key is empty.
  // result coming like this: `{: {table_name: some_name, column_name: some_name, udt_name: text, is_nullable: NO}}`

  final tables = <DatabaseTable>[];
  print(omitTableNames);
  for (final result in resList) {
    final tableName = result[InfoSchemaColumnNames.tableName].toString().replaceAll(' ', '_');
    // the query ensures the table names are sorted so we can do this
    if (tables.isEmpty || tableName != tables.last.tableName) {
      print('reading: $schemaName.$tableName');
      Log.trace('reading table: $tableName');
      if ((omitTableNames?.contains(tableName) ?? false) ||
          (omitTableNames?.contains('$schemaName.$tableName') ?? false)) {
        // print('Skipping table $tableName');
        continue;
      }
      tables.add(DatabaseTable(schemaName, tableName, <DatabaseColumn>[]));
    }
    // get column data
    final columnName = result?[InfoSchemaColumnNames.columnName];
    final dataType = result?[InfoSchemaColumnNames.dataType];

    final isNullable = result?[InfoSchemaColumnNames.isNullable].toLowerCase() == 'yes'
        ? true
        : false;
    final columnDefault = result?[InfoSchemaColumnNames.columnDefault];
    final ordinalPosition = result?[InfoSchemaColumnNames.ordinalPosition];
    final identityGeneration = result?[InfoSchemaColumnNames.identityGeneration];

    Log.trace('read column: $columnName');

    final foreignKeyRelation = _findForeignKeyRelation(
      foreignKeyRelations ?? [],
      schemaName: schemaName,
      tableName: tableName,
      columnName: columnName,
    );

    if (schemaName == 'package_cloud' && tableName == 'package') {
      print('COLUMN NAME $columnName has foreign key relation $foreignKeyRelation');
    }

    final columnData = DatabaseColumn(
      tableName: tableName,
      columnKey: columnName,
      udtType: dataType,
      isNullable: isNullable,
      columnDefault: columnDefault,
      ordinalPosition: ordinalPosition,
      identityGeneration: identityGeneration,
      foreignKeyRelation: foreignKeyRelation,
    );

    tables.last.columns.add(columnData);
    tables.last.columns.sort((c1, c2) => c1.ordinalPosition.compareTo(c2.ordinalPosition));
  }

  for (final table in tables) {
    for (final column in table.columns) {
      if (column.foreignKeyRelation != null) {
        final relatedColumn = tables
            .where((element) => element.tableName == column.foreignKeyRelation!.foreignTableName)
            .firstOrNull
            ?.columns
            .where((element) => element.columnKey == column.foreignKeyRelation!.foreignColumnName)
            .firstOrNull;

        if (relatedColumn == null ||
            (relatedColumn.isKeyId == false && relatedColumn.foreignKeyRelation == null)) {
          // column.foreignKeyRelation = null;
        }
      }
    }
  }

  return tables;
}

String buildColumnTypesQuery({required String schemaName, required List<String> tableNames}) {
  final columns = InfoSchemaColumnNames.all.reduce((c1, c2) => c1 + ', ' + c2);
  String rawQuery =
      '''
SELECT $columns
FROM information_schema.columns
WHERE table_schema = '$schemaName'
''';
  if (tableNames.length == 1) {
    rawQuery = rawQuery + "AND table_name = '${tableNames[0]}'";
  } else if (tableNames.length > 1) {
    rawQuery =
        rawQuery + 'AND table_name in (' + tableNames.reduce((t1, t2) => "'$t1', '$t2'") + ')';
  }

  rawQuery = rawQuery + 'ORDER BY table_name ASC;';

  return rawQuery;
}

String buildForeignKeyTableQuery({required String schemaName}) {
  final rawQuery = '''SELECT
    tc.table_schema, 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema='$schemaName';''';

  return rawQuery;
}

/// a simple representation of a table

/// Returns a String represneting a dart type from a [postgresType]
/// (i.e. `udt_name` from `information_schema.columns`)
//  double check the types
//       The following was based on: https://github.com/SweetIQ/schemats/blob/master/src/schemaPostgres.ts

class InfoSchemaColumnNames {
  static const tableName = 'table_name';
  static const columnName = 'column_name';
  static const dataType = 'udt_name'; // do not use `data_type` (see: NOTES.md)
  static const isNullable = 'is_nullable';
  static const columnDefault = 'column_default';
  static const ordinalPosition = 'ordinal_position';
  static const identityGeneration = 'identity_generation';

  static const all = [
    tableName,
    columnName,
    dataType,
    isNullable,
    columnDefault,
    ordinalPosition,
    identityGeneration,
  ];
}

ForeignKeyRelation? _findForeignKeyRelation(
  List<ForeignKeyRelation> foreignKeyRelationsList, {
  required String schemaName,
  required String tableName,
  required String columnName,
}) {
  ForeignKeyRelation? foreignKeyRelation = foreignKeyRelationsList.where((element) {
    return element.tableSchema == schemaName &&
        element.tableName == tableName &&
        element.columnName == columnName;
  }).firstOrNull;

  if (foreignKeyRelation == null || foreignKeyRelation.foreignTableSchema == 'auth') {
    return null;
  }

  // Check if the foreign key relation is itself a foreign key relation
  final subForeignKey = _findForeignKeyRelation(
    foreignKeyRelationsList,
    schemaName: foreignKeyRelation.foreignTableSchema,
    tableName: foreignKeyRelation.foreignTableName,
    columnName: foreignKeyRelation.foreignColumnName,
  );

  return subForeignKey ?? foreignKeyRelation;
}
