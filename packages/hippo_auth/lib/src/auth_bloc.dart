import 'package:flutter/widgets.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_auth/src/auth_login_controller.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:http/http.dart' as http;

class HippoAuthBloc extends BlocBase {
  final HippoAuthApiController apiController;
  final HippoAuthLoginController loginController;

  final List<HippoAuthSSOProvider> ssoProviders;

  HippoAuthBloc({required this.apiController, this.ssoProviders = const []})
    : loginController = HippoAuthLoginController(apiController: apiController);

  factory HippoAuthBloc.create({
    required Uri baseUrl,
    required KeyValueStore sessionStore,
    String? sessionKey,
    http.Client? httpClient,
  }) {
    return HippoAuthBloc(
      apiController: HippoAuthApiController(
        baseUrl: baseUrl,
        sessionStore: sessionStore,
        sessionKey: sessionKey,
        httpClient: httpClient,
      ),
    );
  }

  @override
  void dispose() {}

  static HippoAuthBloc of(BuildContext context) {
    return BlocProvider.of<HippoAuthBloc>(context);
  }
}
