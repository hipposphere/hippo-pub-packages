import 'package:built_collection/built_collection.dart';
import 'package:code_builder/code_builder.dart';
import 'package:postgres_models_builder/src/models/database_column.dart';
import 'package:postgres_models_builder/src/models/database_table.dart';
import 'package:postgres_models_builder/src/models/model_type.dart';
import 'package:postgres_models_builder/src/util.dart';

import '../generate_types/types_generator.dart';

class DataClassBuilder {
  final DatabaseTable table;
  final TypesGeneratorConfig config;
  final ModelType modelType;
  late final DartEmitter dartEmitter;

  DataClassBuilder({
    required this.table,
    required this.config,
    required this.modelType,
    bool orderDirectives = true,
    bool useNullSafetySyntax = true,
  }) : dartEmitter = DartEmitter(
         orderDirectives: orderDirectives,
         useNullSafetySyntax: useNullSafetySyntax,
       );

  late final ClassBuilder classBuilder = ClassBuilder();

  bool get hasCollection => table.columns.any((element) => element.isCollection);

  bool get requiresConvertImport => config.generateSerialization;

  bool get requiresUniversalToolsImport => table.columns.any((element) => element.isEnum);

  bool get requiresCollectionImport => hasCollection && config.generateEquality;

  String get className {
    if (modelType == ModelType.row) {
      return table.dartClassName;
    } else {
      return table.dartClassName + modelType.name.toUpperCaseFirst().convertSnakeCaseToCamelCase();
    }
  }

  List<DatabaseColumn> get fields => table.columns;

  String build() {
    // assign the class name
    classBuilder.name = className;

    buildDefaultConstructor();
    buildFields();

    if (config.generateCopyWith) {
      buildCopyWithMethod();
    }
    if (config.generateSerialization) {
      buildSerialization();
    }
    if (config.generateEquality) {
      buildEqualityMethods();
      buildHashCodeGetter();
    }
    if (config.generateToString) {
      buildToStringMethod();
    }

    String source = generateSource();

    for (final column in table.columns) {
      if (column.isKeyId && column.foreignKeyRelation == null) {
        final importStatement =
            "import '../../keys/${table.tableName}_${column.columnKey}.g.dart';";
        if (source.contains(importStatement) == false) {
          source = "$importStatement\n$source";
        }
      }
    }

    if (requiresConvertImport) {
      // add collection import to source
      source = "import '$_dartConvertImportUri';\n$source";
    }
    if (modelType == ModelType.partial) {
      // add collection import to source
      source = "import 'package:postgres_base_models/postgres_base_models.dart';\n$source";
    }
    if (requiresUniversalToolsImport) {
      for (final column in table.columns) {
        if (column.isEnum) {
          final importStatement = "import '../../enums/${column.resolvedUdtType}.g.dart';";
          if (source.contains(importStatement) == false) {
            source = "$importStatement\n$source";
          }
        }
      }
    }

    if (requiresCollectionImport) {
      // add convert import to source
      source = "import '$_collectionImportUri';\n$source";
    }

    for (final column in table.columns) {
      if (column.foreignKeyRelation != null) {
        final importStatement =
            "import '../../keys/${column.foreignKeyRelation!.foreignTableName}_${column.foreignKeyRelation!.foreignColumnName}.g.dart';";
        if (source.contains(importStatement) == false) {
          source = "$importStatement\n$source";
        }
      }
    }

    return source;
  }

  String generateSource() => classBuilder.build().accept(dartEmitter).toString();

  void buildFields() {
    final classFields = <Field>[];
    for (var field in fields) {
      classFields.add(
        Field((b) {
          b
            ..name = field.columnName
            ..modifier = FieldModifier.final$
            // if we pull postgresql column/table comments, we can add them here.
            // ..docs = ListBuilder<String>(field.comment)
            ..type = Reference(field.dartTypeNameFor(modelType));
        }),
      );
    }

    classBuilder.fields.addAll(classFields);
  }

  void buildDefaultConstructor() {
    // first create the constructor parameters
    final namedParameters = <Parameter>[];

    for (final field in fields) {
      namedParameters.add(
        Parameter((b) {
          b
            ..name = field.columnName
            ..named = true
            ..toThis = true
            ..required = !field.isFieldNullableFor(modelType);
        }),
      );
    }

    addTrailingCommaToParameters(namedParameters);

    classBuilder.constructors.add(
      Constructor((b) {
        b
          ..optionalParameters = ListBuilder(namedParameters)
          ..constant = true;
      }),
    );
  }

  void buildCopyWithMethod() {
    // create the parameters
    final parameters = <Parameter>[];
    parameters.addAll(
      fields.map(
        (p) => Parameter((b) {
          b
            ..name = p.columnName
            ..named = true
            ..type = Reference(
              p.dartTypeNameFor(
                modelType == ModelType.partial ? ModelType.partial : ModelType.update,
              ),
            );
        }),
      ),
    );

    addTrailingCommaToParameters(parameters);

    // create the body
    final body = fields
        .map((field) {
          return '${field.columnName}: ${field.columnName} ?? this.${field.columnName}';
        })
        .reduce((value, element) => '$value,$element');

    final copyWithMethod = Method((b) {
      b
        ..returns = refer(className)
        ..name = 'copyWith'
        ..body = Code('return $className($body,);')
        ..optionalParameters = ListBuilder(parameters);
    });

    classBuilder.methods.add(copyWithMethod);
  }

