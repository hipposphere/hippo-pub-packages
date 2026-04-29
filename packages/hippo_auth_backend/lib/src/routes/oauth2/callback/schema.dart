import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:dart_edge_http_server_codegen/dart_edge_http_server_codegen.dart';

part 'schema.g.dart';

const oauth2CallbackParamsSchema = JsonSchema.object(
  properties: <String, JsonSchema>{'providerId': JsonSchema.string()},
  required: <String>['providerId'],
  additionalProperties: false,
);

const oauth2CallbackRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[oauth2CallbackParamsSchema],
);

@FromSchema(oauth2CallbackParamsSchema, registry: oauth2CallbackRouteSchemas)
typedef OAuth2CallbackParams = _$OAuth2CallbackParams;

final oauth2CallbackRouteOptions = RouteOptions(
  operationId: 'getV1Oauth2CallbackByProviderId',
  summary: 'Handle an OAuth2 provider callback.',
  params: oauth2CallbackParamsSchema,
  success: ResponseSpec.text(status: 302),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 401, code: 'OAuth2CallbackInvalidSession'),
    ErrorResponse(status: 500, code: 'OAuth2CallbackFailed'),
    ErrorResponse(status: 501, code: 'OAuth2CallbackUnsupported'),
  ],
);
