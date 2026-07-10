import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippo_auth_backend/src/models/hippo_auth_session_payload.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';

const hippoAuthSchemas = <JsonSchema>[
  AuthUserRow.jsonSchema,
  DartEdgeAuthSession.jsonSchema,
  hippoAuthSessionPayloadSchema,
];
