import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../utils/api_error.dart';
import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class SignUpEmailRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  SignUpEmailRoute(this.context)
    : super(error: const HippoAuthRouteError('SignUpEmailFailed', 'Sign up failed.'));

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => signUpEmailRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    if (!context.options.emailSignUpEnabled) {
      throw const HippoAuthBackendException(
        403,
        'SignUpEmailDisabled',
        'Email sign up is disabled.',
      );
    }

    final body = ctx.req.body<SignUpEmailBody>();
    final response = await context.auth.api.signUpEmail(
      email: body.email,
      password: body.password,
      name: body.name,
    );
    return context.signUpSessionPayload(response, ctx.res);
  }
}
