import 'package:code_builder/code_builder.dart';
import 'package:postgres_models_builder/src/models/database_column.dart';
import 'package:postgres_models_builder/src/models/database_enum.dart';
import 'package:postgres_models_builder/src/models/database_rpc.dart';
import 'package:postgres_models_builder/src/models/database_table.dart';
import '../generate_types/types_generator.dart';

class ExportLibraryBuilder {
  final List<DatabaseTable> tables;
  final List<DatabaseEnum> databaseEnum;
  final List<DatabaseRpc> databaseRpc;
  final List<DatabaseColumn> keyIds;
  final TypesGeneratorConfig config;
  late final DartEmitter dartEmitter;

  ExportLibraryBuilder({
    required this.tables,
    required this.databaseEnum,
    required this.databaseRpc,
    required this.keyIds,
    required this.config,
    bool orderDirectives = true,
    bool useNullSafetySyntax = true,
  }) : dartEmitter = DartEmitter(
         orderDirectives: orderDirectives,
         useNullSafetySyntax: useNullSafetySyntax,
       );

  late final LibraryBuilder libraryBuilder = LibraryBuilder();

  String build() {
    // assign the class name
    // libraryBuilder.name = 'public_supabase_models';
    libraryBuilder.directives.clear();
    libraryBuilder.directives.addAll([
      for (final tableName in tables.map((e) => e.tableName).toSet()) ...[
        Directive.export('models/$tableName/${tableName}_insert.g.dart'),
        Directive.export('models/$tableName/${tableName}_update.g.dart'),
        Directive.export('models/$tableName/${tableName}_partial.g.dart'),
        Directive.export('models/$tableName/${tableName}_row.g.dart'),
      ],
      for (final databaseEnumType in databaseEnum.map((e) => e.enumType).toSet())
        Directive.export('enums/$databaseEnumType.g.dart'),
      for (final rpc in databaseRpc.map((e) => e.uniqueFunctionName).toSet())
        Directive.export('rpcs/$rpc.g.dart'),
      for (final keyId in keyIds.where((element) => element.isKeyId))
        Directive.export('keys/${keyId.tableName}_id.g.dart'),
    ]);
    libraryBuilder.directives.add(
      Directive.export('package:postgres_base_models/postgres_base_models.dart'),
    );
    String source = generateSource();

    return source;
  }

  String generateSource() => libraryBuilder.build().accept(dartEmitter).toString();
}
