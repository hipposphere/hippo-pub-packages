// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// **************************************************************************
// DartEdgeHttpServerBuilderGenerator
// **************************************************************************

// ignore_for_file: unused_element, unused_field

final class _$AdminListUsersQuery implements JsonEncodable {
  const _$AdminListUsersQuery({
    this.limit,
    this.offset,
    this.searchField,
    this.searchValue,
    this.sortBy,
    this.sortDirection,
  });

  static const schemaId = "AdminListUsersQuery";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final int? limit;

  final int? offset;

  final String? searchField;

  final String? searchValue;

  final String? sortBy;

  final String? sortDirection;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "limit": limit,
    "offset": offset,
    "search_field": searchField,
    "search_value": searchValue,
    "sort_by": sortBy,
    "sort_direction": sortDirection,
  };

  static AdminListUsersQuery fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminListUsersQuery(
      limit: json["limit"] as int?,
      offset: json["offset"] as int?,
      searchField: json["search_field"] as String?,
      searchValue: json["search_value"] as String?,
      sortBy: json["sort_by"] as String?,
      sortDirection: json["sort_direction"] as String?,
    );
  }
}

final class _$AdminListUsersResponse implements JsonEncodable {
  const _$AdminListUsersResponse({
    required this.users,
    required this.total,
    required this.limit,
    required this.offset,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  static const schemaId = "AdminListUsersResponse";

  static const schemaRef = JsonSchema.ref(schemaId);

  static RequestBody get requestBody =>
      RequestBody.json(schema: schemaRef, decoder: fromJson);

  static ResponseSpec response({int status = 200}) =>
      ResponseSpec.json(status: status, schema: schemaRef);

  final List<AuthUserRow> users;

  final int total;

  final int limit;

  final int offset;

  final int page;

  final int pageSize;

  final int totalPages;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    "users": users.map((item) => item.toJson()).toList(),
    "total": total,
    "limit": limit,
    "offset": offset,
    "page": page,
    "page_size": pageSize,
    "total_pages": totalPages,
  };

  static AdminListUsersResponse fromJson(Object? value) {
    final json = value! as Map<String, Object?>;
    return AdminListUsersResponse(
      users: (json["users"]! as List<Object?>)
          .map(
            (item) => AuthUserRow.fromJson(
              Map<String, Object?>.from(item! as Map),
            ),
          )
          .toList(),
      total: json["total"]! as int,
      limit: json["limit"]! as int,
      offset: json["offset"]! as int,
      page: json["page"]! as int,
      pageSize: json["page_size"]! as int,
      totalPages: json["total_pages"]! as int,
    );
  }
}
