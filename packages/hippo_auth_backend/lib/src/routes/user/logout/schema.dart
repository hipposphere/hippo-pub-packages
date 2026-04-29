import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:dart_edge_http_server_codegen/dart_edge_http_server_codegen.dart';

part 'schema.g.dart';

const logoutResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': JsonSchema.ref('#/components/schemas/DartEdgeAuthUser')},
  required: <String>['user'],
  additionalProperties: false,
);

const logoutRouteResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user': DartEdgeAuthUser.jsonSchema},
  required: <String>['user'],
  additionalProperties: false,
);

const logoutRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[DartEdgeAuthUser.jsonSchema, logoutResponseSchema],
);

@FromSchema(
  logoutResponseSchema,
  registry: logoutRouteSchemas,
  refs: [SchemaRefModel(DartEdgeAuthUser)],
)
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
