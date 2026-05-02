import 'package:dart_edge_core/dart_edge_core.dart';

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
  properties: <String, JsonSchema>{'url': JsonSchema.string()},
  required: <String>['url'],
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
  errors: const <ErrorResponse>[
    ErrorResponse(status: 500, code: 'SSOLoginInitiationFailed'),
    ErrorResponse(status: 501, code: 'SSOLoginUnsupported'),
  ],
);
