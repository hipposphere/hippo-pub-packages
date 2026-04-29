import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../utils/api_error.dart';
import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class SignInEmailRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  SignInEmailRoute(this.context)
    : super(error: const HippoAuthRouteError('SignInEmailFailed', 'Sign in failed.'));

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => signInEmailRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    if (!context.options.emailSignInEnabled) {
      throw const HippoAuthBackendException(
        403,
        'SignInEmailDisabled',
        'Email sign in is disabled.',
      );
    }

    final body = ctx.req.body<SignInEmailBody>();
    final response = await context.auth.api.signInEmail(email: body.email, password: body.password);
    return context.signInSessionPayload(response, ctx.res);
  }
}
