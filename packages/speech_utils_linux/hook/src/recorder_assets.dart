import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hippo_native_deps/hippo_native_deps.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:path/path.dart' as p;

import 'hook_helpers.dart';
import 'windows_webrtc_apm_pipeline.dart';

const _windowsAudioRecorderAssetName =
    'src/generated/recorder/windows_audio_recorder_bindings.dart';
const _windowsAudioRecorderLibraryBaseName =
    'speech_utils_windows_audio_recorder';
const _windowsWebRtcRuntimeAssetNamePrefix =
    'src/generated/recorder/windows_webrtc_runtime';
const _linuxAudioRecorderAssetName =
    'src/generated/linux_audio_recorder_bindings.dart';
const _linuxAudioRecorderLibraryBaseName = 'speech_utils_linux_audio_recorder';
const _windowsAudioRecorderSources = <String>[
  'native/windows/speech_utils_windows_audio_recorder.cpp',
  'native/windows/recorder/windows_audio_recorder_api.cpp',
  'native/windows/recorder/windows_webrtc_audio_processing.cpp',
  'native/windows/recorder/miniaudio_implementation.cpp',
];
const _linuxAudioRecorderSources = <String>[
  'native/linux/speech_utils_linux_audio_recorder.cpp',
  'native/linux/recorder/linux_audio_recorder_api.cpp',
  'native/linux/recorder/miniaudio_implementation.cpp',
];
const _iosAudioRecorderAssetName =
    'src/generated/recorder/ios_audio_recorder_bindings.dart';
const _iosAudioRecorderLibraryBaseName = 'speech_utils_ios_audio_recorder';
const _macosAudioRecorderAssetName =
    'src/generated/recorder/macos_audio_recorder_bindings.dart';
const _macosAudioRecorderLibraryBaseName = 'speech_utils_macos_audio_recorder';
const _iosAudioRecorderSources = <String>[
  'native/ios/speech_utils_native_audio_recorder_impl.mm',
  'native/ios/speech_utils_ios_audio_recorder_session.mm',
  'native/ios/speech_utils_native_audio_recorder_wav.mm',
  'native/ios/speech_utils_native_audio_codec.mm',
  'native/ios/speech_utils_ios_audio_recorder.mm',
];
const _macosAudioRecorderSources = <String>[
  'native/macos/speech_utils_native_audio_recorder_impl.mm',
  'native/macos/speech_utils_native_audio_recorder_wav.mm',
  'native/macos/speech_utils_native_audio_codec.mm',
  'native/macos/speech_utils_macos_audio_recorder.mm',
];

Future<void> buildWindowsAudioRecorderAsset(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  if (!matchesTarget(input, os: OS.windows, arch: Architecture.x64)) {
    return;
  }

  for (final source in _windowsAudioRecorderSources) {
    requireSourceFile(
      input,
      relativePath: source,
      label: 'Windows audio recorder',
      output: output,
    );
  }
  final nativeDepsIncludes = requireNativeDepsWindowsIncludeDirs(input);
  final webrtcSdk = requireVendoredWindowsWebRtcApmSdk(input, output: output);

  final windowsDefines = Map<String, String>.from(windowsCommonDefines);
  final windowsLibraries = <String>['ole32', 'avrt', 'winmm', 'uuid'];
  final windowsIncludes = <String>[...nativeDepsIncludes];
  final windowsLibraryDirectories = <String>[];
  final webrtcIncludeRoot = p.join(webrtcSdk.rootDir.path, 'include');
  windowsIncludes.add(webrtcIncludeRoot);
  windowsIncludes.add(webrtcSdk.includeDir.path);
  windowsLibraries.insertAll(0, webrtcSdk.libraries);
  windowsLibraryDirectories.addAll(webrtcSdk.importLibDirectories);

  await CBuilder.library(
    name: _windowsAudioRecorderLibraryBaseName,
    assetName: _windowsAudioRecorderAssetName,
    language: Language.cpp,
    sources: _windowsAudioRecorderSources,
    includes: windowsIncludes,
    std: 'c++17',
    flags: windowsCommonCppFlags,
    defines: windowsDefines,
    libraries: windowsLibraries,
    libraryDirectories: windowsLibraryDirectories,
  ).run(input: input, output: output);

  _copyWindowsRuntimeDllsNextToRecorderLibrary(
    input: input,
    runtimeDlls: webrtcSdk.runtimeDlls,
  );
  _bundleWindowsWebRtcRuntimeDlls(
    input: input,
    output: output,
    runtimeDlls: webrtcSdk.runtimeDlls,
  );
}

