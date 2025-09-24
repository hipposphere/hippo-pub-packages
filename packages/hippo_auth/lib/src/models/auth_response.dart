import 'package:hippo_auth/hippo_auth.dart';

class AuthResponse {
  final AuthUser user;
  final AuthSession session;

  AuthResponse({required this.user, required this.session});
}
