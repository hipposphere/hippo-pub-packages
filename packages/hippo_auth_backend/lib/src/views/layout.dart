part of 'views.dart';

Component _authDocument({
  required String title,
  required String appName,
  required HippoAuthBackendBranding branding,
  required List<Component> body,
}) {
  return jaspr_server.Document(
    title: title,
    lang: 'en',
    base: null,
    head: [
      Component.element(tag: 'style', children: [RawText(_pageCss(branding))]),
    ],
    body: main_([
      header([
        if (branding.appLogoUrl case final logoUrl?)
          img(src: logoUrl, alt: appName, classes: 'logo'),
        div([
          p([Component.text(appName)], classes: 'brand'),
        ]),
      ]),
      ...body,
      _footer(branding),
    ], classes: 'card'),
  );
}

Component _field({required String labelText, required String inputId, required Component child}) {
  return div([
    label([Component.text(labelText)], htmlFor: inputId),
    child,
  ], classes: 'field');
}

Component _footer(HippoAuthBackendBranding branding) {
  final links = <Component>[
    if (branding.imprintUrl case final href?) a([Component.text('Imprint')], href: href),
    if (branding.privacyUrl case final href?) a([Component.text('Privacy')], href: href),
    if (branding.termsOfServiceUrl case final href?) a([Component.text('Terms')], href: href),
  ];

  return footer([
    if (branding.supportEmail case final email?)
      p([
        Component.text('Need help? '),
        a([Component.text(email)], href: 'mailto:$email'),
      ]),
    if (branding.footerText case final footerText?) p([Component.text(footerText)]),
    if (links.isNotEmpty) nav(links),
  ]);
}
