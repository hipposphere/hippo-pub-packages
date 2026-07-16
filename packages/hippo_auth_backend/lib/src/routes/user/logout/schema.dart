import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const logoutResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': AuthUserRow.schemaRef},
  required: <String>['user'],
  additionalProperties: false,
);

const logoutRouteResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': AuthUserRow.jsonSchema},
  required: <String>['user'],
  additionalProperties: false,
);

const logoutRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[AuthUserRow.jsonSchema, logoutResponseSchema],
);

@FromSchema(logoutResponseSchema, registry: logoutRouteSchemas, refs: [SchemaRefModel(AuthUserRow)])
typedef LogoutResponse = _$LogoutResponse;

final logoutRouteOptions = RouteOptions(
  operationId: 'getV1UserLogout',
  summary: 'Return the authenticated logout user payload.',
  success: ResponseSpec.json(schema: logoutRouteResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 401, code: 'Unauthorized'),
    ErrorResponse(status: 500, code: 'LogoutFailed'),
  ],
);
