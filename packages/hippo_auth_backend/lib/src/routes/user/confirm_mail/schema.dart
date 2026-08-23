import 'package:dart_http_core/dart_http_core.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const confirmMailBodySchema = JsonSchema.object(
  properties: <String, JsonSchema>{'token': JsonSchema.string()},
  required: <String>['token'],
  additionalProperties: false,
);

const confirmMailResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'success': JsonSchema.boolean()},
  required: <String>['success'],
  additionalProperties: false,
);

const confirmMailRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[confirmMailBodySchema, confirmMailResponseSchema],
);

@FromSchema(confirmMailBodySchema, registry: confirmMailRouteSchemas)
typedef ConfirmMailBody = _$ConfirmMailBody;

@FromSchema(confirmMailResponseSchema, registry: confirmMailRouteSchemas)
typedef ConfirmMailResponse = _$ConfirmMailResponse;

final confirmMailRouteOptions = RouteOptions(
  operationId: 'postV1UserConfirmMail',
  summary: 'Confirm an email verification token.',
  body: RequestBody.json(schema: confirmMailBodySchema, decoder: ConfirmMailBody.fromJson),
  success: ResponseSpec.json(schema: confirmMailResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400, code: 'ConfirmMailFailed'),
    ErrorResponse(status: 500, code: 'ConfirmMailFailed'),
  ],
);
