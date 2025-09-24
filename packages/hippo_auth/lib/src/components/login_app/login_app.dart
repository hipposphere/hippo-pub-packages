import 'package:flutter/material.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_auth/src/components/login_app/pages/login_overview/page.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

class HippoAuthLoginApp extends StatelessWidget {
  const HippoAuthLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    final hippoAuthBloc = HippoAuthBloc.of(context);
    return MultiBlocProvider(
      blocDefiners: [
        BlocDefiner<SignInEmailBloc>(
          bloc: SignInEmailBloc(loginController: hippoAuthBloc.loginController),
        ),
        BlocDefiner<SignUpEmailBloc>(
          bloc: SignUpEmailBloc(loginController: hippoAuthBloc.loginController),
        ),
      ],
      child: App(brightness: Brightness.light, home: LoginOverviewPage()),
    );
  }
}
