import 'package:flutter/material.dart';
import 'package:hippo_auth/src/auth_bloc.dart';
import 'package:hippo_auth/src/components/login_app/pages/sign_in_email/page.dart';
import 'package:hippo_auth/src/components/login_app/pages/sign_up_email/page.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

class HippoAuthLoginApp extends StatelessWidget {
  const HippoAuthLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(title: 'Anmelden', backAction: null, body: _Body());
  }
}

class _Body extends StatelessWidget {
  final Widget? header;
  // ignore: unused_element_parameter
  const _Body({this.header});

  static const double _maxCardWidth = 500;
  static const double _cardBorderRadius = 24;
  static const double _cardElevation = 8;
  static const double _cardPadding = 48;
  static const EdgeInsets _horizontalMargin = EdgeInsets.symmetric(
    horizontal: 24,
  );
  static const EdgeInsets _separatorMargin = EdgeInsets.symmetric(
    horizontal: 20,
  );

  @override
  Widget build(BuildContext context) {
    final authBloc = HippoAuthBloc.of(context);
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        const SliverGap(60),
        SliverChild(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: _maxCardWidth),
              margin: _horizontalMargin,
              child: Card(
                elevation: _cardElevation,
                shadowColor: HippoColors.primary.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_cardBorderRadius),
                ),
                child: Container(
                  padding: const EdgeInsets.all(_cardPadding),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_cardBorderRadius),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        HippoColors.primaryLightened.withValues(alpha: 0.85),
                        HippoColors.primary.withValues(alpha: 0.01),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (header != null) ...[
                        header!,
                        Container(
                          height: 1,
                          margin: _separatorMargin,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],

                      const Gap(32),
                      for (final provider in authBloc.ssoProviders) ...[
                        Button(
                          onTap: () => authBloc.loginController.signInWithSSO(
                            provider: provider.id,
                            callbackUrlScheme: 'com.hipposphere.hippoauth',
                          ),
                          prefix: const Icon(Icons.person_outline),
                          label: 'Mit UKA-SSO anmelden',
                          type: ButtonType.outline,
                        ),
                        Gap(8),
                      ],
                      Gap(16),
                      Button(
                        onTap: () =>
                            Routing.openPage(context, SignInEmailPage()),
                        prefix: const Icon(Icons.email_outlined),
                        label: 'Mit Email anmelden',
                        type: ButtonType.outline,
                      ),
                      Gap(16),
                      Button(
                        onTap: () =>
                            Routing.openPage(context, SignUpEmailPage()),
                        prefix: const Icon(Icons.add_circle_outline),
                        label: 'Konto erstellen',
                        type: ButtonType.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SliverGap(60),
      ],
    );
  }
}
