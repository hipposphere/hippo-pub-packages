import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;

const windowsCommonCppFlags = <String>['/EHsc', '/O2'];
const windowsCommonDefines = <String, String>{
  'UNICODE': '1',
  '_UNICODE': '1',
  'WIN32_LEAN_AND_MEAN': '1',
  'NOMINMAX': '1',
};

const appleObjectiveCArcFlags = <String>['-fobjc-arc'];
const appleCommonFrameworks = <String>['Foundation', 'AVFoundation', 'CoreMedia', 'AudioToolbox'];
const appleCommonLibraries = <String>['c++'];

bool matchesTarget(BuildInput input, {required OS os, Architecture? arch}) {
  final target = input.config.code;
  return target.targetOS == os && (arch == null || target.targetArchitecture == arch);
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

void copyFile(File source, File destination) {
  destination.parent.createSync(recursive: true);
  source.copySync(destination.path);
}

void addFileDependency(BuildOutputBuilder output, File file) {
  output.dependencies.add(file.absolute.uri);
}

void addFileDependencies(BuildOutputBuilder output, Iterable<File> files) {
  for (final file in files) {
    output.dependencies.add(file.absolute.uri);
  }
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

String lowercaseFileName(File file) => p.basename(file.path).toLowerCase();
