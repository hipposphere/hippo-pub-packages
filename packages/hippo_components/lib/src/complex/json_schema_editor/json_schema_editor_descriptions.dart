import 'package:hippo_utils/hippo_utils.dart';

const jsonSchemaHelpByKeyword = {
  'const': 'Require this schema to match one exact JSON value.',
  'default': 'Default value used when the field is not supplied.',
  'type': 'Type of JSON value this node validates.',
  'title': 'Optional human-readable name for this schema node.',
  'description': 'Optional description shown in docs and editor tooling.',
  'allOf':
      'Combine this schema with every schema listed here. The instance must satisfy all of them.',
  'oneOf': 'Match exactly one schema from the listed alternatives.',
  r'$ref': 'Reference another schema by JSON Pointer, URI, or external schema location.',
  'minLength': 'Minimum number of characters allowed in the string.',
  'maxLength': 'Maximum number of characters allowed in the string.',
  'pattern': 'Regular expression pattern the string must match.',
  'enum': 'Allowed set of string values. Only one of these values is valid.',
  'minimum': 'Smallest allowed numeric value.',
  'maximum': 'Largest allowed numeric value.',
  'exclusiveMinimum': 'If true, value must be greater than minimum.',
  'exclusiveMaximum': 'If true, value must be less than maximum.',
  'multipleOf': 'Value must be a multiple of this number.',
  'minItems': 'Minimum number of items required in the array.',
  'maxItems': 'Maximum number of items allowed in the array.',
  'uniqueItems': 'All items must be unique across the array.',
  'additionalProperties': 'Allow properties not listed under "Properties" for this object.',
  'required': 'Whether this property must appear in the object.',
  'propertyKey': 'Property identifier used as key in the object.',
  'properties': 'Property definitions for fields contained in the object.',
  'items': 'Schema applied to each item in the array.',
  'extensionField': 'Additional schema metadata entries (commonly namespaced as extension keys).',
};

String jsonSchemaTypeLabel(JsonSchemaNodeType type) {
  return switch (type) {
    JsonSchemaNodeType.string => 'String',
    JsonSchemaNodeType.number => 'Number',
    JsonSchemaNodeType.integer => 'Integer',
    JsonSchemaNodeType.boolean => 'Boolean',
    JsonSchemaNodeType.object => 'Object',
    JsonSchemaNodeType.array => 'Array',
  };
}

String jsonSchemaTypeHelp(JsonSchemaNodeType type) {
  return switch (type) {
    JsonSchemaNodeType.string => 'String: text value (e.g., names, labels, IDs).',
    JsonSchemaNodeType.integer => 'Integer: whole number without decimals.',
    JsonSchemaNodeType.number => 'Number: numeric value, including decimals.',
    JsonSchemaNodeType.boolean => 'Boolean: true/false value.',
    JsonSchemaNodeType.object => 'Object: map with named properties.',
    JsonSchemaNodeType.array => 'Array: ordered list of items.',
  };
}
