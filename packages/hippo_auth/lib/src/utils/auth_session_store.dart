import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_utils/hippo_utils.dart';

const _defaultAuthSessionKey = 'auth_session';

class AuthSessionStore {
  final KeyValueStore keyValueStore;
  final String sessionKey;

  AuthSessionStore({required this.keyValueStore, String? sessionKey})
    : sessionKey = sessionKey ?? _defaultAuthSessionKey;

  Future<AuthSession?> readSession() async {
    final sessionString = await keyValueStore.getString(sessionKey);
    if (sessionString == null) {
      return null;
    }
    final session = AuthSession.decode(sessionString);

    if (session.isExpired) {
      return null;
    }
    return session;
  }

  Future<void> saveSession(AuthSession session) async {
    final sessionString = session.encode();
    await keyValueStore.setString(sessionKey, sessionString);
  }

  Future<void> deleteSession() async {
    await keyValueStore.removeValue(sessionKey);
  }
}
