import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

import 'hook_helpers.dart';

const _windowsAudioRecorderAssetName =
    'src/recording/generated/windows_audio_recorder_bindings.dart';
const _windowsAudioRecorderLibraryBaseName = 'speech_utils_windows_audio_recorder';
const _windowsAudioRecorderSources = <String>[
  'native/windows/speech_utils_windows_audio_recorder.cpp',
  'native/windows/recorder/windows_audio_recorder_api.cpp',
  'native/windows/recorder/miniaudio_implementation.cpp',
];
const _iosAudioRecorderAssetName = 'src/recording/generated/ios_audio_recorder_bindings.dart';
const _iosAudioRecorderLibraryBaseName = 'speech_utils_ios_audio_recorder';
const _macosAudioRecorderAssetName = 'src/recording/generated/macos_audio_recorder_bindings.dart';
const _macosAudioRecorderLibraryBaseName = 'speech_utils_macos_audio_recorder';

Future<void> buildWindowsAudioRecorderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.windows, arch: Architecture.x64)) {
    return;
  }

  for (final source in _windowsAudioRecorderSources) {
    requireSourceFile(input, relativePath: source, label: 'Windows audio recorder');
  }

  await CBuilder.library(
    name: _windowsAudioRecorderLibraryBaseName,
    assetName: _windowsAudioRecorderAssetName,
    language: Language.cpp,
    sources: _windowsAudioRecorderSources,
    std: 'c++17',
    flags: windowsCommonCppFlags,
    defines: windowsCommonDefines,
    libraries: ['ole32', 'avrt', 'winmm', 'uuid'],
  ).run(input: input, output: output);
}

Future<void> buildIosAudioRecorderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.iOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: 'native/apple/speech_utils_apple_audio_recorder.mm',
    label: 'iOS audio recorder',
  );

  requireSourceFile(
    input,
    relativePath: 'native/apple/recorder/speech_utils_apple_audio_recorder_impl.mm',
    label: 'iOS audio recorder',
  );

  await CBuilder.library(
    name: _iosAudioRecorderLibraryBaseName,
    assetName: _iosAudioRecorderAssetName,
    language: Language.objectiveC,
    sources: [
      'native/apple/speech_utils_apple_audio_recorder.mm',
      'native/apple/recorder/speech_utils_apple_audio_recorder_impl.mm',
    ],
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    defines: const {'SPEECH_UTILS_AUDIO_RECORDER_TARGET_IOS': '1'},
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}

Future<void> buildMacosAudioRecorderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.macOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: 'native/apple/speech_utils_apple_audio_recorder.mm',
    label: 'macOS audio recorder',
  );

  requireSourceFile(
    input,
    relativePath: 'native/apple/recorder/speech_utils_apple_audio_recorder_impl.mm',
    label: 'macOS audio recorder',
  );

  await CBuilder.library(
    name: _macosAudioRecorderLibraryBaseName,
    assetName: _macosAudioRecorderAssetName,
    language: Language.objectiveC,
    sources: [
      'native/apple/speech_utils_apple_audio_recorder.mm',
      'native/apple/recorder/speech_utils_apple_audio_recorder_impl.mm',
    ],
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    defines: const {'SPEECH_UTILS_AUDIO_RECORDER_TARGET_MACOS': '1'},
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}
