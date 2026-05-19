import 'package:flutter/material.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_auth/src/components/login_app/pages/login_overview/page.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

class HippoAuthLoginFlow extends StatelessWidget {
  final Widget? header;
  const HippoAuthLoginFlow({super.key, this.header});

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
      child: LoginOverviewPage(header: header),
    );
  }
}

class HippoAuthLoginApp extends StatelessWidget {
  final Widget? header;
  const HippoAuthLoginApp({super.key, this.header});

  @override
  Widget build(BuildContext context) {
    return App(
      brightness: Brightness.light,
      home: HippoAuthLoginFlow(header: header),
    );
  }
}
