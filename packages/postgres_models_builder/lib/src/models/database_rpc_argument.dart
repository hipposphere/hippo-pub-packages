import 'package:postgres_models_builder/src/models/database_enum.dart';
import 'package:postgres_models_builder/src/util.dart';

class DatabaseRpcArgument {
  final String argumentName;
  final String udtType;

  // if this is an enum, then this will be set
  final DatabaseEnum? enumType;

  const DatabaseRpcArgument({required this.argumentName, required this.udtType, this.enumType});

  String get dartArgumentName => argumentName.convertSnakeCaseToCamelCase();

  String get dartType => _getDartType(udtType);

  String _getDartType(String postgresType) {
    if (enumType != null) {
      return enumType!.enumName;
    }
    late final String dartType;
    switch (postgresType) {
      case 'text[]':
      case 'uuid[]':
        dartType = 'List<String>';
        break;
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
      case 'boolean':
        dartType = 'bool';
        break;
      case 'json':
      case 'jsonb':
        dartType = 'dynamic'; // this can be different types (e.g. List or Map)
        break;

      default:
        return 'dynamic';
    }
    return dartType;
  }

  String getToFormatter() {
    if (enumType != null) {
      return '$dartArgumentName.toJsonString()';
    }
    return dartArgumentName;
  }
}
