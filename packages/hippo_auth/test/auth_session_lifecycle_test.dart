import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('redacts bearer tokens from diagnostics', () {
    final session = _session(
      expiresAt: DateTime.now().add(const Duration(days: 100)),
    );

    expect(session.toString(), isNot(contains(session.token)));
    expect(session.toString(), contains('[redacted]'));
  });

  test(
    'restoring an expired session clears it with an explicit reason',
    () async {
      final store = MockKeyValueStore();
      await store.setString(
        'auth_session',
        _session(
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ).encode(),
      );
      final controller = HippoAuthApiController(
        baseUrl: Uri.parse('https://example.test'),
        sessionStore: store,
      );

      final state = await controller.stateSubject.stream.firstWhere(
        (state) => state is! LoadingAuthState,
      );

      expect(
        state,
        isA<UnauthenticatedAuthState>().having(
          (state) => state.reason,
          'reason',
          AuthSessionEndReason.expired,
        ),
      );
      expect(await store.containsKey('auth_session'), isFalse);
    },
  );

  test('coalesces concurrent proactive session renewals', () async {
    final responseCompleter = Completer<http.Response>();
    var refreshCount = 0;
    final controller = await _controller(
      MockClient((request) async {
        refreshCount += 1;
        expect(request.url.path, '/v1/user/refresh-session');
        expect(request.headers['authorization'], 'Bearer test-token');
        return responseCompleter.future;
      }),
    );
    await controller.setSession(
      _session(expiresAt: DateTime.now().add(const Duration(days: 7))),
    );

    final first = controller.resolveSession();
    final second = controller.resolveSession();
    responseCompleter.complete(
      _jsonResponse(200, {
        'expires_at': DateTime.now()
            .add(const Duration(days: 90))
            .toUtc()
            .toIso8601String(),
      }),
    );

    final sessions = await Future.wait([first, second]);
    expect(refreshCount, 1);
    expect(sessions, everyElement(isNotNull));
    expect(sessions.first!.expiresAt, controller.currentSession!.expiresAt);
  });

  test('server rejection clears the session and reports the reason', () async {
    final controller = await _controller(
      MockClient(
        (_) async => _jsonResponse(401, {
          'error': {
            'code': 'RefreshSessionInvalidRequest',
            'message': 'Session not found.',
          },
        }),
      ),
    );
    await controller.setSession(
      _session(expiresAt: DateTime.now().add(const Duration(days: 7))),
    );

    expect(await controller.resolveSession(), isNull);
    expect(
      controller.stateSubject.value,
      isA<UnauthenticatedAuthState>().having(
        (state) => state.reason,
        'reason',
        AuthSessionEndReason.serverRejected,
      ),
    );
  });

  test('transient renewal failure keeps a locally valid session', () async {
    final controller = await _controller(
      MockClient((_) async => _jsonResponse(503, {'error': 'Unavailable'})),
    );
    final session = _session(
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
    await controller.setSession(session);

    expect(await controller.resolveSession(), same(session));
    expect(controller.stateSubject.value, isA<AuthenticatedAuthState>());
  });

  test(
    'revalidates and retries a protected request after bearer rejection',
    () async {
      var userRequestCount = 0;
      var refreshCount = 0;
      final controller = await _controller(
        MockClient((request) async {
          switch (request.url.path) {
            case '/v1/user/get_user':
              userRequestCount += 1;
              if (userRequestCount == 1) {
                return _jsonResponse(
                  401,
                  {
                    'error': {
                      'code': 'Unauthorized',
                      'message': 'Unauthorized.',
                    },
                  },
                  headers: {'www-authenticate': 'Bearer error="invalid_token"'},
                );
              }
              final now = DateTime.now().toUtc().toIso8601String();
              return _jsonResponse(200, {
                'user': {
                  'id': 'user-id',
                  'email': 'user@example.test',
                  'emailVerified': true,
                  'name': 'Test User',
                  'createdAt': now,
                  'updatedAt': now,
                },
              });
            case '/v1/user/refresh-session':
              refreshCount += 1;
              return _jsonResponse(200, {
                'expires_at': DateTime.now()
                    .add(const Duration(days: 90))
                    .toUtc()
                    .toIso8601String(),
              });
            default:
              fail('Unexpected request path: ${request.url.path}');
          }
        }),
      );
      await controller.setSession(
        _session(expiresAt: DateTime.now().add(const Duration(days: 100))),
      );

      final response = await controller.api.v1UserGetUserGet();

      expect(response.isSuccessful, isTrue);
      expect(response.body?.user.name, 'Test User');
      expect(userRequestCount, 2);
      expect(refreshCount, 1);
    },
  );

  test('sign-out clears local state when the server is unavailable', () async {
    final store = MockKeyValueStore();
    final controller = HippoAuthApiController(
      baseUrl: Uri.parse('https://example.test'),
      sessionStore: store,
      httpClient: MockClient(
        (_) async => _jsonResponse(503, {'error': 'Unavailable'}),
      ),
    );
    await controller.stateSubject.stream.firstWhere(
      (state) => state is! LoadingAuthState,
    );
    await controller.setSession(
      _session(expiresAt: DateTime.now().add(const Duration(days: 100))),
    );

    await HippoAuthBloc(apiController: controller).loginController.signOut();

    expect(
      controller.stateSubject.value,
      isA<UnauthenticatedAuthState>().having(
        (state) => state.reason,
        'reason',
        AuthSessionEndReason.signedOut,
      ),
    );
    expect(await store.containsKey('auth_session'), isFalse);
  });
}

Future<HippoAuthApiController> _controller(http.Client client) async {
  final controller = HippoAuthApiController(
    baseUrl: Uri.parse('https://example.test'),
    sessionStore: MockKeyValueStore(),
    httpClient: client,
  );
  await controller.stateSubject.stream.firstWhere(
    (state) => state is! LoadingAuthState,
  );
  return controller;
}

AuthSession _session({required DateTime expiresAt}) {
  return AuthSession(
    id: 'session-id',
    token: 'test-token',
    expiresAt: expiresAt,
  );
}

http.Response _jsonResponse(
  int status,
  Object body, {
  Map<String, String> headers = const {},
}) {
  return http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json', ...headers},
  );
}
