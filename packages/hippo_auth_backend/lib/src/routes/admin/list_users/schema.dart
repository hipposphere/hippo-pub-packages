import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:hippobase_auth_models/hippobase_auth_models.dart';

part 'schema.g.dart';

const adminListUsersQuerySchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'limit': JsonSchema.integer(),
    'offset': JsonSchema.integer(),
    'search_field': JsonSchema.string(),
    'search_value': JsonSchema.string(),
    'sort_by': JsonSchema.string(),
    'sort_direction': JsonSchema.string(),
  },
  additionalProperties: false,
);

const adminListUsersResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'users': JsonSchema.array(items: AuthUserRow.schemaRef),
    'total': JsonSchema.integer(),
    'limit': JsonSchema.integer(),
    'offset': JsonSchema.integer(),
    'page': JsonSchema.integer(),
    'page_size': JsonSchema.integer(),
    'total_pages': JsonSchema.integer(),
  },
  required: <String>['users', 'total', 'limit', 'offset', 'page', 'page_size', 'total_pages'],
  additionalProperties: false,
);

const adminListUsersRouteResponseSchema = JsonSchema.object(
  properties: <String, JsonSchema>{
    'users': JsonSchema.array(items: AuthUserRow.jsonSchema),
    'total': JsonSchema.integer(),
    'limit': JsonSchema.integer(),
    'offset': JsonSchema.integer(),
    'page': JsonSchema.integer(),
    'page_size': JsonSchema.integer(),
    'total_pages': JsonSchema.integer(),
  },
  required: <String>['users', 'total', 'limit', 'offset', 'page', 'page_size', 'total_pages'],
  additionalProperties: false,
);

const adminListUsersRouteSchemas = JsonSchemaRegistry(
  schemas: <JsonSchema>[
    AuthUserRow.jsonSchema,
    adminListUsersQuerySchema,
    adminListUsersResponseSchema,
  ],
);

@FromSchema(adminListUsersQuerySchema, registry: adminListUsersRouteSchemas)
typedef AdminListUsersQuery = _$AdminListUsersQuery;

@FromSchema(
  adminListUsersResponseSchema,
  registry: adminListUsersRouteSchemas,
  refs: [SchemaRefModel(AuthUserRow)],
)
typedef AdminListUsersResponse = _$AdminListUsersResponse;

final adminListUsersRouteOptions = RouteOptions(
  operationId: 'getV1AdminListUsers',
  summary: 'List users as an administrator.',
  query: adminListUsersQuerySchema,
  success: ResponseSpec.json(schema: adminListUsersRouteResponseSchema),
  errors: const <ErrorResponse>[
    ErrorResponse(status: 401, code: 'Unauthorized'),
    ErrorResponse(status: 403, code: 'Forbidden'),
    ErrorResponse(status: 500, code: 'AdminListUsersFailed'),
    ErrorResponse(status: 501, code: 'AdminDisabled'),
  ],
);
