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