Future<void> buildLinuxAudioRecorderAsset(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  if (!matchesTarget(input, os: OS.linux)) {
    return;
  }

  for (final source in _linuxAudioRecorderSources) {
    requireSourceFile(
      input,
      relativePath: source,
      label: 'Linux audio recorder',
      output: output,
    );
  }

  await CBuilder.library(
    name: _linuxAudioRecorderLibraryBaseName,
    assetName: _linuxAudioRecorderAssetName,
    language: Language.cpp,
    sources: _linuxAudioRecorderSources,
    includes: ['native/include', requireRapidjsonIncludeDir(input)],
    std: 'c++17',
    flags: const <String>['-O2', '-pthread'],
    libraries: const <String>['pthread', 'dl', 'm'],
  ).run(input: input, output: output);
}

Future<void> buildIosAudioRecorderAsset(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  if (!matchesTarget(input, os: OS.iOS)) {
    return;
  }

  for (final source in _iosAudioRecorderSources) {
    requireSourceFile(
      input,
      relativePath: source,
      label: 'iOS audio recorder',
      output: output,
    );
  }

  await CBuilder.library(
    name: _iosAudioRecorderLibraryBaseName,
    assetName: _iosAudioRecorderAssetName,
    language: Language.objectiveC,
    sources: _iosAudioRecorderSources,
    includes: ['native/include'],
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}

Future<void> buildMacosAudioRecorderAsset(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  if (!matchesTarget(input, os: OS.macOS)) {
    return;
  }

  for (final source in _macosAudioRecorderSources) {
    requireSourceFile(
      input,
      relativePath: source,
      label: 'macOS audio recorder',
      output: output,
    );
  }

  await CBuilder.library(
    name: _macosAudioRecorderLibraryBaseName,
    assetName: _macosAudioRecorderAssetName,
    language: Language.objectiveC,
    sources: _macosAudioRecorderSources,
    includes: ['native/include'],
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}

void _copyWindowsRuntimeDllsNextToRecorderLibrary({
  required BuildInput input,
  required List<File> runtimeDlls,
}) {
  final sharedOutputDir = Directory.fromUri(input.outputDirectoryShared);
  if (!sharedOutputDir.existsSync()) {
    return;
  }

  final recorderFileName = input.config.code.targetOS.dylibFileName(
    _windowsAudioRecorderLibraryBaseName,
  );
  final builtRecorderLibraries = sharedOutputDir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where(
        (file) => lowercaseFileName(file) == recorderFileName.toLowerCase(),
      )
      .toList(growable: false);

  for (final recorderLibrary in builtRecorderLibraries) {
    final targetDir = recorderLibrary.parent;
    for (final sourceDll in runtimeDlls) {
      final fileName = p.basename(sourceDll.path);
      final destination = File(p.join(targetDir.path, fileName));
      copyFile(sourceDll, destination);
    }
  }
}

void _bundleWindowsWebRtcRuntimeDlls({
  required BuildInput input,
  required BuildOutputBuilder output,
  required List<File> runtimeDlls,
}) {
  for (final sourceDll in runtimeDlls) {
    final fileName = p.basename(sourceDll.path);
    final bundledLibrary = input.outputDirectoryShared.resolve(
      'speech_utils/$fileName',
    );
    final bundledFile = File.fromUri(bundledLibrary);
    copyFile(sourceDll, bundledFile);

    final assetBaseName = p.basenameWithoutExtension(fileName);
    addBundledDynamicAsset(
      input: input,
      output: output,
      assetName:
          '$_windowsWebRtcRuntimeAssetNamePrefix/${assetBaseName}_bindings.dart',
      fileUri: bundledLibrary,
    );
  }
}
