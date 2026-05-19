import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_flutter_app_architecture/hippo_flutter_app_architecture.dart';

class AuthAppStateLoader extends AppStateLoader<AuthAppState> {
  final HippoAuthBloc authBloc;

  AuthAppStateLoader(this.authBloc);

  @override
  AuthAppState get initialAppState => .loading;

  @override
  Stream<AuthAppState> loadAppState() {
    return authBloc.apiController.sessionSubject.stream.map((session) {
      if (session == null) return .loading;
      final sessionValue = session.value;
      if (sessionValue == null) return .unauthenticated;
      return AuthenticatedAuthAppState(authSession: sessionValue);
    });
  }
}
