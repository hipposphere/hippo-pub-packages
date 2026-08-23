import 'package:dart_http_core/dart_http_core.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const adminUpdateUserBodySchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'user_id': JsonSchema.string(),
    'role': JsonSchema.any(),
    'data': JsonSchema.object(nullable: true, additionalProperties: true),
  },
  required: <String>['user_id'],
  additionalProperties: false,
);

const adminUpdateUserResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': AuthUserRow.schemaRef},
  required: <String>['user'],
  additionalProperties: false,
);

const adminUpdateUserRouteResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': AuthUserRow.jsonSchema},
  required: <String>['user'],
  additionalProperties: false,
);

const adminUpdateUserRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[
    AuthUserRow.jsonSchema,
    adminUpdateUserBodySchema,
    adminUpdateUserResponseSchema,
  ],
);

@FromSchema(adminUpdateUserBodySchema, registry: adminUpdateUserRouteSchemas)
typedef AdminUpdateUserBody = _$AdminUpdateUserBody;

@FromSchema(
  adminUpdateUserResponseSchema,
  registry: adminUpdateUserRouteSchemas,
  refs: [SchemaRefModel(AuthUserRow)],
)
typedef AdminUpdateUserResponse = _$AdminUpdateUserResponse;

final adminUpdateUserRouteOptions = RouteOptions(
  operationId: 'postV1AdminUpdateUser',
  summary: 'Update a user as an administrator.',
  body: RequestBody.json(schema: adminUpdateUserBodySchema, decoder: AdminUpdateUserBody.fromJson),
  success: ResponseSpec.json(schema: adminUpdateUserRouteResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400, code: 'AdminUpdateUserFailed'),
    ErrorResponse(status: 401, code: 'Unauthorized'),
    ErrorResponse(status: 403, code: 'Forbidden'),
    ErrorResponse(status: 500, code: 'AdminUpdateUserFailed'),
    ErrorResponse(status: 501, code: 'AdminDisabled'),
  ],
);
