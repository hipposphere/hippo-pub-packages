import 'package:dart_edge_core/dart_edge_core.dart';

part 'schema.g.dart';

const adminListOAuthClientsResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'oauth_clients': JsonSchema.array(items: JsonSchema.object(additionalProperties: true)),
  },
  required: <String>['oauth_clients'],
  additionalProperties: false,
);

const adminListOAuthClientsRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[adminListOAuthClientsResponseSchema],
);

@FromSchema(adminListOAuthClientsResponseSchema, registry: adminListOAuthClientsRouteSchemas)
typedef AdminListOAuthClientsResponse = _$AdminListOAuthClientsResponse;

final adminListOAuthClientsRouteOptions = RouteOptions(
  operationId: 'getV1AdminListOauthClients',
  summary: 'List OAuth clients as an administrator.',
  success: ResponseSpec.json(schema: adminListOAuthClientsResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 401, code: 'Unauthorized'),
    ErrorResponse(status: 403, code: 'Forbidden'),
    ErrorResponse(status: 501, code: 'AdminListOAuthClientsUnsupported'),
  ],
);
