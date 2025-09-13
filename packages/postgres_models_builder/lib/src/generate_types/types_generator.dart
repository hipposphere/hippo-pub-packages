import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:postgres_models_builder/src/class_builder/export_library_buider.dart';
import 'package:postgres_models_builder/src/class_builder/rpc_class_builder.dart';
import 'package:postgres_models_builder/src/class_builder/table_definitions_builder.dart';
import 'package:postgres_models_builder/src/models/dart_file_source_code.dart';
import 'package:postgres_models_builder/src/models/database_column.dart';
import 'package:postgres_models_builder/src/models/database_rpc.dart';
import 'package:postgres_models_builder/src/models/database_table.dart';

import '../class_builder/enum_class_builder.dart';
import '../class_builder/data_class_builder.dart';
import '../class_builder/key_id_class_builder.dart';
import '../models/database_enum.dart';
import '../models/model_type.dart';

/// Generates Dart type definitions (aka data classes) from [Table]s
class TypesGenerator {
  final Directory outputDirectory;

  final List<DatabaseTable> tables;
  final List<DatabaseEnum> enums;
  final List<DatabaseRpc> rpcs;
  final TypesGeneratorConfig config;

  final List<DartFileSourceCode> generatedKeyIds = [];
  final List<DartFileSourceCode> generatedEnums = [];
  final List<DartFileSourceCode> generatedRpcs = [];
  final Map<String, List<DartFileSourceCode>> generatedModels = {};
  late DartFileSourceCode generatedExportLibrary;
  late DartFileSourceCode generatedTableDefinitions;

  final formatter = DartFormatter(
    pageWidth: 100,
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  TypesGenerator({
    required this.outputDirectory,
    required this.tables,
    required this.rpcs,
    required this.enums,
    this.config = const TypesGeneratorConfig(),
  });

  Future<void> addDartSourceToTables() async {
    generatedEnums.clear();
    generatedModels.clear();
    generatedRpcs.clear();
    final List<DatabaseColumn> keyIds = [];
    for (final table in tables) {
      final tableFiles = <DartFileSourceCode>[];

      final idColumn = table.columns.where((element) => element.isKeyId).firstOrNull;
      if (idColumn != null) {
        final keyIdBuilder = KeyIdClassBuilder(
          config: config,
          tableName: table.tableName,
          column: idColumn,
        );
        final keyIdSource = keyIdBuilder.build();
        final keyIdSourceCode = DartFileSourceCode(
          fileName: '${table.tableName}_${idColumn.columnKey}',
          sourceCode: formatter.format(keyIdSource),
        );
        generatedKeyIds.add(keyIdSourceCode);
        keyIds.add(idColumn);
      }

      for (final modelType in [
        ModelType.insert,
        ModelType.update,
        ModelType.row,
        ModelType.partial,
      ]) {
        final builder = DataClassBuilder(config: config, table: table, modelType: modelType);
        final source = builder.build();

        final sourceCode = DartFileSourceCode(
          fileName: '${table.tableName}_${modelType.name}',
          sourceCode: formatter.format(source),
        );
        tableFiles.add(sourceCode);
      }

      generatedModels[table.tableName] = tableFiles;
    }

    for (final databaseEnum in enums) {
      final builder = EnumClassBuilder(config: config, databaseEnum: databaseEnum);
      final source = builder.build();
      final sourceCode = DartFileSourceCode(
        fileName: databaseEnum.enumType,
        sourceCode: formatter.format(source),
      );
      generatedEnums.add(sourceCode);
    }
    for (final databaseRpc in rpcs) {
      final builder = RpcClassBuilder(config: config, databaseRpc: databaseRpc);
      final source = builder.build();
      final sourceCode = DartFileSourceCode(
        fileName: databaseRpc.uniqueFunctionName,
        sourceCode: formatter.format(source),
      );
      generatedRpcs.add(sourceCode);
    }
    final exportLibrary = ExportLibraryBuilder(
      config: TypesGeneratorConfig(),
      databaseEnum: enums,
      tables: tables,
      databaseRpc: rpcs,
      keyIds: keyIds,
    );
    final exportLibrarySource = exportLibrary.build();
    generatedExportLibrary = DartFileSourceCode(
      fileName: 'public_models',
      sourceCode: formatter.format(exportLibrarySource),
    );

    final tableDefinitionsLibrary = TableDefinitionsBuilder(
      config: TypesGeneratorConfig(),
      tables: tables,
    );
    final tableDefinitionsSource = tableDefinitionsLibrary.build();
    generatedTableDefinitions = DartFileSourceCode(
      fileName: 'table_definitions',
      sourceCode: formatter.format(tableDefinitionsSource),
    );
  }
}

class TypesGeneratorConfig {
  final bool generateCopyWith;
  final bool generateSerialization;
  final bool generateEquality;
  final bool generateToString;

  final bool buildFromSerializerForInsertAndUpdate;

  const TypesGeneratorConfig({
    this.generateCopyWith = true,
    this.generateSerialization = true,
    this.generateEquality = true,
    this.generateToString = true,
    this.buildFromSerializerForInsertAndUpdate = true,
  });
}
