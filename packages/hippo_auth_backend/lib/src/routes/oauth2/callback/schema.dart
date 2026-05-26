import 'package:dart_edge_core/dart_edge_core.dart';

part 'schema.g.dart';

const oauth2CallbackParamsSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'providerId': JsonSchema.string()},
  required: <String>['providerId'],
  additionalProperties: false,
);

const oauth2CallbackQuerySchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'code': JsonSchema.string(nullable: true),
    'state': JsonSchema.string(nullable: true),
    'error': JsonSchema.string(nullable: true),
    'error_description': JsonSchema.string(nullable: true),
    'session_state': JsonSchema.string(nullable: true),
  },
  additionalProperties: true,
);

const oauth2CallbackRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[oauth2CallbackParamsSchema, oauth2CallbackQuerySchema],
);

@FromSchema(oauth2CallbackParamsSchema, registry: oauth2CallbackRouteSchemas)
typedef OAuth2CallbackParams = _$OAuth2CallbackParams;

final oauth2CallbackRouteOptions = RouteOptions(
  operationId: 'getV1Oauth2CallbackByProviderId',
  summary: 'Handle an OAuth2 provider callback.',
  params: oauth2CallbackParamsSchema,
  query: oauth2CallbackQuerySchema,
  success: ResponseSpec.text(status: 302),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 401, code: 'OAuth2CallbackInvalidSession'),
    ErrorResponse(status: 500, code: 'OAuth2CallbackFailed'),
    ErrorResponse(status: 501, code: 'OAuth2CallbackUnsupported'),
  ],
);
