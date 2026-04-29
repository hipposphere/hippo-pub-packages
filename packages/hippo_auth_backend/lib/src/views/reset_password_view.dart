part of 'views.dart';

Component buildResetPasswordView({
  required HippoAuthBackendOptions options,
  required String token,
  required String email,
  String routeBasePath = '',
}) {
  final branding = options.branding;
  final appName = branding.appName ?? options.appName;
  final resetEndpoint = _endpointUrl(options.baseUrl, routeBasePath, '/v1/user/reset-password');

  return _authDocument(
    title: 'Reset Password',
    appName: appName,
    branding: branding,
    body: [
      h1([Component.text('Reset Your Password')]),
      p([
        Component.text('Enter a new password to regain access to your account.'),
      ], classes: 'subtitle'),
      form(
        [
          _field(
            labelText: 'Email Address',
            inputId: 'email',
            child: input<String>(
              id: 'email',
              type: InputType.email,
              value: email,
              disabled: true,
              attributes: const {'autocomplete': 'email', 'readonly': ''},
            ),
          ),
          _passwordField(
            labelText: 'New Password',
            inputId: 'password',
            autocomplete: 'new-password',
          ),
          _passwordField(
            labelText: 'Confirm New Password',
            inputId: 'confirm-password',
            autocomplete: 'new-password',
          ),
          button([
            span([Component.text('Reset Password')], id: 'button-text'),
          ], type: ButtonType.submit),
        ],
        id: 'reset-form',
        noValidate: true,
      ),
      p([], id: 'message', classes: 'message hint'),
      script(content: _resetPasswordScript(resetEndpoint, token, email)),
    ],
  );
}

Component _passwordField({
  required String labelText,
  required String inputId,
  required String autocomplete,
}) {
  return _field(
    labelText: labelText,
    inputId: inputId,
    child: div([
      input<String>(
        id: inputId,
        type: InputType.password,
        attributes: {
          'autocomplete': autocomplete,
          'minlength': '8',
          'required': '',
          'placeholder': 'At least 8 characters',
        },
      ),
      button(
        [Component.text('Show')],
        type: ButtonType.button,
        classes: 'toggle',
        attributes: {'data-toggle': inputId, 'aria-label': 'Show password'},
      ),
    ], classes: 'password-wrapper'),
  );
}
