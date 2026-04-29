import 'package:dart_edge_core/dart_edge_core.dart';

import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class GetUserInfoRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  GetUserInfoRoute(this.context)
    : super(
        error: const HippoAuthRouteError(
          'GetUserInfoFailed',
          'Failed to load authentication info.',
        ),
      );

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => getUserInfoRouteOptions;

  @override
  Object? handleJson(RequestContext<TServices> ctx) {
    return GetUserInfoResponse(
      emailSignInEnabled: context.options.emailSignInEnabled,
      emailSignUpEnabled: context.options.emailSignUpEnabled,
      ssoProviders: context.ssoProvidersJson(),
    );
  }
}
