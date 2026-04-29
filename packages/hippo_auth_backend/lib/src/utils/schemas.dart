import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippo_auth_backend/src/models/hippo_auth_session_payload.dart';

const hippoAuthSchemas = <JsonSchema>[
  DartEdgeAuthUser.jsonSchema,
  DartEdgeAuthSession.jsonSchema,
  hippoAuthSessionPayloadSchema,
];
