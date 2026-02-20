import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const _macosAudioMetadataAssetName = 'src/metadata/generated/macos_audio_metadata_bindings.dart';
const _macosAudioMetadataLibraryBaseName = 'speech_utils_macos_audio_metadata';

Future<void> buildMacosAudioMetadataAsset(BuildInput input, BuildOutputBuilder output) async {
  final os = input.config.code.targetOS;
  if (os != OS.macOS) {
    return;
  }

  final source = File.fromUri(
    input.packageRoot.resolve('native/macos/speech_utils_macos_audio_metadata.mm'),
  );
  if (!source.existsSync()) {
    throw StateError('Missing macOS audio metadata source file at ${source.path}.');
  }

  await CBuilder.library(
    name: _macosAudioMetadataLibraryBaseName,
    assetName: _macosAudioMetadataAssetName,
    language: Language.objectiveC,
    sources: ['native/macos/speech_utils_macos_audio_metadata.mm'],
    std: 'c++17',
    flags: ['-fobjc-arc'],
    frameworks: ['Foundation', 'AVFoundation', 'CoreMedia', 'AudioToolbox'],
    libraries: ['c++'],
  ).run(input: input, output: output);
}
