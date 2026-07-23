import 'package:hippo_auth/hippo_auth.dart';

/// Explains why an authenticated session transitioned back to signed out.
enum AuthSessionEndReason {
  signedOut,
  expired,
  serverRejected,
  invalidStoredSession,
}

sealed class HippoAuthState {
  const HippoAuthState();

  static const loading = LoadingAuthState();
  static const unauthenticated = UnauthenticatedAuthState();

  AuthSession? get session;
}

class AuthenticatedAuthState extends HippoAuthState {
  @override
  final AuthSession session;

  const AuthenticatedAuthState({required this.session});
}

class LoadingAuthState extends HippoAuthState {
  const LoadingAuthState();

  @override
  AuthSession? get session => null;
}

class ErrorAuthState extends HippoAuthState {
  final String message;

  const ErrorAuthState(this.message);

  @override
  AuthSession? get session => null;
}

class UnauthenticatedAuthState extends HippoAuthState {
  /// Null for a normal initial state where no session has been established.
  final AuthSessionEndReason? reason;

  const UnauthenticatedAuthState({this.reason});

  @override
  AuthSession? get session => null;
}
