import 'package:hippo_auth/hippo_auth.dart';

sealed class AuthAppState {
  const AuthAppState();

  static const loading = LoadingAuthAppState();
  static const unauthenticated = UnauthenticatedAuthAppState();
}

class AuthenticatedAuthAppState extends AuthAppState {
  final AuthSession authSession;

  const AuthenticatedAuthAppState({required this.authSession});
}

class LoadingAuthAppState extends AuthAppState {
  const LoadingAuthAppState();
}

class ErrorAuthAppState extends AuthAppState {
  final String message;

  const ErrorAuthAppState(this.message);
}

class UnauthenticatedAuthAppState extends AuthAppState {
  const UnauthenticatedAuthAppState();
}
