import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const refreshSessionResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'expires_at': JsonSchema.string(format: 'date-time')},
  required: <String>['expires_at'],
  additionalProperties: false,
);

const refreshSessionRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[refreshSessionResponseSchema],
);

@FromSchema(refreshSessionResponseSchema, registry: refreshSessionRouteSchemas)
typedef RefreshSessionResponse = _$RefreshSessionResponse;

final refreshSessionRouteOptions = RouteOptions(
  operationId: 'postV1UserRefreshSession',
  summary: 'Extend a near-expiry session.',
  success: ResponseSpec.json(schema: refreshSessionResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 401, code: 'RefreshSessionInvalidRequest'),
    ErrorResponse(status: 500, code: 'RefreshSessionFailed'),
  ],
);
