import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:dart_edge_http_server_codegen/dart_edge_http_server_codegen.dart';

part 'schema.g.dart';

const resetPasswordBodySchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'token': JsonSchema.string(),
    'new_password': JsonSchema.string(),
  },
  required: <String>['token', 'new_password'],
  additionalProperties: false,
);

const resetPasswordResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'success': JsonSchema.boolean()},
  required: <String>['success'],
  additionalProperties: false,
);

const resetPasswordRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[resetPasswordBodySchema, resetPasswordResponseSchema],
);

@FromSchema(resetPasswordBodySchema, registry: resetPasswordRouteSchemas)
typedef ResetPasswordBody = _$ResetPasswordBody;

@FromSchema(resetPasswordResponseSchema, registry: resetPasswordRouteSchemas)
typedef ResetPasswordResponse = _$ResetPasswordResponse;

final resetPasswordRouteOptions = RouteOptions(
  operationId: 'postV1UserResetPassword',
  summary: 'Reset a password using a reset token.',
  body: RequestBody.json(schema: resetPasswordBodySchema, decoder: ResetPasswordBody.fromJson),
  success: ResponseSpec.json(schema: resetPasswordResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400, code: 'ResetPasswordFailed'),
    ErrorResponse(status: 500, code: 'ResetPasswordFailed'),
  ],
);
