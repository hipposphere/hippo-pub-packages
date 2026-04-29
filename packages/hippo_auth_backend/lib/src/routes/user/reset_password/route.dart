import 'package:dart_edge_core/dart_edge_core.dart';

import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import '../../shared/route_utils.dart';
import 'schema.dart';

final class ResetPasswordRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  ResetPasswordRoute(this.context)
    : super(
        error: const HippoAuthRouteError(
          'ResetPasswordFailed',
          'Reset password failed.',
          status: 400,
        ),
      );

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => resetPasswordRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    final body = ctx.req.body<ResetPasswordBody>();
    final response = await context.auth.api.call(
      method: HttpMethod.post,
      path: '/reset-password',
      body: {'token': body.token, 'newPassword': body.newPassword},
    );
    return ResetPasswordResponse(success: statusFromResponse(response));
  }
}
