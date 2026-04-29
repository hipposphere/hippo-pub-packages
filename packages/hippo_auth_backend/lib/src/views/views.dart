import 'dart:convert';

import 'package:dart_edge_core/dart_edge_core.dart';
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
  router.getJaspr(
    '/views/reset-password',
    options: RouteOptions(
      summary: 'Render the hosted reset-password page.',
      success: ResponseSpec.html(),
    ),
    handler: (ctx) {
      return buildResetPasswordView(
        options: options,
        token: ctx.req.queryParam('token') ?? '',
        email: ctx.req.queryParam('email') ?? '',
        routeBasePath: routeBasePath,
      );
    },
  );

  router.getJaspr(
    '/views/confirm-mail',
    options: RouteOptions(
      summary: 'Render the hosted email-confirmation page.',
      success: ResponseSpec.html(),
    ),
    handler: (ctx) {
      return buildConfirmMailView(
        options: options,
        token: ctx.req.queryParam('token') ?? '',
        email: ctx.req.queryParam('email') ?? '',
        routeBasePath: routeBasePath,
      );
    },
  );
}
