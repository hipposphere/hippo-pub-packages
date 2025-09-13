import 'package:postgres_models_builder/src/util.dart';

class DatabaseEnum {
  /// The postgres enum type name
  final String enumType;
  final List<String> values;

  const DatabaseEnum({required this.enumType, required this.values});

  /// The Dart Enum Name
  String get enumName {
    return enumType.convertSnakeCaseToCamelCase().toUpperCaseFirst();
  }

  String getDartSafeEnumValue(String value) {
    return safeEnumValue(value);
  }
}

String safeEnumValue(String value) {
  switch (value) {
    case 'new':
      return '_new';
    case 'default':
      return '_default';
    case 'class':
      return '_class';
    case 'operator':
      return '_operator';
    case 'throw':
      return '_throw';
  }

  return value;
}
