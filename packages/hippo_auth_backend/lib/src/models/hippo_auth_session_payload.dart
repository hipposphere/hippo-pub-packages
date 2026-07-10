import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';

part 'hippo_auth_session_payload.g.dart';

const hippoAuthSessionPayloadSchema = JsonSchema.object(
  id: 'HippoAuthSessionPayload',
  title: 'HippoAuthSessionPayload',
  properties: <String, JsonSchema>{
    'session_id': JsonSchema.string(),
    'token': JsonSchema.string(),
    'expires_at': JsonSchema.string(format: 'date-time'),
    'user': AuthUserRow.schemaRef,
  },
  required: ['session_id', 'token', 'expires_at', 'user'],
  additionalProperties: false,
);

@FromSchema(
  hippoAuthSessionPayloadSchema,
  registry: JsonSchemaRegistry(schemas: [AuthUserRow.jsonSchema]),
  refs: [SchemaRefModel(AuthUserRow)],
)
typedef HippoAuthSessionPayload = _$HippoAuthSessionPayload;
