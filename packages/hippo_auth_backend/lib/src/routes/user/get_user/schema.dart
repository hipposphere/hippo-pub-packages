import 'package:dart_http_core/dart_http_core.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const getUserResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': AuthUserRow.schemaRef},
  required: <String>['user'],
  additionalProperties: false,
);

const getUserRouteResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': AuthUserRow.jsonSchema},
  required: <String>['user'],
  additionalProperties: false,
);

const getUserRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[AuthUserRow.jsonSchema, getUserResponseSchema],
);

@FromSchema(
  getUserResponseSchema,
  registry: getUserRouteSchemas,
  refs: [SchemaRefModel(AuthUserRow)],
)
typedef GetUserResponse = _$GetUserResponse;

final getUserRouteOptions = RouteOptions(
  operationId: 'getV1UserGetUser',
  summary: 'Return the authenticated user.',
  success: ResponseSpec.json(schema: getUserRouteResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 401, code: 'Unauthorized'),
    ErrorResponse(status: 500, code: 'GetUserFailed'),
  ],
);
