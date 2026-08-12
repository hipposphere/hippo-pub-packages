import 'package:flutter/material.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_auth_ui/src/widgets/auth_builder.dart';

class HippoAuthWrapper extends StatelessWidget {
  final WidgetBuilder loadingBuilder;
  final WidgetBuilder loginBuilder;
  final Widget Function(BuildContext context, AuthSession session) childBuilder;
  const HippoAuthWrapper({
    super.key,
    required this.loadingBuilder,
    required this.loginBuilder,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return HippoAuthBuilder(
      builder: (context, value) {
        return switch (value) {
          LoadingAuthState() || ErrorAuthState() => loadingBuilder(context),
          UnauthenticatedAuthState() => loginBuilder(context),
          AuthenticatedAuthState(:final session) => childBuilder(
            context,
            session,
          ),
        };
      },
    );
  }
}
