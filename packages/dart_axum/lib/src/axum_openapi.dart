enum AxumParameterLocation {
  query('query'),
  header('header'),
  cookie('cookie');

  const AxumParameterLocation(this.value);

  final String value;
}

abstract base class AxumSchema {
  const AxumSchema();

  const factory AxumSchema.string({String? description, String? format, List<String>? enumValues}) =
      _AxumStringSchema;

  const factory AxumSchema.integer({String? description, String? format}) = _AxumIntegerSchema;

  const factory AxumSchema.number({String? description, String? format}) = _AxumNumberSchema;

  const factory AxumSchema.boolean({String? description}) = _AxumBooleanSchema;

  const factory AxumSchema.array(AxumSchema items, {String? description}) = _AxumArraySchema;

  const factory AxumSchema.object({
    required Map<String, AxumSchema> properties,
    Set<String> required,
    String? description,
    bool additionalProperties,
  }) = _AxumObjectSchema;

  const factory AxumSchema.reference(String ref) = _AxumReferenceSchema;

  const factory AxumSchema.nullable(AxumSchema inner) = _AxumNullableSchema;

  Map<String, Object?> toJson();
}

final class _AxumStringSchema extends AxumSchema {
  const _AxumStringSchema({this.description, this.format, this.enumValues});

  final String? description;
  final String? format;
  final List<String>? enumValues;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'string',
      if (description != null) 'description': description,
      if (format != null) 'format': format,
      if (enumValues != null) 'enum': enumValues,
    };
  }
}

final class _AxumIntegerSchema extends AxumSchema {
  const _AxumIntegerSchema({this.description, this.format});

  final String? description;
  final String? format;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'integer',
      if (description != null) 'description': description,
      if (format != null) 'format': format,
    };
  }
}

final class _AxumNumberSchema extends AxumSchema {
  const _AxumNumberSchema({this.description, this.format});

  final String? description;
  final String? format;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'number',
      if (description != null) 'description': description,
      if (format != null) 'format': format,
    };
  }
}

final class _AxumBooleanSchema extends AxumSchema {
  const _AxumBooleanSchema({this.description});

  final String? description;

  @override
  Map<String, Object?> toJson() {
    return {'type': 'boolean', if (description != null) 'description': description};
  }
}

final class _AxumArraySchema extends AxumSchema {
  const _AxumArraySchema(this.items, {this.description});

  final AxumSchema items;
  final String? description;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'array',
      'items': items.toJson(),
      if (description != null) 'description': description,
    };
  }
}

final class _AxumObjectSchema extends AxumSchema {
  const _AxumObjectSchema({
    required this.properties,
    this.required = const <String>{},
    this.description,
    this.additionalProperties = false,
  });

  final Map<String, AxumSchema> properties;
  final Set<String> required;
  final String? description;
  final bool additionalProperties;

  @override
  Map<String, Object?> toJson() {
    return {
      'type': 'object',
      if (description != null) 'description': description,
      'properties': {for (final entry in properties.entries) entry.key: entry.value.toJson()},
      if (required.isNotEmpty) 'required': required.toList()..sort(),
      'additionalProperties': additionalProperties,
    };
  }
}

final class _AxumReferenceSchema extends AxumSchema {
  const _AxumReferenceSchema(this.ref);

  final String ref;

  @override
  Map<String, Object?> toJson() => <String, Object?>{r'$ref': ref};
}

final class _AxumNullableSchema extends AxumSchema {
  const _AxumNullableSchema(this.inner);

  final AxumSchema inner;

  @override
  Map<String, Object?> toJson() {
    return {
      'anyOf': <Object?>[
        inner.toJson(),
        <String, Object?>{'type': 'null'},
      ],
    };
  }
}

final class AxumParameterDocs {
  const AxumParameterDocs.query(
    this.name, {
    required this.schema,
    this.description,
    this.required = false,
  }) : location = AxumParameterLocation.query;

  const AxumParameterDocs.header(
    this.name, {
    required this.schema,
    this.description,
    this.required = false,
  }) : location = AxumParameterLocation.header;

  const AxumParameterDocs.cookie(
    this.name, {
    required this.schema,
    this.description,
    this.required = false,
  }) : location = AxumParameterLocation.cookie;

  final String name;
  final AxumParameterLocation location;
  final AxumSchema schema;
  final String? description;
  final bool required;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'in': location.value,
      'required': required,
      'schema': schema.toJson(),
      if (description != null) 'description': description,
    };
  }
}

final class AxumResponseDocs {
  const AxumResponseDocs({
    required this.description,
    this.schema,
    this.contentType = 'application/json',
  });

  final String description;
  final AxumSchema? schema;
  final String contentType;

  Map<String, Object?> toJson() {
    final content = schema == null
        ? const <String, Object?>{}
        : <String, Object?>{
            contentType: <String, Object?>{'schema': schema!.toJson()},
          };
    return {'description': description, if (content.isNotEmpty) 'content': content};
  }
}

final class AxumRouteDocs {
  const AxumRouteDocs({
    this.summary,
    this.description,
    this.tags = const <String>[],
    this.operationId,
    this.parameters = const <AxumParameterDocs>[],
    this.responses = const <int, AxumResponseDocs>{},
  });

  final String? summary;
  final String? description;
  final List<String> tags;
  final String? operationId;
  final List<AxumParameterDocs> parameters;
  final Map<int, AxumResponseDocs> responses;
}

final class AxumOpenApiInfo {
  const AxumOpenApiInfo({required this.title, required this.version, this.description});

  final String title;
  final String version;
  final String? description;

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'version': version,
      if (description != null) 'description': description,
    };
  }
}

final class AxumOpenApiServer {
  const AxumOpenApiServer({required this.url, this.description});

  final String url;
  final String? description;

  Map<String, Object?> toJson() {
    return {'url': url, if (description != null) 'description': description};
  }
}

final class AxumOpenApi {
  const AxumOpenApi({
    required this.info,
    this.jsonPath = '/openapi.json',
    this.docsPath = '/docs',
    this.servers = const <AxumOpenApiServer>[],
  });

  final AxumOpenApiInfo info;
  final String jsonPath;
  final String? docsPath;
  final List<AxumOpenApiServer> servers;
}
