import 'package:dart_edge_core/dart_edge_core.dart';

import '../../../models/hippo_auth_session_payload.dart';

part 'schema.g.dart';

const signInEmailBodySchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'email': JsonSchema.string(format: 'email'),
    'password': JsonSchema.string(),
  },
  required: <String>['email', 'password'],
  additionalProperties: false,
);

const signInEmailRouteSchemas = JsonSchemaRegistry(schemas: <JsonSchema>[signInEmailBodySchema]);

@FromSchema(signInEmailBodySchema, registry: signInEmailRouteSchemas)
typedef SignInEmailBody = _$SignInEmailBody;

final signInEmailRouteOptions = RouteOptions(
  operationId: 'postV1UserSignInEmail',
  summary: 'Sign in using email and password.',
  body: RequestBody.json(schema: signInEmailBodySchema, decoder: SignInEmailBody.fromJson),
  success: ResponseSpec.json(schema: hippoAuthSessionPayloadSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400, code: 'SignInEmailFailed'),
    ErrorResponse(status: 403, code: 'SignInEmailDisabled'),
    ErrorResponse(status: 500, code: 'SignInEmailFailed'),
  ],
);
