import 'dart:convert';

import 'package:dart_http_core/dart_http_core.dart';
import 'package:dart_edge_jaspr/dart_edge_jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart' show Component;
import 'package:jaspr/server.dart' as jaspr_server;

import '../options.dart';

part 'confirm_mail_view.dart';
part 'layout.dart';
part 'reset_password_view.dart';
part 'scripts.dart';
part 'styles.dart';
part 'urls.dart';

void mountHippoAuthViews<TServices>(
  Router<TServices> router,
  HippoAuthBackendOptions options, {
  String routeBasePath = '',
}) {
  router.get<RawResponse>(
    '/views/reset-password',
    options: RouteOptions(
      summary: 'Render the hosted reset-password page.',
      success: ResponseSpec.html(),
    ),
    handler: (ctx) async {
      return _renderHtml(
        ctx,
        buildResetPasswordView(
          options: options,
          token: ctx.req.queryParam('token') ?? '',
          email: ctx.req.queryParam('email') ?? '',
          routeBasePath: routeBasePath,
        ),
      );
    },
  );

  router.get<RawResponse>(
    '/views/confirm-mail',
    options: RouteOptions(
      summary: 'Render the hosted email-confirmation page.',
      success: ResponseSpec.html(),
    ),
    handler: (ctx) async {
      return _renderHtml(
        ctx,
        buildConfirmMailView(
          options: options,
          token: ctx.req.queryParam('token') ?? '',
          email: ctx.req.queryParam('email') ?? '',
          routeBasePath: routeBasePath,
        ),
      );
    },
  );
}

Future<RawResponse> _renderHtml<TServices>(
  RequestContext<TServices> ctx,
  Component component,
) async {
  final html = await JasprRenderer.renderString(component);
  return ctx.res.html(html);
}
