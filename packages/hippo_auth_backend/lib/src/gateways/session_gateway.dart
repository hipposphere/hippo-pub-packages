import 'package:dart_better_auth/dart_better_auth.dart';
import 'package:dart_sql/dart_sql.dart';

final class SessionGateway {
  SessionGateway(this.database, {String? schema})
    : _sessions = DartBetterAuthSchema(databaseSchema: schema).sessions;

  final SqlExecutor database;
  final DartBetterAuthSessionsTable _sessions;

  Future<DartBetterAuthSession?> findByToken(String token) async {
    final session = await database.typed
        .from(_sessions)
        .selectTable(_sessions)
        .where(DartBetterAuthSessionsTable.token.equals(token))
        .executeFirstOrNull();
    if (session == null) {
      return null;
    }
    return _sessionFromRow(session);
  }

  Future<void> updateExpiresAt({required String sessionId, required DateTime expiresAt}) async {
    await database.typed
        .updateTable(_sessions)
        .set(DartBetterAuthSessionUpdate(expiresAt: SqlValue(expiresAt.toUtc())))
        .where(DartBetterAuthSessionsTable.id.equals(sessionId))
        .execute();
  }
}

DartBetterAuthSession _sessionFromRow(DartBetterAuthSessionRow row) => DartBetterAuthSession(
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
