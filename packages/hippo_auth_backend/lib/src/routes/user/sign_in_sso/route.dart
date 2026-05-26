import 'package:dart_edge_core/dart_edge_core.dart';

import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class SignInSsoRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  SignInSsoRoute(this.context)
    : super(
        error: const HippoAuthRouteError(
          'SSOLoginInitiationFailed',
          'Failed to initiate SSO login.',
        ),
      );

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => signInSsoRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    final body = ctx.req.body<SignInSsoBody>();
    final result = await context
        .api(ctx)
        .signInOAuth(provider: body.providerId, callbackUrl: body.successUrl);
    return {
      'success': true,
      'data': {'providerId': body.providerId, 'redirectUrl': result.url},
    };
  }
}
