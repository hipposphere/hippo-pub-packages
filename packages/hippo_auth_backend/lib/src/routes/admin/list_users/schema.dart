import 'package:dart_edge_auth/dart_edge_auth.dart';
import 'package:dart_edge_core/dart_edge_core.dart';
import 'package:dart_edge_http_server_codegen/dart_edge_http_server_codegen.dart';

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
    'users': JsonSchema.array(items: JsonSchema.ref('#/components/schemas/DartEdgeAuthUser')),
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
    'users': JsonSchema.array(items: DartEdgeAuthUser.jsonSchema),
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
    DartEdgeAuthUser.jsonSchema,
    adminListUsersQuerySchema,
    adminListUsersResponseSchema,
  ],
);

@FromSchema(adminListUsersQuerySchema, registry: adminListUsersRouteSchemas)
typedef AdminListUsersQuery = _$AdminListUsersQuery;

@FromSchema(
  adminListUsersResponseSchema,
  registry: adminListUsersRouteSchemas,
  refs: [SchemaRefModel(DartEdgeAuthUser)],
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
