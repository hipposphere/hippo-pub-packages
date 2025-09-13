import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:postgres_models_builder/src/models/database_rpc.dart';

import '../generate_types/types_generator.dart';

class RpcClassBuilder {
  final DatabaseRpc databaseRpc;
  final TypesGeneratorConfig config;
  late final DartEmitter dartEmitter;

  RpcClassBuilder({
    required this.databaseRpc,
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
    classBuilder.name = databaseRpc.dartClassName;
    classBuilder.implements = ListBuilder([
      refer('RpcFunctionDefinition<dynamic>'),
    ]);

    /// arguments & constructor

    for (final argument in databaseRpc.arguments) {
      classBuilder.fields.add(
        Field(
          (b) => b
            ..name = argument.dartArgumentName
            ..type = refer(argument.dartType)
            ..modifier = FieldModifier.final$,
        ),
      );
    }
    classBuilder.constructors.add(
      Constructor((c) {
        c.optionalParameters = ListBuilder(
          databaseRpc.arguments.map(
            (e) => Parameter(
              (p) => p
                ..name = e.dartArgumentName
                ..named = true
                ..toThis = true
                ..required = true,
            ),
          ),
        );
      }),
    );

    /// functionName

    classBuilder.fields.add(
      Field(
        (b) => b
          ..annotations.add(refer('override'))
          ..name = 'functionName'
          ..modifier = FieldModifier.final$
          ..assignment = Code('\'${databaseRpc.functionName}\'')
          ..type = refer('String'),
      ),
    );

    // ignore: prefer_interpolation_to_compose_strings
    final paramsCode =
        // ignore: prefer_interpolation_to_compose_strings
        '{' +
        (databaseRpc.arguments
            .map((e) => '\'${e.argumentName}\': ${e.getToFormatter()},')
            .join('\n')) +
        '}';

    /// params getter
    classBuilder.methods.add(
      Method(
        (b) => b
          ..annotations.add(refer('override'))
          ..name = 'params'
          ..returns = refer('Map<String, dynamic>')
          ..type = MethodType.getter
          ..lambda = true
          ..body = Code(paramsCode),
      ),
    );

    /// responseBuilder

    classBuilder.fields.add(
      Field(
        (b) => b
          ..annotations.add(refer('override'))
          ..name = 'responseBuilder'
          ..modifier = FieldModifier.final$
          ..assignment = Code('(data) => data')
          ..type = refer('dynamic Function(dynamic data)'),
      ),
    );

    String source = generateSource();
    // \nimport 'package:app_tools/universal_tools.dart';
    source =
        "import 'package:postgres_base_models/postgres_base_models.dart';  \n$source";

    for (final argument in databaseRpc.arguments) {
      if (argument.enumType != null) {
        source =
            "import '../enums/${argument.enumType!.enumType}.g.dart';\n$source";
      }
    }

    return source;
  }

  String generateSource() =>
      classBuilder.build().accept(dartEmitter).toString();
}
