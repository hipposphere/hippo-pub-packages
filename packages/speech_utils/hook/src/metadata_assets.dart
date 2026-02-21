import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

import 'hook_helpers.dart';

const _appleAudioMetadataAssetName = 'src/metadata/generated/apple_audio_metadata_bindings.dart';
const _appleAudioMetadataBindingsSource = 'native/apple/speech_utils_apple_aac_codec_bindings.mm';
const _macosAudioMetadataLibraryBaseName = 'speech_utils_macos_audio_metadata';
const _iosAudioMetadataLibraryBaseName = 'speech_utils_ios_audio_metadata';
const _appleAudioMetadataSources = <String>[
  'native/apple/speech_utils_apple_aac_codec_bindings.mm',
  'native/apple/speech_utils_apple_aac_codec.mm',
];

Future<void> buildMacosAudioMetadataAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.macOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: _appleAudioMetadataBindingsSource,
    label: 'macOS audio metadata',
  );
  requireSourceFile(
    input,
    relativePath: 'native/apple/speech_utils_apple_aac_codec.mm',
    label: 'macOS audio metadata',
  );

  await CBuilder.library(
    name: _macosAudioMetadataLibraryBaseName,
    assetName: _appleAudioMetadataAssetName,
    language: Language.objectiveC,
    sources: _appleAudioMetadataSources,
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    defines: const {'SPEECH_UTILS_APPLE_AAC_TARGET_MACOS': '1'},
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}

Future<void> buildIosAudioMetadataAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.iOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: _appleAudioMetadataBindingsSource,
    label: 'iOS audio metadata',
  );
  requireSourceFile(
    input,
    relativePath: 'native/apple/speech_utils_apple_aac_codec.mm',
    label: 'iOS audio metadata',
  );

  await CBuilder.library(
    name: _iosAudioMetadataLibraryBaseName,
    assetName: _appleAudioMetadataAssetName,
    language: Language.objectiveC,
    sources: _appleAudioMetadataSources,
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    defines: const {'SPEECH_UTILS_APPLE_AAC_TARGET_IOS': '1'},
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}
