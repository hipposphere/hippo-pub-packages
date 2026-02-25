import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hippo_native_deps/hippo_native_deps.dart';
import 'package:hooks/hooks.dart';

const _rapidJsonIncludeRelativePath = 'third_party/rapidjson/include';
const _rapidJsonVersionRelativePath = 'third_party/rapidjson/VERSION';
const _rapidJsonMarkerHeaderRelativePath = 'rapidjson/document.h';

const _wilIncludeRelativePath = 'third_party/wil/include';
const _wilVersionRelativePath = 'third_party/wil/VERSION';
const _wilMarkerHeaderRelativePath = 'wil/resource.h';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    _publishHeaderOnlyDependency(
      input: input,
      output: output,
      includeRelativePath: _rapidJsonIncludeRelativePath,
      versionRelativePath: _rapidJsonVersionRelativePath,
      markerHeaderRelativePath: _rapidJsonMarkerHeaderRelativePath,
      dependencyLabel: 'RapidJSON',
      fetchCommand: 'bash tool/fetch_rapidjson.sh',
      includeMetadataKey: rapidjsonIncludeDirMetadataKey,
      versionMetadataKey: rapidjsonVersionMetadataKey,
    );
    _publishHeaderOnlyDependency(
      input: input,
      output: output,
      includeRelativePath: _wilIncludeRelativePath,
      versionRelativePath: _wilVersionRelativePath,
      markerHeaderRelativePath: _wilMarkerHeaderRelativePath,
      dependencyLabel: 'WIL',
      fetchCommand: 'bash tool/fetch_wil.sh',
      includeMetadataKey: wilIncludeDirMetadataKey,
      versionMetadataKey: wilVersionMetadataKey,
    );
  });
}

void _publishHeaderOnlyDependency({
  required BuildInput input,
  required BuildOutputBuilder output,
  required String includeRelativePath,
  required String versionRelativePath,
  required String markerHeaderRelativePath,
  required String dependencyLabel,
  required String fetchCommand,
  required String includeMetadataKey,
  required String versionMetadataKey,
}) {
  final packageRoot = Directory.fromUri(input.packageRoot);
  final includeDir = Directory.fromUri(
    input.packageRoot.resolve(includeRelativePath),
  );
  if (!includeDir.existsSync()) {
    throw StateError(
      '$dependencyLabel include directory missing at ${includeDir.path}. '
      'Run "$fetchCommand" in ${packageRoot.path}.',
    );
  }

  final markerHeader = File.fromUri(
    includeDir.uri.resolve(markerHeaderRelativePath),
  );
  if (!markerHeader.existsSync()) {
    throw StateError(
      '$dependencyLabel marker header missing at ${markerHeader.path}. '
      'Expected $markerHeaderRelativePath.',
    );
  }

  final versionFile = File.fromUri(
    input.packageRoot.resolve(versionRelativePath),
  );
  final version = versionFile.existsSync()
      ? versionFile.readAsStringSync().trim()
      : 'unknown';

  output.metadata[includeMetadataKey] = includeDir.absolute.path;
  output.metadata[versionMetadataKey] = version;
  output.dependencies.addAll([
    for (final entity in includeDir.listSync(
      recursive: true,
      followLinks: false,
    ))
      if (entity is File) entity.absolute.uri,
    if (versionFile.existsSync()) versionFile.absolute.uri,
  ]);
}
