import 'package:dart_edge_core/dart_edge_core.dart';

import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import '../../shared/route_utils.dart';
import 'schema.dart';

final class ConfirmMailRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  ConfirmMailRoute(this.context)
    : super(
        error: const HippoAuthRouteError('ConfirmMailFailed', 'Confirm mail failed.', status: 400),
      );

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => confirmMailRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    final body = ctx.req.body<ConfirmMailBody>();
    final response = await context.auth.api.call(
      method: HttpMethod.get,
      path: '/verify-email',
      query: {'token': body.token},
    );
    return ConfirmMailResponse(success: statusFromResponse(response));
  }
}
