import 'package:chopper/chopper.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_auth/src/utils/auth_session_store.dart';
import 'package:hippo_utils/hippo_utils.dart';

class HippoAuthApiController {
  final Openapi api;

  HippoAuthApiController._({
    required this.api,
    required this.sessionStore,
    required this.sessionSubject,
  }) {
    _initController();
  }

  factory HippoAuthApiController({
    required Uri baseUrl,
    required KeyValueStore sessionStore,
    String? sessionKey,
  }) {
    final api = Openapi.create(baseUrl: baseUrl);
    final store = AuthSessionStore(
      keyValueStore: sessionStore,
      sessionKey: sessionKey,
    );
    return HippoAuthApiController._(
      api: api,
      sessionStore: store,
      sessionSubject: DataSubject.seeded(null),
    );
  }

  Future<void> _initController() async {
    final savedSession = await sessionStore.readSession();
    if (savedSession != null) {
      sessionSubject.add(SelectedValue<AuthSession?>(savedSession));
    } else {
      sessionSubject.add(SelectedValue<AuthSession?>(null));
    }
  }

  final DataSubject<SelectedValue<AuthSession?>?> sessionSubject;
  final AuthSessionStore sessionStore;

  AuthSession? get currentSession => sessionSubject.value?.value;

  Future<void> setSession(AuthSession session) async {
    sessionSubject.add(SelectedValue<AuthSession?>(session));
    await sessionStore.saveSession(session);
  }

  Future<void> removeSession() async {
    sessionSubject.add(SelectedValue<AuthSession?>(null));
    await sessionStore.deleteSession();
  }

  Interceptor createAuthorizationInterceptor({
    List<String> excludedPaths = const [],
  }) {
    return HippoAuthorizationTokenRequestInterceptor(
      getSession: () => currentSession,
      excludedPaths: excludedPaths,
      refreshSession: () async {
        final oldSession = currentSession;
        final refreshToken = oldSession?.token;
        if (oldSession == null || refreshToken == null) {
          return null;
        }
        final response = await api.v1UserRefreshSessionPost();
        final body = response.body;
        if (response.isSuccessful && body != null) {
          final newSession = AuthSession(
            id: oldSession.id,
            token: oldSession.token,
            expiresAt: body.expiresAt!,
          );
          await setSession(newSession);
          return newSession;
        } else {
          return null;
        }
      },
    );
  }
}
