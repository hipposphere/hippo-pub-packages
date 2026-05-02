import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

part 'schema.g.dart';

const adminCreateUserBodySchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'email': JsonSchema.string(format: 'email'),
    'password': JsonSchema.string(),
    'name': JsonSchema.string(),
    'role': JsonSchema.any(),
    'data': JsonSchema.object(nullable: true, additionalProperties: true),
  },
  required: <String>['email', 'password', 'name'],
  additionalProperties: false,
);

const adminCreateUserResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': JsonSchema.ref('#/components/schemas/DartEdgeAuthUser')},
  required: <String>['user'],
  additionalProperties: false,
);

const adminCreateUserRouteResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': DartEdgeAuthUser.jsonSchema},
  required: <String>['user'],
  additionalProperties: false,
);

const adminCreateUserRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[
    DartEdgeAuthUser.jsonSchema,
    adminCreateUserBodySchema,
    adminCreateUserResponseSchema,
  ],
);

@FromSchema(adminCreateUserBodySchema, registry: adminCreateUserRouteSchemas)
typedef AdminCreateUserBody = _$AdminCreateUserBody;

@FromSchema(
  adminCreateUserResponseSchema,
  registry: adminCreateUserRouteSchemas,
  refs: [SchemaRefModel(DartEdgeAuthUser)],
)
typedef AdminCreateUserResponse = _$AdminCreateUserResponse;

final adminCreateUserRouteOptions = RouteOptions(
  operationId: 'postV1AdminCreateUser',
  summary: 'Create a user as an administrator.',
  body: RequestBody.json(schema: adminCreateUserBodySchema, decoder: AdminCreateUserBody.fromJson),
  success: ResponseSpec.json(schema: adminCreateUserRouteResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400, code: 'AdminCreateUserFailed'),
    ErrorResponse(status: 401, code: 'Unauthorized'),
    ErrorResponse(status: 403, code: 'Forbidden'),
    ErrorResponse(status: 500, code: 'AdminCreateUserFailed'),
    ErrorResponse(status: 501, code: 'AdminDisabled'),
  ],
);
