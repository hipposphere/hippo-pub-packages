import 'package:code_builder/code_builder.dart';
import 'package:postgres_models_builder/src/models/database_enum.dart';

import '../generate_types/types_generator.dart';

class EnumClassBuilder {
  final DatabaseEnum databaseEnum;
  final TypesGeneratorConfig config;
  late final DartEmitter dartEmitter;

  EnumClassBuilder({
    required this.databaseEnum,
    required this.config,
    bool orderDirectives = true,
    bool useNullSafetySyntax = true,
  }) : dartEmitter = DartEmitter(
         orderDirectives: orderDirectives,
         useNullSafetySyntax: useNullSafetySyntax,
       );

  late final EnumBuilder classBuilder = EnumBuilder();

  String build() {
    // assign the class name
    classBuilder.name = databaseEnum.enumName;
    classBuilder.values.addAll(
      databaseEnum.values.map(
        (e) => EnumValue((b) => b..name = databaseEnum.getDartSafeEnumValue(e)),
      ),
    );

    // from JsonString method
    classBuilder.methods.add(
      Method((b) {
        var returnStatement = '''return  ${databaseEnum.enumName}.values.byName(value);''';

        for (final value in databaseEnum.values) {
          if (value != databaseEnum.getDartSafeEnumValue(value)) {
            returnStatement =
                '''if(value == '$value') return ${databaseEnum.getDartSafeEnumValue(value)}; \n$returnStatement''';
          }
        }
        b
          ..name = 'fromJsonString'
          ..requiredParameters.add(
            Parameter(
              (b) => b
                ..name = 'value'
                ..type = const Reference('String'),
            ),
          )
          ..returns = Reference(databaseEnum.enumName)
          ..static = true
          ..body = Code(returnStatement);
      }),
    );

    // to JsonString method
    classBuilder.methods.add(
      Method((b) {
        var returnStatement = 'return name;';
        for (final value in databaseEnum.values) {
          if (value != databaseEnum.getDartSafeEnumValue(value)) {
            returnStatement =
                '''if(this == ${databaseEnum.enumName}.${databaseEnum.getDartSafeEnumValue(value)}) return '$value'; \n$returnStatement''';
          }
        }
        b
          ..name = 'toJsonString'
          ..returns = const Reference('String')
          ..body = Code(returnStatement);
      }),
    );

    String source = generateSource();

    if (databaseEnum.values.any((element) => element == element.toUpperCase())) {
      source = "// ignore: constant_identifier_names ";
    }

    return source;
  }

  String generateSource() => classBuilder.build().accept(dartEmitter).toString();
}
