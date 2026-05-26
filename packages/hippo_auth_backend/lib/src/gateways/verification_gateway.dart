import 'dart:convert';

import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_sql/dart_edge_sql.dart';

final class VerificationGateway {
  VerificationGateway(this.database, {String? schema})
    : _verifications = DartEdgeAuthVerificationsTable.withSchema(schema);

  final SqlExecutor database;
  final DartEdgeAuthVerificationsTable _verifications;

  Future<String?> oauthCallbackUrl(String state) async {
    final verification = await database.typed
        .from(_verifications)
        .selectTable(_verifications)
        .where(_verifications.identifier.equals('oauth:$state'))
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
