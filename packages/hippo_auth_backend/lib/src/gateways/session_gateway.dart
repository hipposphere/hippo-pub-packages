import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_sql/dart_edge_sql.dart';

final class SessionGateway {
  SessionGateway(this.database, {String? schema})
    : _sessions = DartEdgeAuthSchema(databaseSchema: schema).sessions;

  final SqlExecutor database;
  final DartEdgeAuthSessionsTable _sessions;

  Future<DartEdgeAuthSession?> findByToken(String token) async {
    final session = await database.typed
        .from(_sessions)
        .selectTable(_sessions)
        .where(_sessions.token.equals(token))
        .executeFirstOrNull();
    if (session == null) {
      return null;
    }
    return _sessionFromRow(session);
  }

  Future<void> updateExpiresAt({required String sessionId, required DateTime expiresAt}) async {
    await database.typed
        .updateTable(_sessions)
        .set(DartEdgeAuthSessionUpdate(expiresAt: SqlValue(expiresAt.toUtc())))
        .where(_sessions.id.equals(sessionId))
        .execute();
  }
}

DartEdgeAuthSession _sessionFromRow(DartEdgeAuthSessionRow row) => DartEdgeAuthSession(
  id: row.id,
  userId: row.userId,
  token: row.token,
  ipAddress: row.ipAddress,
  userAgent: row.userAgent,
  expiresAt: row.expiresAt,
  activeOrganizationId: null,
  impersonatedBy: row.impersonatedBy,
  active: true,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
);
