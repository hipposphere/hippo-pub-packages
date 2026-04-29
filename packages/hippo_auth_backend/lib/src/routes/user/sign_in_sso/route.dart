import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../utils/api_error.dart';
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
  Object? handleJson(RequestContext<TServices> ctx) {
    final body = ctx.req.body<SignInSsoBody>();
    return hippoAuthErrorResponse(
      501,
      'SSOLoginUnsupported',
      'SSO sign-in is not supported by dart_edge_auth.',
      details: {'provider_id': body.providerId},
    );
  }
}
