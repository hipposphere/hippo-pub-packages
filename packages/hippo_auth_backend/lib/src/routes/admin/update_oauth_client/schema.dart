import 'package:dart_http_core/dart_http_core.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const adminUpdateOAuthClientBodySchema = JsonSchema.object(additionalProperties: true);

const adminUpdateOAuthClientResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'oauth_client': JsonSchema.object(additionalProperties: true)},
  required: <String>['oauth_client'],
  additionalProperties: false,
);

const adminUpdateOAuthClientRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[adminUpdateOAuthClientBodySchema, adminUpdateOAuthClientResponseSchema],
);

@FromSchema(adminUpdateOAuthClientResponseSchema, registry: adminUpdateOAuthClientRouteSchemas)
typedef AdminUpdateOAuthClientResponse = _$AdminUpdateOAuthClientResponse;

final adminUpdateOAuthClientRouteOptions = RouteOptions(
  operationId: 'postV1AdminUpdateOauthClient',
  summary: 'Update an OAuth client as an administrator.',
  body: RequestBody.json(schema: adminUpdateOAuthClientBodySchema),
  success: ResponseSpec.json(schema: adminUpdateOAuthClientResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400),
    ErrorResponse(status: 401, code: 'Unauthorized'),
    ErrorResponse(status: 403, code: 'Forbidden'),
    ErrorResponse(status: 501, code: 'AdminUpdateOAuthClientUnsupported'),
  ],
);
