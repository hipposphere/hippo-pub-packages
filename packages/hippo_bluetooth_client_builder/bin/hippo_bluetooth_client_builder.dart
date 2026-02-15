import 'dart:io';

import 'package:hippo_bluetooth_client_builder/hippo_bluetooth_client_builder.dart';

Future<void> main(List<String> args) async {
  try {
    await HippoBluetoothClientBuilderRunner().run(args);
    exitCode = 0;
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
