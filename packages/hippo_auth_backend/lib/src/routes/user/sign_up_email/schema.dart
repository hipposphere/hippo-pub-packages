import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:dart_edge_http_server_codegen/dart_edge_http_server_codegen.dart';

import '../../../models/hippo_auth_session_payload.dart';

part 'schema.g.dart';

const signUpEmailBodySchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'email': JsonSchema.string(format: 'email'),
    'password': JsonSchema.string(),
    'name': JsonSchema.string(),
  },
  required: <String>['email', 'password', 'name'],
  additionalProperties: false,
);

const signUpEmailRouteSchemas = JsonSchemaRegistry(schemas: <JsonSchema>[signUpEmailBodySchema]);

@FromSchema(signUpEmailBodySchema, registry: signUpEmailRouteSchemas)
typedef SignUpEmailBody = _$SignUpEmailBody;

final signUpEmailRouteOptions = RouteOptions(
  operationId: 'postV1UserSignUpEmail',
  summary: 'Create a user using email and password.',
  body: RequestBody.json(schema: signUpEmailBodySchema, decoder: SignUpEmailBody.fromJson),
  success: ResponseSpec.json(schema: hippoAuthSessionPayloadSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 400, code: 'SignUpEmailFailed'),
    ErrorResponse(status: 403, code: 'SignUpEmailDisabled'),
    ErrorResponse(status: 500, code: 'SignUpEmailFailed'),
  ],
);
