import 'package:chopper/chopper.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_auth/src/utils/auth_session_store.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:http/http.dart' as http;

class HippoAuthApiController {
  late Openapi api;

  HippoAuthApiController._({
    required Uri baseUrl,
    required this.sessionStore,
    required this.stateSubject,
    http.Client? httpClient,
  }) {
    api = Openapi.create(
      baseUrl: baseUrl,
      httpClient: httpClient,
      interceptors: [createAuthorizationInterceptor()],
    );
    _initialization = _initController();
  }

  factory HippoAuthApiController({
    required Uri baseUrl,
    required KeyValueStore sessionStore,
    String? sessionKey,
    http.Client? httpClient,
  }) {
    final store = AuthSessionStore(
      keyValueStore: sessionStore,
      sessionKey: sessionKey,
    );
    return HippoAuthApiController._(
      baseUrl: baseUrl,
      sessionStore: store,
      stateSubject: DataSubject.seeded(LoadingAuthState()),
      httpClient: httpClient,
    );
  }

  Future<void> _initController() async {
    try {
      final savedSession = await sessionStore.readSession();
      if (savedSession == null) {
        stateSubject.add(const UnauthenticatedAuthState());
      } else if (savedSession.isExpired) {
        await _tryDeleteStoredSession();
        stateSubject.add(
          const UnauthenticatedAuthState(reason: AuthSessionEndReason.expired),
        );
      } else {
        stateSubject.add(AuthenticatedAuthState(session: savedSession));
      }
    } catch (_) {
      await _tryDeleteStoredSession();
      stateSubject.add(
        const UnauthenticatedAuthState(
          reason: AuthSessionEndReason.invalidStoredSession,
        ),
      );
    }
  }

  final DataSubject<HippoAuthState> stateSubject;
  final AuthSessionStore sessionStore;
  late final Future<void> _initialization;
  Future<_SessionRefreshResult>? _activeRefresh;

  AuthSession? get currentSession => stateSubject.value.session;

  Future<void> setSession(AuthSession session) async {
    await _initialization;
    await sessionStore.saveSession(session);
    stateSubject.add(AuthenticatedAuthState(session: session));
  }

  Future<void> removeSession({AuthSessionEndReason? reason}) async {
    await _initialization;
    await _tryDeleteStoredSession();
    stateSubject.add(UnauthenticatedAuthState(reason: reason));
  }

  Future<AuthSession?> resolveSession() async {
    await _initialization;
    final session = currentSession;
    if (session == null) {
      return null;
    }
    if (session.isExpired) {
      await removeSession(reason: AuthSessionEndReason.expired);
      return null;
    }
    if (!session.canBeRefreshed) {
      return session;
    }

    final result = await _refreshSession();
    if (result == _SessionRefreshResult.rejected) {
      return null;
    }
    final resolvedSession = currentSession;
    if (resolvedSession == null) {
      return null;
    }
    if (resolvedSession.isExpired) {
      await removeSession(reason: AuthSessionEndReason.expired);
      return null;
    }
    return resolvedSession;
  }

  Future<bool> recoverSessionAfterUnauthorized() async {
    await _initialization;
    final session = currentSession;
    if (session == null) {
      return false;
    }
    if (session.isExpired) {
      await removeSession(reason: AuthSessionEndReason.expired);
      return false;
    }
    return await _refreshSession(force: true) ==
        _SessionRefreshResult.refreshed;
  }

  Future<_SessionRefreshResult> _refreshSession({bool force = false}) {
    final activeRefresh = _activeRefresh;
    if (activeRefresh != null) {
      return activeRefresh;
    }

    final session = currentSession;
    if (session == null) {
      return Future.value(_SessionRefreshResult.rejected);
    }
    if (session.isExpired) {
      return removeSession(
        reason: AuthSessionEndReason.expired,
      ).then((_) => _SessionRefreshResult.rejected);
    }
    if (!force && !session.canBeRefreshed) {
      return Future.value(_SessionRefreshResult.refreshed);
    }

    final future = _performSessionRefresh(session);
    _activeRefresh = future;
    return future.whenComplete(() {
      if (identical(_activeRefresh, future)) {
        _activeRefresh = null;
      }
    });
  }

  Future<_SessionRefreshResult> _performSessionRefresh(
    AuthSession oldSession,
  ) async {
    try {
      final response = await api.v1UserRefreshSessionPost();
      final expiresAt = response.body?.expiresAt;
      if (response.isSuccessful && expiresAt != null) {
        if (!expiresAt.isAfter(DateTime.now())) {
          await removeSession(reason: AuthSessionEndReason.serverRejected);
          return _SessionRefreshResult.rejected;
        }
        if (!identical(currentSession, oldSession)) {
          return currentSession == null
              ? _SessionRefreshResult.rejected
              : _SessionRefreshResult.refreshed;
        }
        await setSession(
          AuthSession(
            id: oldSession.id,
            token: oldSession.token,
            expiresAt: expiresAt,
          ),
        );
        return _SessionRefreshResult.refreshed;
      }
      if (response.statusCode == 401) {
        final error = AuthApiError.parse(response.error);
        if (error.message == 'Session is still valid') {
          return _SessionRefreshResult.refreshed;
        }
        await removeSession(reason: AuthSessionEndReason.serverRejected);
        return _SessionRefreshResult.rejected;
      }
      return _SessionRefreshResult.unavailable;
    } catch (_) {
      return _SessionRefreshResult.unavailable;
    }
  }

  Interceptor createAuthorizationInterceptor({
    List<String> excludedPaths = const [],
  }) {
    return HippoAuthorizationTokenRequestInterceptor(
      getSession: () => currentSession,
      excludedPaths: excludedPaths,
      refreshSession: resolveSession,
      resolveSession: resolveSession,
      recoverSessionAfterUnauthorized: recoverSessionAfterUnauthorized,
      onUnauthorized: () =>
          removeSession(reason: AuthSessionEndReason.serverRejected),
    );
  }

  Future<void> _tryDeleteStoredSession() async {
    try {
      await sessionStore.deleteSession();
    } catch (_) {
      // In-memory authentication state must still be clearable when a secure
      // storage implementation is temporarily unavailable.
    }
  }
}

enum _SessionRefreshResult { refreshed, rejected, unavailable }
