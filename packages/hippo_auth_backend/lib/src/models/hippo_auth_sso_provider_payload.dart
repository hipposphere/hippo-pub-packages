import 'package:dart_edge_core/dart_edge_core.dart';

const hippoAuthSsoProviderPayloadSchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'provider_id': JsonSchema.string(),
    'provider_type': JsonSchema.string(),
  },
  required: <String>['provider_id', 'provider_type'],
  additionalProperties: false,
);
