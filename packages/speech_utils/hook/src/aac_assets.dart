import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:path/path.dart' as p;

import 'hook_helpers.dart';
import 'windows_ffmpeg_pipeline.dart';

const _windowsAacAssetName = 'src/encoding/generated/windows_aac_bindings.dart';
const _windowsAacLibraryBaseName = 'speech_utils_windows_aac_encoder';
const _windowsFfmpegRuntimeAssetNamePrefix = 'src/encoding/generated/windows_ffmpeg_runtime';
const _windowsAacSources = <String>[
  'native/windows/speech_utils_windows_aac_encoder.cpp',
  'native/windows/encoding/windows_ffmpeg_common.cpp',
  'native/windows/encoding/windows_aac_transcoder.cpp',
  'native/windows/encoding/windows_audio_metadata.cpp',
];
const _androidAacAssetName = 'src/encoding/generated/android_aac_bindings.dart';
const _androidAacLibraryBaseName = 'speech_utils_android_aac_encoder';
const _appleAacAssetName = 'src/encoding/generated/apple_aac_bindings.dart';
const _appleAacBindingsSource = 'native/apple/speech_utils_apple_aac_codec_bindings.mm';
const _appleAacSharedSources = <String>[
  'native/apple/speech_utils_apple_aac_codec_bindings.mm',
  'native/apple/speech_utils_apple_aac_codec.mm',
];
const _iosAacLibraryBaseName = 'speech_utils_ios_aac_encoder';
const _macosAacLibraryBaseName = 'speech_utils_macos_aac_encoder';

Future<void> buildWindowsAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.windows, arch: Architecture.x64)) {
    return;
  }

  for (final source in _windowsAacSources) {
    requireSourceFile(input, relativePath: source, label: 'Windows AAC encoder');
  }

  final ffmpegSdk = await loadWindowsFfmpegSdk(input);
  final runtimeDlls = ffmpegSdk.runtimeDlls;
  final importLibDirectories = ffmpegSdk.importLibDirectories
      .map((directory) => directory.path)
      .toList(growable: false);

  await CBuilder.library(
    name: _windowsAacLibraryBaseName,
    assetName: _windowsAacAssetName,
    language: Language.cpp,
    sources: _windowsAacSources,
    includes: [ffmpegSdk.includeDir.path],
    std: 'c++17',
    flags: windowsCommonCppFlags,
    defines: windowsCommonDefines,
    libraries: ['avformat', 'avcodec', 'avutil', 'swresample', 'bcrypt', 'ws2_32', 'secur32'],
    libraryDirectories: importLibDirectories,
  ).run(input: input, output: output);

  _copyWindowsRuntimeDllsNextToAacLibrary(input: input, runtimeDlls: runtimeDlls);
  _bundleWindowsFfmpegRuntimeDlls(input: input, output: output, runtimeDlls: runtimeDlls);
}

void _copyWindowsRuntimeDllsNextToAacLibrary({
  required BuildInput input,
  required List<File> runtimeDlls,
}) {
  final sharedOutputDir = Directory.fromUri(input.outputDirectoryShared);
  if (!sharedOutputDir.existsSync()) {
    return;
  }

  final aacFileName = input.config.code.targetOS.dylibFileName(_windowsAacLibraryBaseName);
  final builtAacLibraries = sharedOutputDir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => lowercaseFileName(file) == aacFileName.toLowerCase())
      .toList(growable: false);

  for (final aacLibrary in builtAacLibraries) {
    final targetDir = aacLibrary.parent;
    for (final sourceDll in runtimeDlls) {
      final fileName = p.basename(sourceDll.path);
      final destination = File(p.join(targetDir.path, fileName));
      copyIfMissing(sourceDll, destination);
    }
  }
}

void _bundleWindowsFfmpegRuntimeDlls({
  required BuildInput input,
  required BuildOutputBuilder output,
  required List<File> runtimeDlls,
}) {
  for (final sourceDll in runtimeDlls) {
    final fileName = p.basename(sourceDll.path);
    final bundledLibrary = input.outputDirectoryShared.resolve('speech_utils/$fileName');
    final bundledFile = File.fromUri(bundledLibrary);
    copyIfMissing(sourceDll, bundledFile);

    final assetBaseName = p.basenameWithoutExtension(fileName);
    addBundledDynamicAsset(
      input: input,
      output: output,
      assetName: '$_windowsFfmpegRuntimeAssetNamePrefix/${assetBaseName}_bindings.dart',
      fileUri: bundledLibrary,
    );
  }
}

Future<void> buildAndroidAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.android)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: 'native/android/speech_utils_android_aac_encoder.cpp',
    label: 'Android AAC encoder',
  );

  final targetNdkApi = input.config.code.android.targetNdkApi;
  final effectiveNdkApi = targetNdkApi < 26 ? 26 : targetNdkApi;
  await CBuilder.library(
    name: _androidAacLibraryBaseName,
    assetName: _androidAacAssetName,
    language: Language.cpp,
    sources: ['native/android/speech_utils_android_aac_encoder.cpp'],
    std: 'c++17',
    flags: ['-O2'],
    defines: {'__ANDROID_API__': '$effectiveNdkApi'},
    libraries: ['android', 'mediandk', 'log'],
  ).run(input: input, output: output);
}

Future<void> buildIosAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.iOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: _appleAacBindingsSource,
    label: 'iOS AAC encoder',
  );
  requireSourceFile(
    input,
    relativePath: 'native/apple/speech_utils_apple_aac_codec.mm',
    label: 'iOS AAC encoder',
  );

  await CBuilder.library(
    name: _iosAacLibraryBaseName,
    assetName: _appleAacAssetName,
    language: Language.objectiveC,
    sources: _appleAacSharedSources,
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    defines: const {'SPEECH_UTILS_APPLE_AAC_TARGET_IOS': '1'},
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}

Future<void> buildMacosAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.macOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: _appleAacBindingsSource,
    label: 'macOS AAC encoder',
  );
  requireSourceFile(
    input,
    relativePath: 'native/apple/speech_utils_apple_aac_codec.mm',
    label: 'macOS AAC encoder',
  );

  await CBuilder.library(
    name: _macosAacLibraryBaseName,
    assetName: _appleAacAssetName,
    language: Language.objectiveC,
    sources: _appleAacSharedSources,
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    defines: const {'SPEECH_UTILS_APPLE_AAC_TARGET_MACOS': '1'},
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}
