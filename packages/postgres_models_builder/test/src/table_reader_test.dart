import 'package:postgres_models_builder/src/postgres_reader/postgres_reader.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

const _connectionString =
    'postgresql://some_user-name:pass123word456@db.fwoqzpwqgJgrqak.supabase.co:54322/postgres';
const _dbName = 'postgres';
const _host = 'db.fwoqzpwqgJgrqak.supabase.co';
const _port = 54322;
const _username = 'some_user-name';
const _password = 'pass123word456';
// the '@' symbol should be replaced with `%40`
const _invalidConnectionString = 'postgresql://postgres:pass@word@localhost:54322/postgres';

void main() {
  group('postgres_reader.dart', () {
    group('PostgresReader.fromConnectionString', () {
      test('- correct string ', () {
        final reader = PostgresReader.fromConnectionString(_connectionString);

        expect(reader.databaseName, _dbName);
        expect(reader.host, _host);
        expect(reader.port, _port);
        expect(reader.username, _username);
        expect(reader.password, _password);
      });

      test('- invalid string (password contains @ symbol)', () {
        expect(
          () => PostgresReader.fromConnectionString(_invalidConnectionString),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('- PostgresReader.getTables', () {
      test('- all tables', () async {
        final tableReader = TableReaderMock(_connectionString);
        final tables = await tableReader.getTables();
        expect(tables.length, tablesForTest.length);
      });

      test('filtered tables', () async {
        final tableReader = TableReaderMock(_connectionString);
        final subTables = tablesForTest.sublist(0, 2);
        final tables = await tableReader.getTables(tableNames: tablesForTest.sublist(0, 2));

        expect(tables.length, subTables.length);
        expect(tables[0].tableName, subTables[0]);
        expect(tables[1].tableName, subTables[1]);
      });
    });
  });
}

/* -------------------------------------------------------------------------- */
/*                                    MOCKS                                   */
/* -------------------------------------------------------------------------- */
// This only mocks one method `query`. The rest of the class is intact.
class TableReaderMock extends PostgresReader {
  TableReaderMock(super.connectionString) : super.fromConnectionString();

  @override
  Future<List<Map<String, Map<String, dynamic>>>> query(String rawQuery) async {
    if (_includedTables.isNotEmpty) {
      final filteredColumns = [...columnDataForTest];
      filteredColumns.removeWhere(
        (element) => !_includedTables.contains(element['']?['table_name']),
      );
      return filteredColumns;
    }
    return columnDataForTest;
  }

  final _includedTables = <String>[];
}

/* -------------------------------------------------------------------------- */
/*                                  test data                                 */
/* -------------------------------------------------------------------------- */
const tablesForTest = [
  'audit_log_entries',
  'identities',
  'instances',
  'refresh_tokens',
  'schema_migrations',
  'users',
];

final numberOfTestColumns = columnDataForTest.length;

// The following data are the auth schema tables/columns from supabase
// for some reason PostgreSQLConnection returns the first map with empty keys
const columnDataForTest = <Map<String, Map<String, dynamic>>>[
  {
    '': {
      'table_name': 'audit_log_entries',
      'column_name': 'instance_id',
      'udt_name': 'uuid',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'audit_log_entries',
      'column_name': 'created_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'audit_log_entries',
      'column_name': 'id',
      'udt_name': 'uuid',
      'is_nullable': 'NO',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'identities',
      'column_name': 'provider',
      'udt_name': 'text',
      'is_nullable': 'NO',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'identities',
      'column_name': 'identity_data',
      'udt_name': 'jsonb',
      'is_nullable': 'NO',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'identities',
      'column_name': 'last_sign_in_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'identities',
      'column_name': 'id',
      'udt_name': 'text',
      'is_nullable': 'NO',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'identities',
      'column_name': 'created_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'identities',
      'column_name': 'updated_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'identities',
      'column_name': 'user_id',
      'udt_name': 'uuid',
      'is_nullable': 'NO',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'instances',
      'column_name': 'updated_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'instances',
      'column_name': 'id',
      'udt_name': 'uuid',
      'is_nullable': 'NO',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'instances',
      'column_name': 'uuid',
      'udt_name': 'uuid',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'instances',
      'column_name': 'raw_base_config',
      'udt_name': 'text',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'instances',
      'column_name': 'created_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'refresh_tokens',
      'column_name': 'instance_id',
      'udt_name': 'uuid',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'refresh_tokens',
      'column_name': 'user_id',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'refresh_tokens',
      'column_name': 'id',
      'udt_name': 'int8',
      'is_nullable': 'NO',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'refresh_tokens',
      'column_name': 'created_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'refresh_tokens',
      'column_name': 'revoked',
      'udt_name': 'bool',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'refresh_tokens',
      'column_name': 'updated_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'refresh_tokens',
      'column_name': 'parent',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'refresh_tokens',
      'column_name': 'token',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'schema_migrations',
      'column_name': 'version',
      'udt_name': 'varchar',
      'is_nullable': 'NO',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'phone',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'phone_change',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'phone_change_token',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'email_change_token_current',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'email_change_token_new',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'is_super_admin',
      'udt_name': 'bool',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'created_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'updated_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'phone_confirmed_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'phone_change_sent_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'confirmed_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'email_change_confirm_status',
      'udt_name': 'int2',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'instance_id',
      'udt_name': 'uuid',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'id',
      'udt_name': 'uuid',
      'is_nullable': 'NO',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'email_confirmed_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'invited_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'confirmation_sent_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'recovery_sent_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'email_change_sent_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'last_sign_in_at',
      'udt_name': 'timestamptz',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'raw_app_meta_data',
      'udt_name': 'jsonb',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'aud',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'role',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'email',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'encrypted_password',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'confirmation_token',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'recovery_token',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'raw_user_meta_data',
      'udt_name': 'jsonb',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
  {
    '': {
      'table_name': 'users',
      'column_name': 'email_change',
      'udt_name': 'varchar',
      'is_nullable': 'YES',
      'columnDefault': null,
      'ordinal_position': 0,
    },
  },
];
