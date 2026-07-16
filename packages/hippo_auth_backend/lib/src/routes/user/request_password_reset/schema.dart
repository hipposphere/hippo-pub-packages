import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const requestPasswordResetBodySchema = JsonSchema.object(
  properties: <String, JsonSchema>{'email': JsonSchema.string(format: 'email')},
  required: <String>['email'],
  additionalProperties: false,
);

const requestPasswordResetResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'success': JsonSchema.boolean()},
  required: <String>['success'],
  additionalProperties: false,
);

const requestPasswordResetRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[requestPasswordResetBodySchema, requestPasswordResetResponseSchema],
);

@FromSchema(requestPasswordResetBodySchema, registry: requestPasswordResetRouteSchemas)
typedef RequestPasswordResetBody = _$RequestPasswordResetBody;

@FromSchema(requestPasswordResetResponseSchema, registry: requestPasswordResetRouteSchemas)
typedef RequestPasswordResetResponse = _$RequestPasswordResetResponse;

final requestPasswordResetRouteOptions = RouteOptions(
  operationId: 'postV1UserRequestPasswordReset',
  summary: 'Request a password reset email.',
  body: RequestBody.json(
    schema: requestPasswordResetBodySchema,
    decoder: RequestPasswordResetBody.fromJson,
  ),
  success: ResponseSpec.json(schema: requestPasswordResetResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400, code: 'RequestPasswordResetFailed'),
    ErrorResponse(status: 500, code: 'RequestPasswordResetFailed'),
  ],
);
