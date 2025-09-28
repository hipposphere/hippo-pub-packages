import 'package:flutter/widgets.dart';

class HippoAuthSSOProvider {
  final String id;
  final String name;
  final AuthSSOProviderBranding? branding;

  HippoAuthSSOProvider({required this.id, required this.name, this.branding});
}

class AuthSSOProviderBranding {
  final WidgetBuilder logoBuilder;

  AuthSSOProviderBranding({required this.logoBuilder});
}
