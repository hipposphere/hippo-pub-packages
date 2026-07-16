import 'package:json_schema/json_schema.dart';

const hippoAuthSsoProviderPayloadSchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'provider_id': JsonSchema.string(),
    'provider_type': JsonSchema.string(),
  },
  required: <String>['provider_id', 'provider_type'],
  additionalProperties: false,
);
