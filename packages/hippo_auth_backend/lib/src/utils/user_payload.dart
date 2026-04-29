import 'package:dart_edge_auth/dart_edge_auth.dart';

Map<String, Object?> authUserFromJson(Map<String, Object?> user) {
  return {
    'id': user['id'],
    'email': user['email'],
    'emailVerified': user['emailVerified'] ?? user['email_verified'] ?? false,
    'name': user['name'] ?? '',
    'image': user['image'],
    if (user.containsKey('role')) 'role': user['role'],
    'createdAt': _dateTimeString(user['createdAt'] ?? user['created_at']),
    'updatedAt': _dateTimeString(user['updatedAt'] ?? user['updated_at']),
  };
}

Map<String, Object?> authUserFromUsersRow(DartEdgeAuthUser user) {
  return user.toJson();
}

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

String _dateTimeString(Object? value) {
  if (value case final DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }
  if (value case final String text when text.isNotEmpty) {
    return DateTime.tryParse(text)?.toUtc().toIso8601String() ?? text;
  }
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toIso8601String();
}
