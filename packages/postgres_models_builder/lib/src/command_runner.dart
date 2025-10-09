import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:postgres_models_builder/src/schema_converter.dart';
import 'package:postgres_models_builder/src/version.dart';

import 'logger.dart';

class PostgresModelsBuilderRunner extends CommandRunner<void> {
  PostgresModelsBuilderRunner() : super('postgres-models-builder', '') {
    argParser.addOption(
      'connection-string',
      abbr: 'c',
      // mandatory: true,
      help:
          'PostgreSQL connection string in the following format:\n'
          'postgresql://<username>:<password>@<host>:<port>/<database-name>',
    );

    argParser.addOption(
      'output-dir',
      abbr: 'o',
      // mandatory: true,
      help: 'The output directory for the generated dart files',
    );

    argParser.addOption('ssl', defaultsTo: 'false', help: 'Enable SSL connection (true/false)');

    argParser.addOption('schema', abbr: 's', defaultsTo: 'public', help: 'specify the schema');

    argParser.addMultiOption(
      'tables',
      abbr: 't',
      valueHelp: 'String',
      help:
          'provide a specific list of tables to generate data classes for.\n'
          '(defaults to all tables)',
    );

    argParser.addMultiOption(
      'omit-tables',
      valueHelp: 'String',
      help:
          'provide a specific list of tables which should be omitted.\n'
          '(defaults to none)',
    );

    argParser.addFlag('verbose', abbr: 'v', negatable: false, help: 'Enable verbose logging.');

    argParser.addFlag('version', negatable: false, help: 'Print the current version.');
  }

  @override
  String get description => '''Generate Data Classes for PostgreSQL schema
  
Examples: 

  # generate data classes for public schema (default)
  schema-dart -c postgresql://postgres:postgres@localhost:54322/postgres -o path/to/output/directory

  # generate for data classes for a "cms" schema 
  schema-dart -c <connection-string> -o <output-dir> -s cms

  # generate data classes for specific tables from public schema (format sensitive): 
  schema-dart -c <connection-string> -o <output-dir> -t "users","posts"
  # or
  schema-dart -c <connection-string> -o <output-dir> --schema=api --tables="profiles","posts"
  ''';

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      // ignore: avoid_print
      Log.stdout(schemaDartVersion);
      return;
    }

    if (topLevelResults['verbose'] == true) {
      Log.verbose = true;
    }

    if (topLevelResults['help'] != false) {
      return super.runCommand(topLevelResults);
    }

    if (topLevelResults['connection-string'] == null) {
      throw Exception('connection-string is required');
    }

    // if (topLevelResults['output-dir'] == null) {
    //   throw Exception('output-dir is required');
    // }

    final connectionString = topLevelResults['connection-string'] as String;
    final outputDirectory = Directory(topLevelResults['output-dir'] as String);

    // if (!outputDirectory.existsSync()) {
    //   throw Exception('The given output directory does not exist: ${outputDirectory.path}');
    // }

    final schema = topLevelResults['schema'] as String;

    final listOfTables = topLevelResults['tables'];
    final omitTables = topLevelResults['omit-tables'];
    final sslEnabled = (topLevelResults['ssl'] as String).toLowerCase() == 'true';

    final converter = SchemaConverter(
      connectionString: connectionString,
      outputDirectory: outputDirectory,
      schemaList: schema.contains(',') ? schema.split(',') : [schema],
      tableNames: listOfTables,
      omitTableNames: omitTables,
      sslEnabled: sslEnabled,
    );

    await converter.convert();
  }
}
