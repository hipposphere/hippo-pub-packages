// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:postgres_models_builder/src/models/foreign_key_relation.dart';
import 'package:postgres_models_builder/src/models/model_type.dart';
import 'package:postgres_models_builder/src/util.dart';

enum KeyIdType { int, string }

class DatabaseColumn {
  final String tableName;
  final String columnKey;
  final String udtType;
  final bool isNullable;
  final int ordinalPosition;
  final String? columnDefault;
  final String? identityGeneration;

  ForeignKeyRelation? foreignKeyRelation;

  DatabaseColumn({
    required this.tableName,
    required this.columnKey,
    required this.udtType,
    required this.isNullable,
    required this.ordinalPosition,
    required this.columnDefault,
    required this.identityGeneration,
    required this.foreignKeyRelation,
  });

  String get columnName {
    if (columnKey == 'switch') return 'switch_';
    return columnKey.convertSnakeCaseToCamelCase();
  }

  String dartTypeNameFor(ModelType modelType) {
    final dartType = _dartTypeForModelType(modelType);

    if (modelType == ModelType.partial) {
      return 'PartialValue<$dartType>?';
    }
    return dartType;
  }

  String _dartTypeForModelType(ModelType modelType) {
    if (foreignKeyRelation != null) {
      return foreignKeyRelation!.foreignTableName.convertSnakeCaseToCamelCase().toUpperCaseFirst() +
          foreignKeyRelation!.foreignColumnName.convertSnakeCaseToCamelCase().toUpperCaseFirst() +
          (isFieldNullableFor(modelType) ? '?' : '');
    }
    if (isKeyId) {
      return tableName.convertSnakeCaseToCamelCase().toUpperCaseFirst() +
          columnKey.convertSnakeCaseToCamelCase().toUpperCaseFirst() +
          (isFieldNullableFor(modelType) ? '?' : '');
    }
    if (_dartType == 'dynamic') {
      return 'dynamic';
    }
    return _dartType + (isFieldNullableFor(modelType) ? '?' : '');
  }

  String get _dartType {
    if (isKeyId) {
      return tableName.convertSnakeCaseToCamelCase().toUpperCaseFirst() +
          columnKey.convertSnakeCaseToCamelCase().toUpperCaseFirst();
    }
    return _getDartType(udtType, isEnum);
  }

  String get rawDartType {
    return _getDartType(udtType, isEnum);
  }

  bool get isEnum {
    return _isEnumType(udtType);
  }

  bool get isKeyId {
    return columnKey == 'id' && (udtType == 'uuid' || udtType == 'text' || udtType == 'int8');
  }

  KeyIdType get keyIdType {
    if (isKeyId) {
      if (udtType == 'uuid') {
        return KeyIdType.string;
      } else if (udtType == 'text') {
        return KeyIdType.string;
      } else if (udtType == 'int8') {
        return KeyIdType.int;
      }
    }
    throw Exception('not a key id');
  }

  bool isFieldNullableFor(ModelType modelType) {
    switch (modelType) {
      case ModelType.insert:
        return isNullable ? true : hasDefaultValueOrAutoIncrement;
      case ModelType.update:
        return true;
      case ModelType.row:
        return isNullable;
      case ModelType.partial:
        return isNullable;
    }
  }

  bool get hasDefaultValueOrAutoIncrement {
    return columnDefault != null || identityGeneration != null;
  }

  bool get isCollection => _dartType.startsWith('List');

  String fromJsonDefinitionFor(ModelType modelType) {
    return _getFromFormatter(
      _dartType,
      columnKey,
      columnName,
      isFieldNullableFor(modelType),
      isEnum,
      isCollection,
      isKeyId,
      tableName,
      foreignKeyRelation,
    );
  }

