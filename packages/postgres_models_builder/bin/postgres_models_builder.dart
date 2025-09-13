import 'dart:io';

import 'package:postgres_models_builder/postgres_models_builder.dart';

void main(List<String> args) async {
  try {
    await PostgresModelsBuilderRunner().run(args);
    exitCode = 0;
  } catch (e) {
    print(e);
    exitCode = 1;
  }
}
