import 'package:flutter/material.dart';
import 'package:hippo_auth/src/auth_login_controller.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

enum _ForgotPasswordModalState { enterEmail, loading, result }

class ForgotPasswordModal {
  final HippoAuthLoginController loginController;
  final TextEditingController textEditingController;

  final _stateSubject = DataSubject<_ForgotPasswordModalState>.seeded(
    _ForgotPasswordModalState.enterEmail,
  );

  ForgotPasswordModal({required this.loginController, String initialText = ''})
    : textEditingController = TextEditingController(text: initialText);

  InfoModal _buildModal() {
    return InfoModal(
      title: 'Forgot Password',
      child: DataSubjectBuilder(
        subject: _stateSubject,
        builder: (context, state) {
          return switch (state) {
            _ForgotPasswordModalState.enterEmail => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledTextfield(
                  controller: textEditingController,
                  keyboardType: TextInputType.emailAddress,
                  maxLines: 1,
                  autofillHints: const [AutofillHints.email],
                  autofocus: true,
                  label: Text('Email-Adresse'),
                ),
                Gap(16),
                Button(
                  onTap: () {
                    _sendRequest(context);
                  },
                  label: 'Senden',
                ),
              ],
            ),
            _ForgotPasswordModalState.loading => Center(
              child: CircularProgressIndicator.adaptive(),
            ),
            _ForgotPasswordModalState.result => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Button(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  label: 'Fertig',
                ),
              ],
            ),
          };
        },
      ),
    );
  }

  Future<void> _sendRequest(BuildContext context) async {
    _stateSubject.add(_ForgotPasswordModalState.loading);
    await loginController.requestPasswordReset(textEditingController.text);
    _stateSubject.add(_ForgotPasswordModalState.result);
  }

  Future<void> open(BuildContext context) async {
    final modal = _buildModal();
    await modal.open(context);
  }
}
