import 'package:flutter/widgets.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_auth/src/auth_login_controller.dart';
import 'package:hippo_utils/hippo_utils.dart';

class SignUpEmailBloc extends BlocBase {
  final HippoAuthLoginController loginController;

  SignUpEmailBloc({required this.loginController});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final obscurePasswordSubject = DataSubject<bool>.seeded(true);
  final errorSubject = DataSubject<LoginError?>.seeded(null);
  final isRunningSubject = DataSubject<bool>.seeded(false);

  Future<void> signUp() async {
    if (isRunningSubject.value) return;

    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      errorSubject.add(EmptyEmailOrPasswordLoginError());
      return;
    }

    errorSubject.add(null);
    isRunningSubject.add(true);
    try {
      final result = await loginController.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      if (result is FailedLoginResult) {
        errorSubject.add(result.error);
      }
    } catch (e) {
      errorSubject.add(
        UnknownLoginError(
          error: e.toString(),
          message: 'An unknown error occurred.',
        ),
      );
    } finally {
      isRunningSubject.add(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    obscurePasswordSubject.close();
    errorSubject.close();
    isRunningSubject.close();
  }

  static SignUpEmailBloc of(BuildContext context) {
    return BlocProvider.of<SignUpEmailBloc>(context);
  }
}
