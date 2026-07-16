import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const adminDeleteUserBodySchema = JsonSchema.object(
  properties: <String, JsonSchema>{'user_id': JsonSchema.string()},
  required: <String>['user_id'],
  additionalProperties: false,
);

const adminDeleteUserResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'success': JsonSchema.boolean(), 'user_id': JsonSchema.string()},
  required: <String>['success', 'user_id'],
  additionalProperties: false,
);

const adminDeleteUserRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[adminDeleteUserBodySchema, adminDeleteUserResponseSchema],
);

@FromSchema(adminDeleteUserBodySchema, registry: adminDeleteUserRouteSchemas)
typedef AdminDeleteUserBody = _$AdminDeleteUserBody;

@FromSchema(adminDeleteUserResponseSchema, registry: adminDeleteUserRouteSchemas)
typedef AdminDeleteUserResponse = _$AdminDeleteUserResponse;

final adminDeleteUserRouteOptions = RouteOptions(
  operationId: 'postV1AdminDeleteUser',
  summary: 'Delete a user as an administrator.',
  body: RequestBody.json(schema: adminDeleteUserBodySchema, decoder: AdminDeleteUserBody.fromJson),
  success: ResponseSpec.json(schema: adminDeleteUserResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400, code: 'AdminDeleteUserFailed'),
    ErrorResponse(status: 401, code: 'Unauthorized'),
    ErrorResponse(status: 403, code: 'Forbidden'),
    ErrorResponse(status: 500, code: 'AdminDeleteUserFailed'),
    ErrorResponse(status: 501, code: 'AdminDisabled'),
  ],
);