  void buildEqualityMethods() {
    final method = Method((b) {
      b
        ..name = '=='
        ..returns = refer('bool operator')
        ..requiredParameters = ListBuilder([
          Parameter((b) {
            b
              ..name = 'other'
              ..type = refer('Object');
          }),
        ])
        ..annotations = overrideAnnotation()
        ..body = generateEqualityOperatorBody();
    });

    classBuilder.methods.add(method);
  }

  // create the body of the method
  Code generateEqualityOperatorBody() {
    final params = fields
        .map((field) {
          if (field.isCollection) {
            return 'collectionEquals(other.${field.columnName}, ${field.columnName})';
          } else {
            return 'other.${field.columnName} == ${field.columnName}';
          }
        })
        .reduce((prev, next) => '$prev&&$next');

    final collectionEquality = hasCollection
        ? 'final collectionEquals = const DeepCollectionEquality().equals;'
        : '';

    return Code('''
  if (identical(this, other)) return true;
  $collectionEquality

  return other is $className && $params;
  ''');
  }

  void buildHashCodeGetter() {
    final params = fields
        .map((field) => '${field.columnName}.hashCode')
        .reduce((prev, next) => '$prev^$next');
    final method = Method((b) {
      b
        ..name = 'hashCode'
        ..type = MethodType.getter
        ..returns = refer('int')
        ..annotations = overrideAnnotation()
        ..body = Code('return $params;');
    });
    classBuilder.methods.add(method);
  }

  void buildSerialization() {
    if (config.buildFromSerializerForInsertAndUpdate || modelType == ModelType.row) {
      if (modelType != ModelType.partial) {
        buildFromMapConstructor();
        buildFromJsonConstructor();
      }
    }

    buildToMapMethod();
    buildToJsonMethod();
  }

  void buildToMapMethod() {
    final body = fields
        .map((field) {
          return field.toJsonDefinitionFor(modelType);
        })
        .reduce((value, element) => '$value,$element');
    final method = Method((b) {
      b
        // ..annotations.add(CodeExpression(Code('override')))
        ..name = 'toMap'
        ..returns = refer('Map<String, dynamic>')
        ..optionalParameters = ListBuilder([
          if (modelType == ModelType.update || modelType == ModelType.insert)
            Parameter((b) {
              b
                ..name = 'includeNulls'
                ..named = true
                ..defaultTo = Code('false')
                ..type = refer('bool');
            }),
        ])
        ..body = Code('return {$body,};');
    });

    classBuilder.methods.add(method);
  }

  void buildFromMapConstructor() {
    final constructorBody = fields
        .map((p) => p.fromJsonDefinitionFor(modelType))
        .reduce((value, element) => '$value,$element');
    // return Code('return ${clazz.name.name}($body,);');

    final constructor = Constructor((b) {
      b
        ..name = 'fromMap'
        ..factory = true
        ..requiredParameters = ListBuilder<Parameter>([
          Parameter((b) {
            b
              ..name = 'map'
              ..type = refer('Map<String, dynamic>');
          }),
        ])
        ..body = Code('return $className($constructorBody,);');
    });

    classBuilder.constructors.add(constructor);
  }

  void buildFromJsonConstructor() {
    final constructor = Constructor((b) {
      b
        ..name = 'fromJson'
        ..factory = true
        ..requiredParameters = ListBuilder<Parameter>([
          Parameter((b) {
            b
              ..name = 'source'
              ..type = refer('String');
          }),
        ])
        ..lambda = true
        ..body = Code('$className.fromMap(json.decode(source))');
    });
    classBuilder.constructors.add(constructor);
  }

  void buildToJsonMethod() {
    final method = Method((b) {
      b
        ..name = 'toJson'
        ..returns = refer('String')
        ..lambda = true
        ..body = Code('json.encode(toMap())');
    });

    classBuilder.methods.add(method);
  }

  void buildToStringMethod() {
    final params = fields
        .map((p) => '${p.columnName}: \$${p.columnName}')
        .reduce((prev, next) => '$prev, $next');
    final method = Method((b) {
      b
        ..name = 'toString'
        ..returns = refer('String')
        ..annotations = overrideAnnotation()
        ..body = Code("return '$className($params)';");
    });
    classBuilder.methods.add(method);
  }

  // helper method
  ListBuilder<Expression> overrideAnnotation() {
    return ListBuilder(const [CodeExpression(Code('override'))]);
  }

  /// adds a trailing comma if the [params] is not empty
  void addTrailingCommaToParameters(List<Parameter> params) {
    if (params.isNotEmpty) {
      // Since there's no method in the Builders to add a trailing comma,
      // This adds an empty parameter which will add a comma as a trailing one.
      // params.add(Parameter((b) => b.name = ''));
    }
  }
}

const _dartConvertImportUri = "dart:convert";
const _collectionImportUri = "package:collection/collection.dart";
