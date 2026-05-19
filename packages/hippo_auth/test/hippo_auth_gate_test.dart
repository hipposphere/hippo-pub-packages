import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

void main() {
  testWidgets('renders loading state', (tester) async {
    final authBloc = await _createAuthBloc(tester);
    authBloc.apiController.stateSubject.add(const LoadingAuthState());

    await tester.pumpWidget(_TestAuthGate(authBloc: authBloc));

    expect(find.text('loading'), findsOneWidget);
  });

  testWidgets('renders authenticated data with session', (tester) async {
    final authBloc = await _createAuthBloc(tester);
    final session = _createSession(id: 'session-1');
    authBloc.apiController.stateSubject.add(
      AuthenticatedAuthState(session: session),
    );

    await tester.pumpWidget(
      _TestAuthGate(
        authBloc: authBloc,
        createAuthenticated: (session) => 'core:${session.id}',
      ),
    );
    await tester.pump();

    expect(find.text('authenticated:core:session-1:session-1'), findsOneWidget);
  });

  testWidgets('renders unauthenticated data', (tester) async {
    final authBloc = await _createAuthBloc(tester);
    authBloc.apiController.stateSubject.add(const UnauthenticatedAuthState());

    await tester.pumpWidget(
      _TestAuthGate(
        authBloc: authBloc,
        createUnauthenticated: () => 'login-core',
      ),
    );
    await tester.pump();

    expect(find.text('unauthenticated:login-core'), findsOneWidget);
  });

  testWidgets('renders error builder for error state', (tester) async {
    final authBloc = await _createAuthBloc(tester);
    authBloc.apiController.stateSubject.add(const ErrorAuthState('boom'));

    await tester.pumpWidget(
      _TestAuthGate(
        authBloc: authBloc,
        errorBuilder: (context, state) => Text('error:${state.message}'),
      ),
    );

    expect(find.text('error:boom'), findsOneWidget);
  });

  testWidgets('falls back to loading for error state without error builder', (
    tester,
  ) async {
    final authBloc = await _createAuthBloc(tester);
    authBloc.apiController.stateSubject.add(const ErrorAuthState('boom'));

    await tester.pumpWidget(_TestAuthGate(authBloc: authBloc));

    expect(find.text('loading'), findsOneWidget);
  });

  testWidgets(
    'does not let stale authenticated data overwrite unauthenticated state',
    (tester) async {
      final authBloc = await _createAuthBloc(tester);
      final authenticatedCompleter = Completer<String>();
      authBloc.apiController.stateSubject.add(
        AuthenticatedAuthState(session: _createSession(id: 'session-1')),
      );

      await tester.pumpWidget(
        _TestAuthGate(
          authBloc: authBloc,
          createAuthenticated: (_) => authenticatedCompleter.future,
          createUnauthenticated: () => 'login-core',
        ),
      );
      await tester.pump();

      authBloc.apiController.stateSubject.add(const UnauthenticatedAuthState());
      await tester.pump();
      await tester.pump();

      expect(find.text('unauthenticated:login-core'), findsOneWidget);

      authenticatedCompleter.complete('late-core');
      await tester.pump();

      expect(find.text('authenticated:late-core:session-1'), findsNothing);
      expect(find.text('unauthenticated:login-core'), findsOneWidget);
    },
  );
}

Future<HippoAuthBloc> _createAuthBloc(WidgetTester tester) async {
  final authBloc = HippoAuthBloc.create(
    baseUrl: Uri.parse('https://example.com/auth'),
    sessionStore: MockKeyValueStore(),
  );
  await tester.pump();
  addTearDown(authBloc.apiController.stateSubject.close);
  return authBloc;
}

AuthSession _createSession({required String id}) {
  return AuthSession(id: id, token: 'token-$id', expiresAt: DateTime(2099));
}

class _TestAuthGate extends StatelessWidget {
  const _TestAuthGate({
    required this.authBloc,
    this.createAuthenticated,
    this.createUnauthenticated,
    this.errorBuilder,
  });

  final HippoAuthBloc authBloc;
  final FutureOr<String> Function(AuthSession session)? createAuthenticated;
  final FutureOr<String> Function()? createUnauthenticated;
  final Widget Function(BuildContext context, ErrorAuthState state)?
  errorBuilder;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: HippoAuthGate<String, String>(
        authBloc: authBloc,
        createAuthenticated:
            createAuthenticated ?? (session) => 'core:${session.id}',
        createUnauthenticated: createUnauthenticated ?? () => 'login-core',
        loadingBuilder: (_) => const Text('loading'),
        errorBuilder: errorBuilder,
        authenticatedBuilder: (_, data, session) {
          return Text('authenticated:$data:${session.id}');
        },
        unauthenticatedBuilder: (_, data) {
          return Text('unauthenticated:$data');
        },
      ),
    );
  }
}
