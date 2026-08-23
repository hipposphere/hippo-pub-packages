import 'package:dart_http_core/dart_http_core.dart';

import 'dart:math' as math;

import '../../../models/auth_user.dart';
import '../../shared/route_context.dart';
import '../../shared/route_definition.dart';
import '../../shared/route_utils.dart';
import 'schema.dart';

final class AdminListUsersRoute<TServices> extends HippoAuthJsonRoute<TServices> {
  AdminListUsersRoute(this.context)
    : super(error: const HippoAuthRouteError('AdminListUsersFailed', 'Failed to list users.'));

  final HippoAuthRouteContext context;

  @override
  RouteOptions get options => adminListUsersRouteOptions;

  @override
  Future<Object?> handleJson(RequestContext<TServices> ctx) async {
    context.ensureAdminEnabled();
    final query = ctx.req.queryMap;
    final limit = readIntQuery(query, 'limit', min: 1, max: 200) ?? 20;
    final offset = readIntQuery(query, 'offset', min: 0) ?? 0;
    final response = await context
        .adminApi(ctx)
        .listUsers(
          limit: limit,
          offset: offset,
          searchField: query['search_field'],
          searchValue: query['search_value'],
          sortBy: query['sort_by'],
          sortDirection: query['sort_direction'],
        );
    final resolvedLimit = response.limit == 0 ? limit : response.limit;
    final resolvedOffset = response.offset;
    final total = math.max(0, response.total);
    final totalPages = math.max(1, (total / resolvedLimit).ceil());
    return AdminListUsersResponse(
      users: response.users.map(hippobaseAuthUser).toList(growable: false),
      total: total,
      limit: resolvedLimit,
      offset: resolvedOffset,
      page: math.min(totalPages, (resolvedOffset / resolvedLimit).floor() + 1),
      pageSize: resolvedLimit,
      totalPages: totalPages,
    );
  }
}
