import 'dart:convert';

class AuthSession {
  final String id;
  final String token;
  final DateTime expiresAt;

  AuthSession({required this.id, required this.token, required this.expiresAt});

  factory AuthSession.decode(String sessionString) {
    final map = jsonDecode(sessionString);
    return AuthSession.fromMap(map);
  }

  factory AuthSession.fromMap(Map<String, dynamic> map) {
    return AuthSession(
      id: map['id'],
      token: map['token'],
      expiresAt: DateTime.parse(map['expires_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  String encode() {
    return jsonEncode(toMap());
  }

  bool get isExpired {
    return isExpiredAt(DateTime.now());
  }

  bool get canBeRefreshed {
    return canBeRefreshedAt(DateTime.now());
  }

  bool isExpiredAt(DateTime now) {
    return !expiresAt.isAfter(now);
  }

  bool canBeRefreshedAt(DateTime now) {
    return !isExpiredAt(now) &&
        expiresAt.isBefore(now.add(const Duration(days: 89)));
  }

  @override
  String toString() {
    return 'AuthSession(id: $id, token: [redacted], expiresAt: $expiresAt)';
  }
}
