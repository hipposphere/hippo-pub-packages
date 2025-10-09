import 'package:postgres/postgres.dart';
import 'package:postgres_models_builder/src/models/database_column.dart';
import 'package:postgres_models_builder/src/models/database_enum.dart';
import 'package:postgres_models_builder/src/models/database_table.dart';
import 'package:postgres_models_builder/src/models/foreign_key_relation.dart';

import '../logger.dart';
import '../models/database_rpc.dart';
import '../models/database_rpc_argument.dart';

part 'parts/get_enums.dart';
part 'parts/get_tables.dart';
part 'parts/get_rpcs.dart';
part 'parts/get_foreign_key_relations.dart';

class PostgresReader {
  late final Connection _connection;

  late final bool ssl;
  late final String host;
  late final String databaseName;
  late final int port;
  late final String? username;
  late final String? password;
  final Duration timeout;
  final Duration queryTimeout;

  PostgresReader({
    required this.host,
    required this.databaseName,
    required this.port,
    this.username,
    this.password,
    this.timeout = const Duration(seconds: 30),
    this.queryTimeout = const Duration(seconds: 30),
    this.ssl = false,
  });

  PostgresReader.fromConnectionString(
    String connectionString, {
    bool sslEnabled = false,
    this.timeout = const Duration(seconds: 30),
    this.queryTimeout = const Duration(seconds: 30),
  }) {
    // expected format: postgresql://<username>:<password>@<host>:<port>/<database-name>
    connectionString = connectionString.trim();
    if (connectionString.startsWith('postgres://')) {
      connectionString = connectionString.replaceFirst('postgres://', 'postgresql://');
    }
    if (!connectionString.startsWith('postgresql://')) {
      throw FormatException(
        'The provided connection string does not start with `postgresql://`'
        '\nconnectionString = $connectionString',
      );
    }

    // from: postgresql://<username>:<password>@<host>:<port>/<database-name>
    // to:  <username>:<password>@<host>:<port>/<database-name>
    connectionString = connectionString.replaceAll('postgresql://', '');

    // from:   <username>:<password>@<host>:<port>/<database-name>
    // to:     ['username', 'password', 'host', 'port', 'databaseName']
    final parts = connectionString.split(RegExp(r':|@|\/'));

    if (connectionString.replaceFirst('@', '').contains('@')) {
      throw FormatException(
        'Looks like the `@` symbol is used in the password.\n'
        'replace it with: %40  -- the URL encoding for `@`',
      );
    }

    if (parts.length < 5) {
      throw FormatException(
        'Could not find all five required values:\n'
        'username, password, host, port, databaseName.\n'
        'make sure the connection string is formatted as follow:\n'
        'postgresql://<username>:<password>@<host>:<port>/<database-name>',
      );
    }

    if (int.tryParse(parts[3]) == null) {
      throw FormatException(
        'The port is not formatted correctly, expected an `integer` but got ${parts[3]}',
      );
    }

    /// assign fields:
    username = parts[0];
    password = parts[1];
    host = parts[2];
    port = int.parse(parts[3]);
    databaseName = parts[4];
    ssl = sslEnabled;
  }

  Future<List<ForeignKeyRelation>> getForeignKeyRelations({String schemaName = 'public'}) {
    return _getForeignKeyRelations(schemaName: schemaName, query: query);
  }

  Future<List<DatabaseTable>> getTables({
    String schemaName = 'public',
    List<String>? tableNames,
    List<String>? omitTableNames,
    List<ForeignKeyRelation>? foreignKeyRelations,
  }) {
    return _getTables(
      schemaName: schemaName,
      query: query,
      tableNames: tableNames,
      omitTableNames: omitTableNames,
      foreignKeyRelations: foreignKeyRelations,
    );
  }

  Future<List<DatabaseRpc>> getRpcs({
    String schemaName = 'public',
    List<String>? omitRpcNames,
    List<DatabaseEnum> enums = const [],
  }) {
    return _getRpcs(schemaName: schemaName, query: query, omitRpcNames: omitRpcNames, enums: enums);
  }

  Future<List<DatabaseEnum>> getEnums({String schemaName = 'public'}) {
    return _getEnums(query: query, schemaName: schemaName);
  }

  Future<void> connect() async {
    _connection = await Connection.open(
      Endpoint(
        host: host,
        database: databaseName,
        port: port,
        username: username,
        password: password,
      ),
      settings: ConnectionSettings(
        connectTimeout: timeout,
        queryTimeout: queryTimeout,
        sslMode: ssl ? SslMode.require : SslMode.disable,
      ),
    );
  }

  /// Retrieve the postgres type for all columns
  ///
  /// The [schemaName] defaults to `public`.
  /// Provide [tableNames] to retrieve data for specific tables only,
  /// an empty list (default) indicates all tables.

  /// Returns one flat map per row: {columnName: value}
  Future<List<Map<String, dynamic>>> query(String rawQuery) async {
    final result = await _connection.execute(rawQuery);
    final cols = result.schema.columns; // ResultSchemaColumn list

    return result.map((row) {
      final m = <String, dynamic>{};
      for (var i = 0; i < cols.length; i++) {
        // columnName may be null for expressions; use an auto name if so
        final name = cols[i].columnName ?? 'column_$i';
        m[name] = row[i];
      }
      return m;
    }).toList();
  }

  Future<void> disconnect() async {
    await _connection.close();
  }
}
