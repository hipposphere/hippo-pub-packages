import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

const windowsCommonCppFlags = <String>['/EHsc', '/O2'];
const windowsCommonDefines = <String, String>{
  'UNICODE': '1',
  '_UNICODE': '1',
  'WIN32_LEAN_AND_MEAN': '1',
  'NOMINMAX': '1',
};

const appleObjectiveCArcFlags = <String>['-fobjc-arc'];
const appleFrameworks = <String>['Foundation', 'ApplicationServices', 'Cocoa'];
const appleLibraries = <String>['c++'];

bool matchesTarget(BuildInput input, {required OS os, Architecture? arch}) {
  final target = input.config.code;
  return target.targetOS == os &&
      (arch == null || target.targetArchitecture == arch);
}

File requireSourceFile(
  BuildInput input, {
  required String relativePath,
  required String label,
  BuildOutputBuilder? output,
}) {
  final file = File.fromUri(input.packageRoot.resolve(relativePath));
  if (!file.existsSync()) {
    throw StateError('Missing $label source file at ${file.path}.');
  }
  if (output != null) {
    output.dependencies.add(file.absolute.uri);
  }
  return file;
}

void addBundledDynamicAsset({
  required BuildInput input,
  required BuildOutputBuilder output,
  required String assetName,
  required Uri fileUri,
}) {
  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: assetName,
      linkMode: DynamicLoadingBundled(),
      file: fileUri,
    ),
  );
}
