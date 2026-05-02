import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';

part 'schema.g.dart';

const getUserResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': JsonSchema.ref('#/components/schemas/DartEdgeAuthUser')},
  required: <String>['user'],
  additionalProperties: false,
);

const getUserRouteResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': DartEdgeAuthUser.jsonSchema},
  required: <String>['user'],
  additionalProperties: false,
);

const getUserRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[DartEdgeAuthUser.jsonSchema, getUserResponseSchema],
);

@FromSchema(
  getUserResponseSchema,
  registry: getUserRouteSchemas,
  refs: [SchemaRefModel(DartEdgeAuthUser)],
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
