import 'package:dart_edge_core/dart_edge_core.dart';

part 'schema.g.dart';

const oauth2SignInParamsSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'providerId': JsonSchema.string()},
  required: <String>['providerId'],
  additionalProperties: false,
);

const oauth2SignInQuerySchema = JsonSchema.object(
  properties: <String, JsonSchema>{'callbackURL': JsonSchema.string()},
  required: <String>['callbackURL'],
  additionalProperties: true,
);

const oauth2SignInRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[oauth2SignInParamsSchema, oauth2SignInQuerySchema],
);

@FromSchema(oauth2SignInParamsSchema, registry: oauth2SignInRouteSchemas)
typedef OAuth2SignInParams = _$OAuth2SignInParams;

final oauth2SignInRouteOptions = RouteOptions(
  operationId: 'getV1Oauth2SignInByProviderId',
  summary: 'Start an OAuth2 provider sign-in flow.',
  params: oauth2SignInParamsSchema,
  query: oauth2SignInQuerySchema,
  success: ResponseSpec.text(status: 302),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 500, code: 'SSOLoginInitiationFailed'),
    ErrorResponse(status: 501, code: 'OAuth2SignInUnsupported'),
  ],
);
