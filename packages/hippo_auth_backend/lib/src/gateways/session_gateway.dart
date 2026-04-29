import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_sql/dart_edge_sql.dart';

final class SessionGateway {
  const SessionGateway(this.database);

  final SqlExecutor database;

  Future<DartEdgeAuthSession?> findByToken(String token) {
    return database.builder
        .selectFrom(DartEdgeAuthSchema.sessions)
        .selectTable(DartEdgeAuthSchema.sessions)
        .where(DartEdgeAuthSessionsTable.token.equals(token))
        .executeTakeFirst();
  }

  Future<void> updateExpiresAt({required String sessionId, required DateTime expiresAt}) async {
    await database.builder
        .updateTable(DartEdgeAuthSchema.sessions)
        .set(<String, Object?>{'expires_at': expiresAt.toUtc().toIso8601String()})
        .where(DartEdgeAuthSessionsTable.id.equals(sessionId))
        .execute();
  }
}
