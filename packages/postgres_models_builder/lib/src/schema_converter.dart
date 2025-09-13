import 'dart:io';

import 'package:postgres_models_builder/src/logger.dart';
import 'package:postgres_models_builder/src/models/database_enum.dart';
import 'package:postgres_models_builder/src/models/database_rpc.dart';
import 'package:postgres_models_builder/src/models/database_table.dart';
import 'package:postgres_models_builder/src/generate_types/types_generator.dart';
import 'package:path/path.dart' as p;
import 'package:postgres_models_builder/src/models/foreign_key_relation.dart';

import 'postgres_reader/postgres_reader.dart';

class SchemaConverter {
  final String connectionString;
  final Directory outputDirectory;

  /// the schema to generate data classes from
  final List<String> schemaList;

  /// an optional list of tables to generate the data classes fromƒ
  final List<String>? tableNames;
  final List<String>? omitTableNames;
  final List<String>? omitRpcNames;

  late List<DatabaseTable> tables;
  late List<DatabaseRpc> rpcs;
  late List<DatabaseEnum> enums;

  late TypesGenerator typesGenerator;

  SchemaConverter({
    required this.connectionString,
    required this.outputDirectory,
    required this.schemaList,
    this.tableNames,
    this.omitTableNames,
    this.omitRpcNames,
  });

  Future<void> convert() async {
    // read tables
    Log.trace('started reading tables');
    var progress = Log.progress('reading tables');
    await _readTables();
    progress.finish(
      message:
          'found ${tables.length} - tables, found ${rpcs.length} - rpcs,found ${enums.length} - enums',
    );

    // generate source code
    Log.trace('generating dart classes');
    progress = Log.progress('generating dart source code for tables');
    await _addDartSourceToTables();
    progress.finish(message: 'sources were generated.');

    // write sources to output directory
    Log.trace('writing files to output directory');
    progress = Log.progress('writing files to output directory');
    await _writeFilesToOutputDirectory();
    progress.finish(message: 'files were written at ${outputDirectory.path}');
  }

  Future<void> _readTables() async {
    final reader = PostgresReader.fromConnectionString(connectionString);
    Log.trace('connecting to database');
    await reader.connect();

    enums = [for (final schema in schemaList) ...await reader.getEnums(schemaName: schema)];

    final List<ForeignKeyRelation> foreignKeyRelations = [
      for (final schema in schemaList) ...await reader.getForeignKeyRelations(schemaName: schema),
    ];

    Log.trace('calling PostgresReader.getTables with omitting $omitTableNames');
    tables = [
      for (final schema in schemaList)
        ...await reader.getTables(
          schemaName: schema,
          tableNames: tableNames,
          omitTableNames: omitTableNames,
          foreignKeyRelations: foreignKeyRelations,
        ),
    ];

    Log.trace('calling PostgresReader.getRpcs with omitting $omitRpcNames');
    rpcs = [
      for (final schema in schemaList)
        ...await reader.getRpcs(schemaName: schema, omitRpcNames: omitRpcNames, enums: enums),
    ];
    Log.trace('calling PostgresReader.getRpcs');

    Log.trace('disconnecting the database');
    await reader.disconnect();
  }

  Future<void> _addDartSourceToTables() async {
    typesGenerator = TypesGenerator(
      outputDirectory: outputDirectory,
      tables: tables,
      enums: enums,
      rpcs: rpcs,
    );
    await typesGenerator.addDartSourceToTables();
  }

  Future<void> _writeFilesToOutputDirectory() async {
    final futures = <Future>[];
    Log.trace('writing files');
    for (final table in typesGenerator.generatedModels.entries) {
      final tableName = table.key;
      final tableFiles = table.value;
      for (final tableFile in tableFiles) {
        final file = File(
          p.join(outputDirectory.path, 'models/$tableName/', '${tableFile.fileName}.g.dart'),
        );
        futures.add(
          file.create(recursive: true).then((value) => file.writeAsString(tableFile.sourceCode)),
        );
      }
    }
    for (final generatedEnum in typesGenerator.generatedEnums) {
      final file = File(p.join(outputDirectory.path, 'enums/', '${generatedEnum.fileName}.g.dart'));
      futures.add(
        file.create(recursive: true).then((value) => file.writeAsString(generatedEnum.sourceCode)),
      );
    }
    for (final generatedRpcs in typesGenerator.generatedRpcs) {
      final file = File(p.join(outputDirectory.path, 'rpcs/', '${generatedRpcs.fileName}.g.dart'));
      futures.add(
        file.create(recursive: true).then((value) => file.writeAsString(generatedRpcs.sourceCode)),
      );
    }

    for (final generatedKey in typesGenerator.generatedKeyIds) {
      final file = File(p.join(outputDirectory.path, 'keys/', '${generatedKey.fileName}.g.dart'));
      futures.add(
        file.create(recursive: true).then((value) => file.writeAsString(generatedKey.sourceCode)),
      );
    }
    final libraryFile = File(p.join(outputDirectory.path, 'public_supabase_models.dart'));
    futures.add(
      libraryFile
          .create(recursive: true)
          .then(
            (value) => libraryFile.writeAsString(typesGenerator.generatedExportLibrary.sourceCode),
          ),
    );

    final tableDefintionsFile = File(p.join(outputDirectory.path, 'table_definitions.dart'));
    futures.add(
      tableDefintionsFile
          .create(recursive: true)
          .then(
            (value) => tableDefintionsFile.writeAsString(
              typesGenerator.generatedTableDefinitions.sourceCode,
            ),
          ),
    );
    await Future.wait(futures);
  }
}
