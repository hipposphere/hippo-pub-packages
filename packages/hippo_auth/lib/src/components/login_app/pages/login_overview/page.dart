import 'package:flutter/material.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_utils/hippo_utils.dart';

class LoginOverviewPage extends StatelessWidget {
  final Widget? header;
  const LoginOverviewPage({super.key, this.header});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Anmelden',
      backAction: null,
      body: LoginOverviewPageBody(header: header),
    );
  }
}

class LoginOverviewPageBody extends StatelessWidget {
  final Widget? header;

  const LoginOverviewPageBody({super.key, this.header});

  @override
  Widget build(BuildContext context) {
    final authBloc = HippoAuthBloc.of(context);

    return CustomScrollView(
      slivers: [
        ?header,
        SliverGap(32),
        SliverColumn(
          children: [
            for (final provider in authBloc.ssoProviders) ...[
              HippoAuthSSOLoginButton(
                provider: provider,
                onTap: () {
                  authBloc.loginController.oauth2SignIn(
                    provider: provider.id,
                    callbackUrl: provider.callbackUrl.toString(),
                    callbackUrlScheme: 'https',
                  );
                },
              ),
              Gap(8),
            ],
            Gap(16),
            Button(
              onTap: () {
                Routing.openPage(
                  context,
                  BlocProvider<SignInEmailBloc>(
                    bloc: SignInEmailBloc.of(context),
                    child: SignInEmailPage(),
                  ),
                );
              },
              prefix: const Icon(Icons.email_outlined),
              label: 'Mit Email anmelden',
              type: ButtonType.outline,
            ),
            Gap(16),
            Button(
              onTap: () {
                Routing.openPage(
                  context,
                  BlocProvider<SignUpEmailBloc>(
                    bloc: SignUpEmailBloc.of(context),
                    child: SignUpEmailPage(),
                  ),
                );
              },
              prefix: const Icon(Icons.add_circle_outline),
              label: 'Konto erstellen',
              type: ButtonType.primary,
            ),
          ],
        ),
        SliverGap(32),
      ],
    );
  }
}
