import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

import 'hook_helpers.dart';

const _macosAudioMetadataAssetName = 'src/metadata/generated/macos_audio_metadata_bindings.dart';
const _macosAudioMetadataLibraryBaseName = 'speech_utils_macos_audio_metadata';

Future<void> buildMacosAudioMetadataAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.macOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: 'native/macos/speech_utils_macos_audio_metadata.mm',
    label: 'macOS audio metadata',
  );

  await CBuilder.library(
    name: _macosAudioMetadataLibraryBaseName,
    assetName: _macosAudioMetadataAssetName,
    language: Language.objectiveC,
    sources: ['native/macos/speech_utils_macos_audio_metadata.mm'],
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}
