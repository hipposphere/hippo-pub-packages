import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';

AuthUserRow hippobaseAuthUser(DartEdgeAuthUser user) {
  final name = user.name;
  final email = user.email;
  if (name == null || email == null) {
    throw StateError('Better Auth returned a user without a name or email.');
  }

  return AuthUserRow(
    id: AuthUserId(user.id),
    name: name,
    email: email,
    emailVerified: user.emailVerified,
    image: user.image,
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
    role: user.role,
    banned: user.banned,
    banReason: user.banReason,
    banExpires: user.banExpires,
    phoneNumber: null,
    phoneNumberVerified: null,
  );
}
