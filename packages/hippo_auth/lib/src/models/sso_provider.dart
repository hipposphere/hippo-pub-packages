import 'package:flutter/widgets.dart';

class HippoAuthSSOProvider {
  final String id;
  final String name;
  final Uri callbackUrl;
  final AuthSSOProviderBranding? branding;

  HippoAuthSSOProvider({
    required this.id,
    required this.name,
    required this.callbackUrl,
    this.branding,
  });
}

class AuthSSOProviderBranding {
  final WidgetBuilder logoBuilder;

  AuthSSOProviderBranding({required this.logoBuilder});
}
