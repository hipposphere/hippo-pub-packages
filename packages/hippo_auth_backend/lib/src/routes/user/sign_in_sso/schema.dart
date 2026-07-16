import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:json_schema/json_schema.dart';

part 'schema.g.dart';

const signInSsoBodySchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'provider_id': JsonSchema.string(),
    'success_url': JsonSchema.string(),
  },
  required: <String>['provider_id', 'success_url'],
  additionalProperties: false,
);

const signInSsoResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'success': JsonSchema.boolean(),
    'data': JsonSchema.object(
      properties: <String, JsonSchema>{
        'providerId': JsonSchema.string(),
        'redirectUrl': JsonSchema.string(),
      },
      required: <String>['providerId', 'redirectUrl'],
      additionalProperties: false,
    ),
  },
  required: <String>['success', 'data'],
  additionalProperties: false,
);

const signInSsoRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[signInSsoBodySchema, signInSsoResponseSchema],
);

@FromSchema(signInSsoBodySchema, registry: signInSsoRouteSchemas)
typedef SignInSsoBody = _$SignInSsoBody;

@FromSchema(signInSsoResponseSchema, registry: signInSsoRouteSchemas)
typedef SignInSsoResponse = _$SignInSsoResponse;

final signInSsoRouteOptions = RouteOptions(
  operationId: 'postV1UserSignInSso',
  summary: 'Start an SSO sign-in flow.',
  body: RequestBody.json(schema: signInSsoBodySchema, decoder: SignInSsoBody.fromJson),
  success: ResponseSpec.json(schema: signInSsoResponseSchema),
  errors: const <ErrorResponse>[ErrorResponse(status: 500, code: 'SSOLoginInitiationFailed')],
);