  String toJsonDefinitionFor(ModelType modelType) {
    return _getToFormatter(
      _dartType,
      columnKey,
      columnName,
      isFieldNullableFor(modelType),
      isEnum,
      isCollection,
      isKeyId,
      tableName,
      modelType,
      foreignKeyRelation,
    );
  }
}

String _getDartType(String postgresType, bool isEnum) {
  late final String dartType;
  switch (postgresType) {
    case 'tsvector':
      dartType = 'dynamic';
      break;
    case 'bpchar':
    case 'char':
    case 'varchar':
    case 'text':
    case 'citext':
    case 'uuid':
    case 'bytea':
    case 'inet':
    case 'time':
    case 'timetz':
    case 'interval':
    case 'name':
      dartType = 'String';
      break;
    case 'vector':
      return 'String';
    case 'int2':
    case 'int4':
    case 'int8':
    // Object Identifier Type
    // "The oid type is currently implemented as an unsigned four-byte integer."
    // - for more info, see: https://www.postgresql.org/docs/8.4/datatype-oid.html
    case 'oid':
      dartType = 'int';
      break;
    case 'float4':
    case 'float8':
    case 'numeric':
    case 'money':
      dartType = 'double';
      break;
    case 'bool':
      dartType = 'bool';
      break;
    case 'json':
    case 'jsonb':
      dartType = 'dynamic'; // this can be different types (e.g. List or Map)
      break;
    case 'date':
    case 'timestamp':
    case 'timestamptz':
      dartType = 'DateTime';
      break;
    case '_int2':
    case '_int4':
    case '_int8':
      dartType = 'List<int>';
      break;
    case '_float4':
    case '_float8':
    case '_numeric':
    case '_money':
      dartType = 'List<double>';
      break;
    case '_bool':
      dartType = 'List<bool>';
      break;
    case '_varchar':
    case '_text':
    case '_citext':
    case '_uuid':
    case '_bytea':
      dartType = 'List<String>';
      break;
    case '_json':
    case '_jsonb':
      dartType = 'List<Object>'; // this can be different types (e.g. List<List> or List<Map>)
      break;
    case '_timestamptz':
      dartType = 'List<DateTime>';
      break;
    default:
      return postgresType.convertSnakeCaseToCamelCase().toUpperCaseFirst();
  }
  return dartType;
}

bool _isEnumType(String postgresType) {
  switch (postgresType) {
    case 'tsvector':
      return false;
    case 'vector':
      return false;
    case 'bpchar':
    case 'char':
    case 'varchar':
    case 'text':
    case 'citext':
    case 'uuid':
    case 'bytea':
    case 'inet':
    case 'time':
    case 'timetz':
    case 'interval':
    case 'name':
      return false;
    case 'int2':
    case 'int4':
    case 'int8':
    // Object Identifier Type
    // "The oid type is currently implemented as an unsigned four-byte integer."
    // - for more info, see: https://www.postgresql.org/docs/8.4/datatype-oid.html
    case 'oid':
      return false;

    case 'float4':
    case 'float8':
    case 'numeric':
    case 'money':
      return false;
    case 'bool':
      return false;
    case 'json':
    case 'jsonb':
      return false;
    case 'date':
    case 'timestamp':
    case 'timestamptz':
      return false;
    case '_int2':
    case '_int4':
    case '_int8':
      return false;
    case '_float4':
    case '_float8':
    case '_numeric':
    case '_money':
      return false;
    case '_bool':
      return false;
    case '_varchar':
    case '_text':
    case '_citext':
    case '_uuid':
    case '_bytea':
      return false;
    case '_json':
    case '_jsonb':
      return false;
    case '_timestamptz':
      return false;
    default:
      return true;
  }
}

