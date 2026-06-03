import 'dart:convert';

import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_sql/dart_edge_sql.dart';

final class VerificationGateway {
  VerificationGateway(this.database, {String? schema})
    : _verifications = DartEdgeAuthVerificationsTable.withSchema(schema);

  final SqlExecutor database;
  final DartEdgeAuthVerificationsTable _verifications;

  Future<String?> oauthCallbackUrl(String state) async {
    return _callbackUrl('oauth:$state');
  }

  Future<String?> oauthRelayCallbackUrl(String state) {
    return _callbackUrl(_oauthRelayCallbackIdentifier(state));
  }

  Future<void> storeOAuthRelayCallbackUrl({
    required String state,
    required String callbackUrl,
  }) async {
    final identifier = _oauthRelayCallbackIdentifier(state);
    final now = DateTime.now().toUtc();
    await database.typed
        .deleteFrom(_verifications)
        .where(_verifications.identifier.equals(identifier))
        .execute();
    await database.typed
        .insertInto(_verifications)
        .values(
          DartEdgeAuthVerificationInsert(
            id: SqlValue(identifier),
            identifier: identifier,
            value: jsonEncode({'callback_url': callbackUrl}),
            expiresAt: now.add(const Duration(minutes: 15)),
            createdAt: now,
            updatedAt: now,
          ),
        )
        .execute();
  }

  Future<void> deleteOAuthRelayCallbackUrl(String state) async {
    await database.typed
        .deleteFrom(_verifications)
        .where(_verifications.identifier.equals(_oauthRelayCallbackIdentifier(state)))
        .execute();
  }

  Future<String?> _callbackUrl(String identifier) async {
    final verification = await database.typed
        .from(_verifications)
        .selectTable(_verifications)
        .where(_verifications.identifier.equals(identifier))
        .executeFirstOrNull();
    if (verification == null) {
      return null;
    }
    final value = jsonDecode(verification.value);
    if (value case {'callback_url': final String callbackUrl}) {
      return callbackUrl;
    }
    return null;
  }
}

String _oauthRelayCallbackIdentifier(String state) => 'hippo-oauth-callback:$state';
