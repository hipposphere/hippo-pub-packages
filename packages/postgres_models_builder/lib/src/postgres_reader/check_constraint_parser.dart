List<String>? parseEnumValuesFromCheckConstraint(String constraintDefinition) {
  final normalized = constraintDefinition.toLowerCase();
  final looksLikeInList = RegExp(r'\bin\s*\(').hasMatch(normalized);
  final looksLikeAnyArray = RegExp(r'=\s*any\s*\(\s*array\s*\[').hasMatch(normalized);
  final looksLikeNotInList = RegExp(r'\bnot\s+in\s*\(').hasMatch(normalized);

  if ((!looksLikeInList && !looksLikeAnyArray) || looksLikeNotInList) {
    return null;
  }

  final valueRegex = RegExp(r"'((?:[^']|'')*)'");
  final parsedValues = <String>[];
  final seenValues = <String>{};

  for (final match in valueRegex.allMatches(constraintDefinition)) {
    final group = match.group(1);
    if (group == null) {
      continue;
    }
    final value = group.replaceAll("''", "'");
    if (seenValues.add(value)) {
      parsedValues.add(value);
    }
  }

  if (parsedValues.length < 2) {
    return null;
  }

  return parsedValues;
}
