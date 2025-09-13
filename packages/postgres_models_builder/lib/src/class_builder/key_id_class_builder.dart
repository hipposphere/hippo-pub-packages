import 'package:code_builder/code_builder.dart';
import 'package:postgres_models_builder/src/models/database_column.dart';
import 'package:postgres_models_builder/src/util.dart';

import '../generate_types/types_generator.dart';

class KeyIdClassBuilder {
  final String tableName;
  final DatabaseColumn column;
  final TypesGeneratorConfig config;
  late final DartEmitter dartEmitter;

  KeyIdClassBuilder({
    required this.column,
    required this.tableName,
    required this.config,
    bool orderDirectives = true,
    bool useNullSafetySyntax = true,
  }) : dartEmitter = DartEmitter(
         orderDirectives: orderDirectives,
         useNullSafetySyntax: useNullSafetySyntax,
       );

  late final ClassBuilder classBuilder = ClassBuilder();

  String get className =>
      tableName.convertSnakeCaseToCamelCase().toUpperCaseFirst() +
      column.columnKey.convertSnakeCaseToCamelCase().toUpperCaseFirst();
  String get keyName => column.columnKey.convertSnakeCaseToCamelCase();

  String build() {
    // assign the class name
    classBuilder.name = className;
    classBuilder.fields.add(
      Field((field) {
        field.name = 'id';
        field.type = refer(column.rawDartType);
        field.modifier = FieldModifier.final$;
        field.annotations.add(refer('override'));
      }),
    );

    classBuilder.extend = refer(
      column.keyIdType == KeyIdType.string ? 'StringId' : 'IntId',
    );

    classBuilder.constructors.add(
      Constructor((c) {
        c.requiredParameters.add(
          Parameter((param) {
            param.name = 'id';
            param.toThis = true;
          }),
        );
        c.constant = true;
      }),
    );

    // Override hashCode method
    classBuilder.methods.add(
      Method((method) {
        method
          ..name = 'hashCode'
          ..returns = refer('int')
          ..type = MethodType.getter
          ..annotations.add(refer('override'))
          ..lambda = true
          ..body = Code('''
         id.hashCode
        ''');
      }),
    );

    // Override == operator
    classBuilder.methods.add(
      Method((method) {
        method
          ..name = 'operator =='
          ..returns = refer('bool')
          ..annotations.add(refer('override'))
          ..requiredParameters.add(
            Parameter((param) {
              param.name = 'other';
            }),
          )
          ..body = Code('''
        return other is ${classBuilder.name} && other.id == $keyName;
        ''');
      }),
    );

    String source = generateSource();
    source =
        "import 'package:postgres_base_models/postgres_base_models.dart';\n$source";
    return source;
  }

  String generateSource() =>
      classBuilder.build().accept(dartEmitter).toString();
}
