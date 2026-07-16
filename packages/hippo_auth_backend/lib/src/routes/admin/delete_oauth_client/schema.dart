import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const adminDeleteOAuthClientBodySchema = JsonSchema.object(
  properties: <String, JsonSchema>{'client_id': JsonSchema.string()},
  required: <String>['client_id'],
  additionalProperties: false,
);

const adminDeleteOAuthClientResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'success': JsonSchema.boolean(),
    'client_id': JsonSchema.string(),
  },
  required: <String>['success', 'client_id'],
  additionalProperties: false,
);

const adminDeleteOAuthClientRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[adminDeleteOAuthClientBodySchema, adminDeleteOAuthClientResponseSchema],
);

@FromSchema(adminDeleteOAuthClientBodySchema, registry: adminDeleteOAuthClientRouteSchemas)
typedef AdminDeleteOAuthClientBody = _$AdminDeleteOAuthClientBody;

@FromSchema(adminDeleteOAuthClientResponseSchema, registry: adminDeleteOAuthClientRouteSchemas)
typedef AdminDeleteOAuthClientResponse = _$AdminDeleteOAuthClientResponse;

final adminDeleteOAuthClientRouteOptions = RouteOptions(
  operationId: 'postV1AdminDeleteOauthClient',
  summary: 'Delete an OAuth client as an administrator.',
  body: RequestBody.json(
    schema: adminDeleteOAuthClientBodySchema,
    decoder: AdminDeleteOAuthClientBody.fromJson,
  ),
  success: ResponseSpec.json(schema: adminDeleteOAuthClientResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400),
    ErrorResponse(status: 401, code: 'Unauthorized'),
    ErrorResponse(status: 403, code: 'Forbidden'),
    ErrorResponse(status: 501, code: 'AdminDeleteOAuthClientUnsupported'),
  ],
);