String _getFromFormatter(
  String dartType,
  String columnKey,
  String columnName,
  bool isNullable,
  bool isEnum,
  bool isCollection,
  bool isKeyId,
  String tableName,
  ForeignKeyRelation? foreignKeyRelation,
) {
  late String assignment;
  String mapKey = "map['$columnKey']";
  if (foreignKeyRelation != null) {
    final objectName =
        foreignKeyRelation.foreignTableName.convertSnakeCaseToCamelCase().toUpperCaseFirst() +
        foreignKeyRelation.foreignColumnName.convertSnakeCaseToCamelCase().toUpperCaseFirst();
    assignment = isNullable
        ? '$mapKey != null ? $objectName($mapKey) : null'
        : '$objectName($mapKey)';
  } else if (isKeyId) {
    final objectName =
        tableName.convertSnakeCaseToCamelCase().toUpperCaseFirst() +
        columnKey.convertSnakeCaseToCamelCase().toUpperCaseFirst();
    assignment = isNullable
        ? '$mapKey != null ? $objectName($mapKey) :null'
        : '$objectName($mapKey)';
  } else if (isEnum) {
    assignment = isNullable
        ? '$mapKey != null ? $dartType.fromJsonString( $mapKey) : null'
        : '$dartType.fromJsonString($mapKey)';
  } else {
    switch (dartType) {
      case 'tsvector':
        assignment = mapKey;
        break;
      case 'vector':
        assignment = mapKey;
        break;
      case 'num':
      case 'dynamic':
      case 'bool':
      case 'Object':
      case 'String':
        assignment = mapKey;
        break;
      case 'int':
        // - int --> map['fieldName']?.toInt()       OR     int.parse(map['fieldName'])
        assignment = isNullable
            ? '$mapKey != null ? ($mapKey is int ? $mapKey : int.parse($mapKey)) : null'
            : '($mapKey is int ? $mapKey : int.parse($mapKey))';
        break;
      case 'double':
        // - double --> map['fieldName']?.double()   OR     double.parse(map['fieldName'])
        // note: dart, especially when used with web, would convert double to integer (1.0 -> 1) so account for it.
        assignment = isNullable
            ? '$mapKey != null ? ($mapKey is double ? $mapKey : ( $mapKey is int ? $mapKey.toDouble() : double.parse($mapKey) )) : null'
            : '($mapKey is double ? $mapKey : ( $mapKey is int ? $mapKey.toDouble() : double.parse($mapKey) ) )';
        break;
      case 'DateTime':
        assignment = isNullable
            ? '$mapKey != null ? DateTime.parse($mapKey).toLocal() : null'
            : 'DateTime.parse($mapKey).toLocal()';
        break;
    }
    if (isCollection) {
      assignment = isNullable
          ? '$mapKey == null ? null : $dartType.from($mapKey)'
          : '$dartType.from($mapKey)';
    }
  }

  return '$columnName: $assignment';
}

String _getToFormatter(
  String dartType,
  String columnKey,
  String columnName,
  bool isNullable,
  bool isEnum,
  bool isCollection,
  bool isKeyId,
  String tableName,
  ModelType modelType,
  ForeignKeyRelation? foreignKeyRelation,
) {
  final key = columnKey;
  String value = columnName;
  if (modelType == ModelType.partial) {
    value = '$value?.value';
  }
  if (foreignKeyRelation != null) {
    value = isNullable ? '$value?.id' : '$value.id';
  } else if (isKeyId) {
    value = isNullable ? '$value?.id' : '$value.id';
  } else if (isEnum) {
    value = isNullable ? '$value?.toJsonString()' : '$value.toJsonString()';
  } else {
    if (dartType == 'DateTime') {
      if (isNullable) {
        value = value + '?';
      }
      // if (useUTC) {
      //   value = value + '.toUtc()';
      // }

      value = value + '.toUtc().toIso8601String()';
    }
  }
  if (modelType == ModelType.insert || modelType == ModelType.update) {
    if (isNullable) {
      return "if($columnName != null || includeNulls) '$key':$value";
    }
  }
  if (modelType == ModelType.partial) {
    return "if($columnName != null) '$key':$value";
  }
  return "'$key':$value";
}
