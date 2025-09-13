import 'package:code_builder/code_builder.dart';
import 'package:postgres_models_builder/src/models/database_table.dart';
import 'package:postgres_models_builder/src/util.dart';
import '../generate_types/types_generator.dart';

class TableDefinitionsBuilder {
  final List<DatabaseTable> tables;
  final TypesGeneratorConfig config;
  late final DartEmitter dartEmitter;

  TableDefinitionsBuilder({
    required this.tables,
    required this.config,
    bool orderDirectives = true,
    bool useNullSafetySyntax = true,
  }) : dartEmitter = DartEmitter(
         orderDirectives: orderDirectives,
         useNullSafetySyntax: useNullSafetySyntax,
       );

  late final ClassBuilder classBuilder = ClassBuilder();

  String build() {
    // assign the class name
    // libraryBuilder.name = 'public_supabase_models';
    classBuilder.name = 'TableDefinitions';
    classBuilder.constructors.add(
      Constructor((b) {
        b
          ..name = '_'
          ..constant = true;
      }),
    );
    classBuilder.fields.addAll([
      for (final table in tables) ...[
        Field((field) {
          field
            ..name = '${table.dartClassName.toLowerCaseFirst()}Table'
            ..modifier = FieldModifier.final$
            ..static = true
            ..assignment = Code(
              "TableDefinition<${table.dartClassName}Insert, ${table.dartClassName}Update, ${table.dartClassName}>(schemaName: '${table.schemaName}', tableName: '${table.tableName}', insertParser: ${table.dartClassName}Insert.fromMap,toInsertMap: (e) => e.toMap(), updateParser: ${table.dartClassName}Update.fromMap,toUpdateMap: (e) => e.toMap(), rowParser: ${table.dartClassName}.fromMap,toRowMap: (e) => e.toMap(),)",
            );
        }),
      ],
    ]);

    String source = generateSource();
    source = "import 'public_supabase_models.dart';\n$source";
    return source;
  }

  String generateSource() =>
      classBuilder.build().accept(dartEmitter).toString();
}
