import 'package:dart_http_core/dart_http_core.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const adminCreateOAuthClientBodySchema = JsonSchema.object(additionalProperties: true);

const adminCreateOAuthClientResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'oauth_client': JsonSchema.object(additionalProperties: true)},
  required: <String>['oauth_client'],
  additionalProperties: false,
);

const adminCreateOAuthClientRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[adminCreateOAuthClientBodySchema, adminCreateOAuthClientResponseSchema],
);

@FromSchema(adminCreateOAuthClientResponseSchema, registry: adminCreateOAuthClientRouteSchemas)
typedef AdminCreateOAuthClientResponse = _$AdminCreateOAuthClientResponse;

final adminCreateOAuthClientRouteOptions = RouteOptions(
  operationId: 'postV1AdminCreateOauthClient',
  summary: 'Create an OAuth client as an administrator.',
  body: RequestBody.json(schema: adminCreateOAuthClientBodySchema),
  success: ResponseSpec.json(schema: adminCreateOAuthClientResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400),
    ErrorResponse(status: 401, code: 'Unauthorized'),
    ErrorResponse(status: 403, code: 'Forbidden'),
    ErrorResponse(status: 501, code: 'AdminCreateOAuthClientUnsupported'),
  ],
);
