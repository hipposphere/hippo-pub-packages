import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

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
  properties: <String, JsonSchema>{'user': JsonSchema.ref('#/components/schemas/DartEdgeAuthUser')},
  required: <String>['user'],
  additionalProperties: false,
);

const adminUpdateUserRouteResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': DartEdgeAuthUser.jsonSchema},
  required: <String>['user'],
  additionalProperties: false,
);

const adminUpdateUserRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[
    DartEdgeAuthUser.jsonSchema,
    adminUpdateUserBodySchema,
    adminUpdateUserResponseSchema,
  ],
);

@FromSchema(adminUpdateUserBodySchema, registry: adminUpdateUserRouteSchemas)
typedef AdminUpdateUserBody = _$AdminUpdateUserBody;

@FromSchema(
  adminUpdateUserResponseSchema,
  registry: adminUpdateUserRouteSchemas,
  refs: [SchemaRefModel(DartEdgeAuthUser)],
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
