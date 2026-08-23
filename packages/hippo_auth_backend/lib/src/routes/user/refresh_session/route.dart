import 'package:dart_http_core/dart_http_core.dart';

import '../../../utils/api_error.dart';
import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import 'schema.dart';

final class RefreshSessionRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  RefreshSessionRoute(this.context)
    : super(
        error: const HippoAuthRouteError(
          'RefreshSessionFailed',
          'Refresh session failed.',
          status: 500,
        ),
      );

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => refreshSessionRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    final token = context.sessionToken(ctx);
    final session = await context.sessions.findByToken(token);
    if (session == null) {
      throw const HippoAuthBackendException(
        401,
        'RefreshSessionInvalidRequest',
        'Session not found.',
      );
    }

    final now = DateTime.now().toUtc();
    final expiresAt = session.expiresAt.toUtc();
    if (!expiresAt.isAfter(now)) {
      throw const HippoAuthBackendException(
        401,
        'RefreshSessionInvalidRequest',
        'Session expired.',
      );
    }

    final threshold = now.add(const Duration(days: 89));
    if (expiresAt.isAfter(threshold)) {
      return RefreshSessionResponse(expiresAt: expiresAt.toIso8601String());
    }

    final newExpiresAt = now.add(const Duration(days: 90));
    await context.sessions.updateExpiresAt(sessionId: session.id, expiresAt: newExpiresAt);
    return RefreshSessionResponse(expiresAt: newExpiresAt.toIso8601String());
  }
}
