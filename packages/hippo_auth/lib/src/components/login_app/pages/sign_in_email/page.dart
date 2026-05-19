import 'package:flutter/material.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

class SignInEmailPage extends StatelessWidget {
  const SignInEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(title: 'Mit Email anmelden', body: SignInEmailBody());
  }
}

class SignInEmailBody extends StatelessWidget {
  const SignInEmailBody({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = SignInEmailBloc.of(context);
    return AutofillGroup(
      child: CustomScrollView(
        slivers: [
          SliverGap(32),
          SliverColumn(
            children: [
              PaddedSectionHeader(text: 'Email'),
              Gap(4),
              StyledTextfield(
                autofocus: true,
                autofillHints: const [AutofillHints.email],
                controller: bloc.emailController,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
                hint: 'Gib deine E-Mail-Adresse ein',
              ),
              Gap(16),
              PaddedSectionHeader(text: 'Passwort'),
              Gap(4),
              DataSubjectBuilder(
                subject: bloc.obscurePasswordSubject,
                builder: (context, obscurePassword) {
                  return StyledTextfield(
                    controller: bloc.passwordController,
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: Icon(Icons.key),
                    ),
                    hint: 'Gib dein Passwort ein',
                    maxLines: 1,
                    autofillHints: [AutofillHints.password],
                    obscureText: obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    onSubmit: (_) {
                      if (bloc.isRunningSubject.value) return;
                      bloc.signIn();
                    },
                    suffix: SimpleTappable(
                      onTap: () {
                        bloc.obscurePasswordSubject.add(!obscurePassword);
                      },
                      tooltip: obscurePassword
                          ? 'Passwort anzeigen'
                          : 'Passwort ausblenden',
                      margin: EdgeInsets.all(8),
                      child: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  );
                },
              ),
              Gap(32),
              DataSubjectBuilder(
                subject: bloc.isRunningSubject,
                builder: (context, isRunning) {
                  return Button(
                    onTap: isRunning
                        ? null
                        : () {
                            bloc.signIn();
                          },
                    prefix: isRunning
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : Icon(Icons.arrow_right_alt),
                    label: 'Anmelden',
                  );
                },
              ),
            ],
          ),

          SliverGap(16),
          SliverChild(
            crossAxisAlignment: CrossAxisAlignment.center,
            child: TappableChip(
              leading: Icon(Icons.lock_reset),
              label: Text('Password vergessen?'),
              onTap: () {
                ForgotPasswordModal(
                  loginController: bloc.loginController,
                  initialText: bloc.emailController.text,
                ).open(context);
              },
            ),
          ),
          SliverGap(16),
          DataSubjectBuilder(
            subject: bloc.errorSubject,
            builder: (context, error) {
              if (error == null) return SliverToBoxAdapter();
              return SliverChild(
                child: Alert(
                  title: 'Ein Fehler ist aufgetreten',
                  subtitle: loginErrorToString(error),
                  style: AlertStyle.destructive,
                ),
              );
            },
          ),
          SliverGap(16),
        ],
      ),
    );
  }
}
