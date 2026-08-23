import 'package:dart_http_core/dart_http_core.dart';

import '../../utils/auth_guard.dart';
import '../shared/route_context.dart';
import 'confirm_mail/route.dart';
import 'get_user/route.dart';
import 'info/route.dart';
import 'logout/route.dart';
import 'refresh_session/route.dart';
import 'request_password_reset/route.dart';
import 'reset_password/route.dart';
import 'sign_in_email/route.dart';
import 'sign_in_sso/route.dart';
import 'sign_up_email/route.dart';

void mountUserRoutes<TServices>(Router<TServices> router, HippoAuthRouteContext context) {
  router.routeGet('/info', GetUserInfoRoute<TServices>(context));
  router.routePost('/confirm-mail', ConfirmMailRoute<TServices>(context));
  router.routePost('/request-password-reset', RequestPasswordResetRoute<TServices>(context));
  router.routePost('/reset-password', ResetPasswordRoute<TServices>(context));
  router.routePost('/sign-in-email', SignInEmailRoute<TServices>(context));
  router.routePost('/sign-up-email', SignUpEmailRoute<TServices>(context));
  router.routePost('/sign-in-sso', SignInSsoRoute<TServices>(context));

  final protectedRouter = router.router(
    '',
    guards: [
      HippoAuthGuard<TServices>(
        auth: context.auth,
        sessionCookieName: context.options.sessionCookieName,
      ),
    ],
  );
  protectedRouter.routeGet('/get_user', GetUserRoute<TServices>(context));
  protectedRouter.routeGet('/logout', LogoutRoute<TServices>(context));
  protectedRouter.routePost('/refresh-session', RefreshSessionRoute<TServices>(context));
}
