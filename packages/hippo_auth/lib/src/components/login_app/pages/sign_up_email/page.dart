import 'package:flutter/material.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

class SignUpEmailPage extends StatelessWidget {
  const SignUpEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Neues Konto erstellen',
      body: SignUpEmailPageBody(),
    );
  }
}

class SignUpEmailPageBody extends StatelessWidget {
  const SignUpEmailPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = SignUpEmailBloc.of(context);
    return AutofillGroup(
      child: CustomScrollView(
        slivers: [
          SliverGap(32),
          SliverColumn(
            children: [
              PaddedSectionHeader(text: 'Dein Name'),
              Gap(4),
              StyledTextfield(
                autofocus: true,
                autofillHints: const [AutofillHints.email],
                maxLines: 1,
                controller: bloc.nameController,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: Icon(Icons.person_outline),
                ),
                keyboardType: TextInputType.name,
                hint: 'Gib deinen Namen ein',
              ),
              Gap(16),
              PaddedSectionHeader(text: 'Email'),
              Gap(4),
              StyledTextfield(
                autofocus: true,
                autofillHints: const [AutofillHints.email],
                maxLines: 1,
                controller: bloc.emailController,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
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
                    autofillHints: [
                      AutofillHints.newPassword,
                      AutofillHints.password,
                    ],
                    obscureText: obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    suffix: SimpleTappable(
                      onTap: () {
                        bloc.obscurePasswordSubject.add(!obscurePassword);
                      },
                      tooltip: obscurePassword
                          ? 'Passwort anzeigen'
                          : 'Passwort verbergen',
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
              Gap(16),
              DataSubjectBuilder(
                subject: bloc.isRunningSubject,
                builder: (context, isRunning) {
                  return Button(
                    onTap: isRunning
                        ? null
                        : () {
                            bloc.signUp();
                          },
                    prefix: isRunning
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : Icon(Icons.arrow_right_alt),
                    label: 'Registrieren',
                  );
                },
              ),
            ],
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
