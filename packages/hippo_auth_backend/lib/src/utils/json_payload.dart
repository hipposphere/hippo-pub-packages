Map<String, Object?> readJsonObject(Object? value, String label) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return {for (final entry in value.entries) '${entry.key}': entry.value};
  }
  throw FormatException('Expected $label to be a JSON object.');
}

String? readOptionalString(Map<String, Object?> body, String key) {
  final value = body[key];
  if (value == null) {
    return null;
  }
  return value.toString();
}

String readRequiredString(Map<String, Object?> body, String key) {
  final value = readOptionalString(body, key);
  if (value == null || value.isEmpty) {
    throw FormatException('Missing required field "$key".');
  }
  return value;
}
