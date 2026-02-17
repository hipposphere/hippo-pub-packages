import 'package:postgres_models_builder/src/models/database_enum.dart';

class DatabaseColumnEnum {
  final String schemaName;
  final String tableName;
  final String columnName;
  final String constraintName;
  final DatabaseEnum databaseEnum;

  const DatabaseColumnEnum({
    required this.schemaName,
    required this.tableName,
    required this.columnName,
    required this.constraintName,
    required this.databaseEnum,
  });

  String get columnIdentifier {
    return '$schemaName.$tableName.$columnName';
  }
}
