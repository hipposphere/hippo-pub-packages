import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:path/path.dart' as p;

import 'hook_helpers.dart';
import 'windows_ffmpeg_pipeline.dart';

const _windowsAudioEncoderAssetName =
    'src/generated/audio_encoder/windows_audio_encoder_bindings.dart';
const _windowsAudioEncoderLibraryBaseName = 'speech_utils_windows_audio_encoder';
const _windowsFfmpegRuntimeAssetNamePrefix = 'src/generated/audio_encoder/windows_ffmpeg_runtime';
const _windowsAudioEncoderSources = <String>[
  'native/windows/speech_utils_windows_audio_encoder.cpp',
  'native/windows/encoding/windows_ffmpeg_common.cpp',
  'native/windows/encoding/windows_audio_encoder_transcoder.cpp',
  'native/windows/encoding/windows_audio_metadata.cpp',
];
const _androidAudioEncoderAssetName =
    'src/generated/audio_encoder/android_audio_encoder_bindings.dart';
const _androidAudioEncoderLibraryBaseName = 'speech_utils_android_audio_encoder';
const _androidCxxRuntimeAssetName = 'src/generated/audio_encoder/android_cxx_runtime_bindings.dart';
const _appleAudioEncoderAssetName = 'src/generated/audio_encoder/apple_audio_encoder_bindings.dart';
const _iosAudioCodecBindingsSource = 'native/ios/speech_utils_native_audio_codec_bindings.mm';
const _iosAudioCodecSources = <String>[
  'native/ios/speech_utils_native_audio_codec_bindings.mm',
  'native/ios/speech_utils_native_audio_codec.mm',
];
const _macosAudioCodecBindingsSource = 'native/macos/speech_utils_native_audio_codec_bindings.mm';
const _macosAudioCodecSources = <String>[
  'native/macos/speech_utils_native_audio_codec_bindings.mm',
  'native/macos/speech_utils_native_audio_codec.mm',
];
const _iosAudioEncoderLibraryBaseName = 'speech_utils_ios_audio_encoder';
const _macosAudioEncoderLibraryBaseName = 'speech_utils_macos_audio_encoder';

String _androidTargetTripleForArchitecture(Architecture architecture) {
  return switch (architecture) {
    Architecture.arm => 'armv7a-linux-androideabi',
    Architecture.arm64 => 'aarch64-linux-android',
    Architecture.ia32 => 'i686-linux-android',
    Architecture.x64 => 'x86_64-linux-android',
    Architecture.riscv64 => 'riscv64-linux-android',
    _ => throw UnsupportedError(
      'Unsupported Android architecture for audio encoder: $architecture',
    ),
  };
}

String _androidLibcxxRuntimeTripleForArchitecture(Architecture architecture) {
  return switch (architecture) {
    Architecture.arm => 'arm-linux-androideabi',
    Architecture.arm64 => 'aarch64-linux-android',
    Architecture.ia32 => 'i686-linux-android',
    Architecture.x64 => 'x86_64-linux-android',
    Architecture.riscv64 => 'riscv64-linux-android',
    _ => throw UnsupportedError(
      'Unsupported Android architecture for libc++ runtime: $architecture',
    ),
  };
}

File _resolveAndroidLibcxxSharedRuntime(BuildInput input) {
  final cCompiler = input.config.code.cCompiler;
  if (cCompiler == null) {
    throw StateError('Missing C compiler configuration for Android build.');
  }

  final compilerFile = File.fromUri(cCompiler.compiler);
  final prebuiltDir = compilerFile.parent.parent;
  final runtimeTriple = _androidLibcxxRuntimeTripleForArchitecture(
    input.config.code.targetArchitecture,
  );
  final runtimeFile = File(
    p.join(prebuiltDir.path, 'sysroot', 'usr', 'lib', runtimeTriple, 'libc++_shared.so'),
  );
  if (!runtimeFile.existsSync()) {
    throw StateError('Missing Android libc++ runtime at ${runtimeFile.path}.');
  }
  return runtimeFile;
}

void _bundleAndroidLibcxxSharedRuntime({
  required BuildInput input,
  required BuildOutputBuilder output,
}) {
  final runtimeSource = _resolveAndroidLibcxxSharedRuntime(input);
  addFileDependency(output, runtimeSource);
  final bundledRuntimeUri = input.outputDirectory.resolve('speech_utils/libc++_shared.so');
  final bundledRuntimeFile = File.fromUri(bundledRuntimeUri);
  copyFile(runtimeSource, bundledRuntimeFile);
  addBundledDynamicAsset(
    input: input,
    output: output,
    assetName: _androidCxxRuntimeAssetName,
    fileUri: bundledRuntimeUri,
  );
}

