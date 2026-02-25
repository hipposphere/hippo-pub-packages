import 'package:hooks/hooks.dart';

import 'metadata_keys.dart';

/// Package name used for shared native dependency metadata.
const hippoNativeDepsPackageName = 'hippo_native_deps';

/// Reads required string metadata from [BuildInput.metadata].
String requireBuildMetadataString(
  BuildInput input, {
  required String packageName,
  required String metadataKey,
  String? label,
}) {
  final value = input.metadata[packageName][metadataKey];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  final effectiveLabel = label ?? 'metadata value';
  throw StateError(
    'Missing $effectiveLabel metadata "$metadataKey" from dependency "$packageName".',
  );
}

/// Reads required string metadata emitted by `hippo_native_deps`.
String requireNativeDepsMetadataString(
  BuildInput input, {
  required String metadataKey,
  String? label,
}) {
  return requireBuildMetadataString(
    input,
    packageName: hippoNativeDepsPackageName,
    metadataKey: metadataKey,
    label: label,
  );
}

/// Returns the include directory for RapidJSON.
String requireRapidjsonIncludeDir(BuildInput input) {
  return requireNativeDepsMetadataString(
    input,
    metadataKey: rapidjsonIncludeDirMetadataKey,
    label: 'RapidJSON include directory',
  );
}

/// Returns the include directory for WIL.
String requireWilIncludeDir(BuildInput input) {
  return requireNativeDepsMetadataString(
    input,
    metadataKey: wilIncludeDirMetadataKey,
    label: 'WIL include directory',
  );
}

/// Returns common include directories for Windows native builds.
List<String> requireNativeDepsWindowsIncludeDirs(
  BuildInput input, {
  bool includeRapidjson = true,
  bool includeWil = true,
}) {
  final includes = <String>[];
  if (includeRapidjson) {
    includes.add(requireRapidjsonIncludeDir(input));
  }
  if (includeWil) {
    includes.add(requireWilIncludeDir(input));
  }
  return includes;
}
