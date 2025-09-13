// ignore_for_file: prefer_interpolation_to_compose_strings

part of '../postgres_reader.dart';

Future<List<DatabaseRpc>> _getRpcs({
  String schemaName = 'public',
  required dynamic Function(String sqlCommand) query,
  List<DatabaseEnum> enums = const [],
  List<String>? omitRpcNames,
}) async {
  final rawQuery = buildRpcTypesQuery(schemaName: schemaName);

  Log.trace('executing the following query:\n$rawQuery');

  final res = await query(rawQuery);

  // for some reason the table key is empty.
  // result coming like this: `{: {table_name: some_name, column_name: some_name, udt_name: text, is_nullable: NO}}`

  final rpcs = <DatabaseRpc>[];

  List<String> uniqueFunctionNames = [];

  String getUniqueFunctionName(String functionName) {
    if (!uniqueFunctionNames.contains(functionName)) {
      uniqueFunctionNames.add(functionName);
      return functionName;
    }
    final newName =
        '${functionName}_${uniqueFunctionNames.where((e) => e == functionName).length}';
    uniqueFunctionNames.add(newName);
    return newName;
  }

  for (final rawResult in res) {
    final functionName = rawResult['pg_proc'][FunctionColumnNames.functionName]
        .toString()
        .replaceAll(' ', '_');

    final result = rawResult[''];

    Log.trace('reading rpc: $functionName');
    if (omitRpcNames?.contains(functionName) ?? false) {
      // print('Skipping rpc $functionName');
      continue;
    }

    // get column data
    final returnType = result?[FunctionColumnNames.returnType];
    final String arguments = result?[FunctionColumnNames.arguments];

    final splittedArguments = arguments
        .split(',')
        .map((e) => e.trim())
        .toList();

    final rpcData = DatabaseRpc(
      uniqueFunctionName: getUniqueFunctionName(functionName),
      functionName: functionName,
      returnType: returnType,
      arguments: splittedArguments.where((element) => element != '').map((e) {
        // This splits the argument into its name and type like for example
        // for "user_id uuid" it would split into ["user_id", "uuid"] but it can also
        // be "given_product_id character varying" so we need to split only on the first space
        final split = e.split(' ');
        final argumentName = split[0];
        final udtType = split.sublist(1).join(' ');

        return DatabaseRpcArgument(
          argumentName: argumentName,
          udtType: split.sublist(1).join(' '),
          enumType: enums
              .where((element) => element.enumType == udtType)
              .firstOrNull,
        );
      }).toList(),
    );
    rpcs.add(rpcData);
  }

  return rpcs;
}

String buildRpcTypesQuery({required String schemaName}) {
  String rawQuery =
      '''
SELECT
    p.proname AS function_name,
    pg_catalog.pg_get_function_result(p.oid) AS return_type,
    pg_catalog.pg_get_function_arguments(p.oid) AS arguments,
    CASE
        WHEN p.prokind = 'a' THEN 'agg'
        WHEN p.prokind = 'w' THEN 'window'
        WHEN p.prorettype = 'pg_catalog.trigger'::pg_catalog.regtype THEN 'trigger'
        ELSE 'normal'
    END AS function_type,
    d.description
FROM
    pg_catalog.pg_proc p
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    LEFT JOIN pg_catalog.pg_description d ON p.oid = d.objoid
WHERE
    n.nspname = '$schemaName'  -- Adjust schema name as necessary
    AND p.prorettype <> 'pg_catalog.trigger'::pg_catalog.regtype
    AND p.prokind IN ('f', 'p')  -- f for normal functions, p for procedures
ORDER BY
    function_name;
''';

  return rawQuery;
}

/// a simple representation of a table

/// Returns a String represneting a dart type from a [postgresType]
/// (i.e. `udt_name` from `information_schema.columns`)
//  double check the types
//       The following was based on: https://github.com/SweetIQ/schemats/blob/master/src/schemaPostgres.ts

class FunctionColumnNames {
  static const functionName = 'function_name';
  static const returnType = 'return_type';
  static const arguments = 'arguments';

  static const all = [functionName, returnType, arguments];
}