Future<void> buildWindowsAudioEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.windows, arch: Architecture.x64)) {
    return;
  }

  for (final source in _windowsAudioEncoderSources) {
    requireSourceFile(input, relativePath: source, label: 'Windows audio encoder', output: output);
  }

  final ffmpegSdk = await loadWindowsFfmpegSdk(input, output: output);
  final runtimeDlls = ffmpegSdk.runtimeDlls;
  final importLibDirectories = ffmpegSdk.importLibDirectories
      .map((directory) => directory.path)
      .toList(growable: false);

  await CBuilder.library(
    name: _windowsAudioEncoderLibraryBaseName,
    assetName: _windowsAudioEncoderAssetName,
    language: Language.cpp,
    sources: _windowsAudioEncoderSources,
    includes: [ffmpegSdk.includeDir.path],
    std: 'c++17',
    flags: windowsCommonCppFlags,
    defines: windowsCommonDefines,
    libraries: ['avformat', 'avcodec', 'avutil', 'swresample', 'bcrypt', 'ws2_32', 'secur32'],
    libraryDirectories: importLibDirectories,
  ).run(input: input, output: output);

  _copyWindowsRuntimeDllsNextToAudioEncoderLibrary(input: input, runtimeDlls: runtimeDlls);
  _bundleWindowsFfmpegRuntimeDlls(input: input, output: output, runtimeDlls: runtimeDlls);
}

void _copyWindowsRuntimeDllsNextToAudioEncoderLibrary({
  required BuildInput input,
  required List<File> runtimeDlls,
}) {
  final sharedOutputDir = Directory.fromUri(input.outputDirectoryShared);
  if (!sharedOutputDir.existsSync()) {
    return;
  }

  final audioEncoderFileName = input.config.code.targetOS.dylibFileName(
    _windowsAudioEncoderLibraryBaseName,
  );
  final builtAudioEncoderLibraries = sharedOutputDir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => lowercaseFileName(file) == audioEncoderFileName.toLowerCase())
      .toList(growable: false);

  for (final audioEncoderLibrary in builtAudioEncoderLibraries) {
    final targetDir = audioEncoderLibrary.parent;
    for (final sourceDll in runtimeDlls) {
      final fileName = p.basename(sourceDll.path);
      final destination = File(p.join(targetDir.path, fileName));
      copyFile(sourceDll, destination);
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
    copyFile(sourceDll, bundledFile);

    final assetBaseName = p.basenameWithoutExtension(fileName);
    addBundledDynamicAsset(
      input: input,
      output: output,
      assetName: '$_windowsFfmpegRuntimeAssetNamePrefix/${assetBaseName}_bindings.dart',
      fileUri: bundledLibrary,
    );
  }
}

Future<void> buildAndroidAudioEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.android)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: 'native/android/speech_utils_android_audio_encoder.cpp',
    label: 'Android audio encoder',
    output: output,
  );

  final targetNdkApi = input.config.code.android.targetNdkApi;
  final effectiveNdkApi = targetNdkApi < 26 ? 26 : targetNdkApi;
  final androidTargetTriple = _androidTargetTripleForArchitecture(
    input.config.code.targetArchitecture,
  );
  await CBuilder.library(
    name: _androidAudioEncoderLibraryBaseName,
    assetName: _androidAudioEncoderAssetName,
    language: Language.cpp,
    sources: ['native/android/speech_utils_android_audio_encoder.cpp'],
    cppLinkStdLib: 'c++_shared',
    std: 'c++17',
    flags: ['-O2', '--target=$androidTargetTriple$effectiveNdkApi'],
    libraries: ['android', 'mediandk', 'log'],
  ).run(input: input, output: output);

  _bundleAndroidLibcxxSharedRuntime(input: input, output: output);
}

Future<void> buildIosAudioEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.iOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: _iosAudioCodecBindingsSource,
    label: 'iOS audio encoder',
    output: output,
  );
  requireSourceFile(
    input,
    relativePath: 'native/ios/speech_utils_native_audio_codec.mm',
    label: 'iOS audio encoder',
    output: output,
  );

  await CBuilder.library(
    name: _iosAudioEncoderLibraryBaseName,
    assetName: _appleAudioEncoderAssetName,
    language: Language.objectiveC,
    sources: _iosAudioCodecSources,
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}

Future<void> buildMacosAudioEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  if (!matchesTarget(input, os: OS.macOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: _macosAudioCodecBindingsSource,
    label: 'macOS audio encoder',
    output: output,
  );
  requireSourceFile(
    input,
    relativePath: 'native/macos/speech_utils_native_audio_codec.mm',
    label: 'macOS audio encoder',
    output: output,
  );

  await CBuilder.library(
    name: _macosAudioEncoderLibraryBaseName,
    assetName: _appleAudioEncoderAssetName,
    language: Language.objectiveC,
    sources: _macosAudioCodecSources,
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    frameworks: appleCommonFrameworks,
    libraries: appleCommonLibraries,
  ).run(input: input, output: output);
}
