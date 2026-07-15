import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

import 'hook_helpers.dart';

const _appleAudioMetadataAssetName =
    'src/generated/metadata/apple_audio_metadata_bindings.dart';
const _macosAudioMetadataLibraryBaseName = 'speech_utils_macos_audio_metadata';
const _iosAudioMetadataLibraryBaseName = 'speech_utils_ios_audio_metadata';
const _iosAudioMetadataBindingsSource =
    'native/ios/speech_utils_native_audio_codec_bindings.mm';
const _iosAudioMetadataSources = <String>[
  'native/ios/speech_utils_native_audio_codec_bindings.mm',
  'native/ios/speech_utils_native_audio_codec.mm',
];
const _macosAudioMetadataBindingsSource =
    'native/macos/speech_utils_native_audio_codec_bindings.mm';
const _macosAudioMetadataSources = <String>[
  'native/macos/speech_utils_native_audio_codec_bindings.mm',
  'native/macos/speech_utils_native_audio_codec.mm',
];

Future<void> buildMacosAudioMetadataAsset(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  if (!matchesTarget(input, os: OS.macOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: _macosAudioMetadataBindingsSource,
    label: 'macOS audio metadata',
    output: output,
  );
  requireSourceFile(
    input,
    relativePath: 'native/macos/speech_utils_native_audio_codec.mm',
    label: 'macOS audio metadata',
    output: output,
  );

  await CBuilder.library(
    name: _macosAudioMetadataLibraryBaseName,
    assetName: _appleAudioMetadataAssetName,
    language: Language.objectiveC,
    sources: _macosAudioMetadataSources,
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}

Future<void> buildIosAudioMetadataAsset(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  if (!matchesTarget(input, os: OS.iOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: _iosAudioMetadataBindingsSource,
    label: 'iOS audio metadata',
    output: output,
  );
  requireSourceFile(
    input,
    relativePath: 'native/ios/speech_utils_native_audio_codec.mm',
    label: 'iOS audio metadata',
    output: output,
  );

  await CBuilder.library(
    name: _iosAudioMetadataLibraryBaseName,
    assetName: _appleAudioMetadataAssetName,
    language: Language.objectiveC,
    sources: _iosAudioMetadataSources,
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}
