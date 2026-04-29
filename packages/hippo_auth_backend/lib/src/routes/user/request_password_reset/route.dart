import 'package:dart_edge_core/dart_edge_core.dart';

import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import '../../shared/route_utils.dart';
import 'schema.dart';

final class RequestPasswordResetRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  RequestPasswordResetRoute(this.context)
    : super(
        error: const HippoAuthRouteError(
          'RequestPasswordResetFailed',
          'Request password reset failed.',
          status: 400,
        ),
      );

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => requestPasswordResetRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    final body = ctx.req.body<RequestPasswordResetBody>();
    final response = await context.auth.api.call(
      method: HttpMethod.post,
      path: '/request-password-reset',
      body: {'email': body.email},
    );
    return RequestPasswordResetResponse(success: statusFromResponse(response));
  }
}
