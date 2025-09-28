import 'package:flutter/widgets.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_auth/src/auth_login_controller.dart';
import 'package:hippo_utils/hippo_utils.dart';

class SignInEmailBloc extends BlocBase {
  final HippoAuthLoginController loginController;

  SignInEmailBloc({required this.loginController});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final obscurePasswordSubject = DataSubject<bool>.seeded(true);
  final errorSubject = DataSubject<LoginError?>.seeded(null);
  final isRunningSubject = DataSubject<bool>.seeded(false);

  Future<void> signIn() async {
    if (isRunningSubject.value) return;
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorSubject.add(EmptyEmailOrPasswordLoginError());
      return;
    }
    errorSubject.add(null);
    isRunningSubject.add(true);
    try {
      final result = await loginController.signInWithEmail(
        email: email,
        password: password,
      );
      if (result is FailedLoginResult) {
        errorSubject.add(result.error);
      }
    } catch (e) {
      errorSubject.add(
        UnknownLoginError(error: 'UnknownLoginError', message: e.toString()),
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

  static SignInEmailBloc of(BuildContext context) {
    return BlocProvider.of<SignInEmailBloc>(context);
  }
}
