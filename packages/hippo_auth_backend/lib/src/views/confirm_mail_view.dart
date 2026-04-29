part of 'views.dart';

Component buildConfirmMailView({
  required HippoAuthBackendOptions options,
  required String token,
  required String email,
  String routeBasePath = '',
}) {
  final branding = options.branding;
  final appName = branding.appName ?? options.appName;
  final confirmEndpoint = _endpointUrl(options.baseUrl, routeBasePath, '/v1/user/confirm-mail');

  return _authDocument(
    title: 'Confirm Email',
    appName: appName,
    branding: branding,
    body: [
      h1([Component.text('Confirm Your Email')]),
      p([
        Component.text('Verify your email address to complete your registration.'),
      ], classes: 'subtitle'),
      div([
        p(
          [span([], classes: 'spinner'), Component.text('Confirming your email...')],
          id: 'message',
          classes: 'message hint',
        ),
      ], id: 'content-container'),
      script(content: _confirmMailScript(confirmEndpoint, token, email)),
    ],
  );
}
