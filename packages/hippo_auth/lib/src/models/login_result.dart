sealed class LoginResult {}

class SuccessfulLoginResult implements LoginResult {
  SuccessfulLoginResult();
}

class FailedLoginResult implements LoginResult {
  final LoginError error;

  FailedLoginResult(this.error);
}

sealed class LoginError {}

class InvalidCredentialsLoginError implements LoginError {}

class NetworkLoginError implements LoginError {}

class EmptyEmailOrPasswordLoginError implements LoginError {}

class PasswordTooShortLoginError implements LoginError {
  PasswordTooShortLoginError();
}

class UnknownLoginError implements LoginError {
  final String error;
  final String message;

  UnknownLoginError({required this.error, required this.message});
}

String loginErrorToString(LoginError error) {
  switch (error) {
    case InvalidCredentialsLoginError():
      return 'Deine E-Mail oder dein Passwort ist ungültig.';
    case PasswordTooShortLoginError():
      return 'Dein Passwort ist zu kurz. Es muss mindestens 8 Zeichen lang sein.';
    case NetworkLoginError():
      return 'Netzwerkfehler. Bitte versuche es erneut.';
    case EmptyEmailOrPasswordLoginError():
      return '-Mail und Passwort dürfen nicht leer sein.';
    case UnknownLoginError(error: final errorCode, message: final message):
      return 'Unbekannter Fehler: $message (Code: $errorCode)';
  }
}
