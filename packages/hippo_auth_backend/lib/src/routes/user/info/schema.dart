import 'package:dart_http_core/dart_http_core.dart';
import 'package:json_schema/json_schema.dart';

import '../../../models/hippo_auth_sso_provider_payload.dart';

part 'schema.g.dart';

const getUserInfoResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'email_sign_in_enabled': JsonSchema.boolean(),
    'email_sign_up_enabled': JsonSchema.boolean(),
    'sso_providers': JsonSchema.array(items: hippoAuthSsoProviderPayloadSchema),
  },
  required: <String>['email_sign_in_enabled', 'email_sign_up_enabled', 'sso_providers'],
  additionalProperties: false,
);

const getUserInfoRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[hippoAuthSsoProviderPayloadSchema, getUserInfoResponseSchema],
);

@FromSchema(getUserInfoResponseSchema, registry: getUserInfoRouteSchemas)
typedef GetUserInfoResponse = _$GetUserInfoResponse;

final getUserInfoRouteOptions = RouteOptions(
  operationId: 'getV1UserInfo',
  summary: 'Return enabled authentication methods.',
  success: ResponseSpec.json(schema: getUserInfoResponseSchema),
  errors: const <ErrorResponse>[ErrorResponse(status: 500, code: 'GetUserInfoFailed')],
);
