import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_flutter_app_architecture/hippo_flutter_app_architecture.dart';

class AuthAppStateLoader extends AppStateLoader<HippoAuthState> {
  final HippoAuthBloc authBloc;

  AuthAppStateLoader(this.authBloc);

  @override
  HippoAuthState get initialAppState => .loading;

  @override
  Stream<HippoAuthState> loadAppState() {
    return authBloc.apiController.sessionSubject.stream;
  }
}
