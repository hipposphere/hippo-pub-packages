import 'package:hippo_auth/hippo_auth.dart';

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
  const UnauthenticatedAuthState();

  @override
  AuthSession? get session => null;
}
