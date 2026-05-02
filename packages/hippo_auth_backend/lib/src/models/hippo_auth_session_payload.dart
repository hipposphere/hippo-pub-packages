import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

part 'hippo_auth_session_payload.g.dart';

const hippoAuthSessionPayloadSchema = JsonSchema.object(
  id: 'HippoAuthSessionPayload',
  title: 'HippoAuthSessionPayload',
  properties: <String, JsonSchema>{
    'session_id': JsonSchema.string(),
    'token': JsonSchema.string(),
    'expires_at': JsonSchema.string(format: 'date-time'),
    'user': DartEdgeAuthUser.schemaRef,
  },
  required: ['session_id', 'token', 'expires_at', 'user'],
  additionalProperties: false,
);

@FromSchema(
  hippoAuthSessionPayloadSchema,
  registry: JsonSchemaRegistry(schemas: [DartEdgeAuthUser.jsonSchema]),
  refs: [SchemaRefModel(DartEdgeAuthUser)],
)
typedef HippoAuthSessionPayload = _$HippoAuthSessionPayload;
