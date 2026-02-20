import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const _windowsAudioRecorderAssetName =
    'src/recording/generated/windows_audio_recorder_bindings.dart';
const _windowsAudioRecorderLibraryBaseName = 'speech_utils_windows_audio_recorder';
const _iosAudioRecorderAssetName = 'src/recording/generated/ios_audio_recorder_bindings.dart';
const _iosAudioRecorderLibraryBaseName = 'speech_utils_ios_audio_recorder';
const _macosAudioRecorderAssetName = 'src/recording/generated/macos_audio_recorder_bindings.dart';
const _macosAudioRecorderLibraryBaseName = 'speech_utils_macos_audio_recorder';

Future<void> buildWindowsAudioRecorderAsset(BuildInput input, BuildOutputBuilder output) async {
  final os = input.config.code.targetOS;
  final arch = input.config.code.targetArchitecture;
  if (os != OS.windows || arch != Architecture.x64) {
    return;
  }

  final source = File.fromUri(
    input.packageRoot.resolve('native/windows/speech_utils_windows_audio_recorder.cpp'),
  );
  if (!source.existsSync()) {
    throw StateError('Missing Windows audio recorder source file at ${source.path}.');
  }

  await CBuilder.library(
    name: _windowsAudioRecorderLibraryBaseName,
    assetName: _windowsAudioRecorderAssetName,
    language: Language.cpp,
    sources: ['native/windows/speech_utils_windows_audio_recorder.cpp'],
    std: 'c++17',
    flags: ['/EHsc', '/O2'],
    defines: const {'UNICODE': '1', '_UNICODE': '1', 'WIN32_LEAN_AND_MEAN': '1', 'NOMINMAX': '1'},
    libraries: ['ole32', 'avrt', 'winmm', 'uuid'],
  ).run(input: input, output: output);
}

Future<void> buildIosAudioRecorderAsset(BuildInput input, BuildOutputBuilder output) async {
  final os = input.config.code.targetOS;
  if (os != OS.iOS) {
    return;
  }

  final source = File.fromUri(
    input.packageRoot.resolve('native/apple/speech_utils_apple_audio_recorder.mm'),
  );
  if (!source.existsSync()) {
    throw StateError('Missing iOS audio recorder source file at ${source.path}.');
  }

  await CBuilder.library(
    name: _iosAudioRecorderLibraryBaseName,
    assetName: _iosAudioRecorderAssetName,
    language: Language.objectiveC,
    sources: ['native/apple/speech_utils_apple_audio_recorder.mm'],
    std: 'c++17',
    flags: ['-fobjc-arc'],
    defines: const {'SPEECH_UTILS_AUDIO_RECORDER_TARGET_IOS': '1'},
    frameworks: ['Foundation', 'AVFoundation', 'CoreMedia', 'AudioToolbox'],
    libraries: ['c++'],
  ).run(input: input, output: output);
}

Future<void> buildMacosAudioRecorderAsset(BuildInput input, BuildOutputBuilder output) async {
  final os = input.config.code.targetOS;
  if (os != OS.macOS) {
    return;
  }

  final source = File.fromUri(
    input.packageRoot.resolve('native/apple/speech_utils_apple_audio_recorder.mm'),
  );
  if (!source.existsSync()) {
    throw StateError('Missing macOS audio recorder source file at ${source.path}.');
  }

  await CBuilder.library(
    name: _macosAudioRecorderLibraryBaseName,
    assetName: _macosAudioRecorderAssetName,
    language: Language.objectiveC,
    sources: ['native/apple/speech_utils_apple_audio_recorder.mm'],
    std: 'c++17',
    flags: ['-fobjc-arc'],
    defines: const {'SPEECH_UTILS_AUDIO_RECORDER_TARGET_MACOS': '1'},
    frameworks: ['Foundation', 'AVFoundation', 'CoreMedia', 'AudioToolbox'],
    libraries: ['c++'],
  ).run(input: input, output: output);
}
