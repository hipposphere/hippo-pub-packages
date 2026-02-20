import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:path/path.dart' as p;

import 'windows_ffmpeg_pipeline.dart';

const _windowsAacAssetName = 'src/encoding/generated/windows_aac_bindings.dart';
const _windowsAacLibraryBaseName = 'speech_utils_windows_aac_encoder';
const _windowsFfmpegRuntimeAssetNamePrefix = 'src/encoding/generated/windows_ffmpeg_runtime';
const _windowsFfmpegRequiredEnv = 'SPEECH_UTILS_WINDOWS_FFMPEG_REQUIRED';
const _androidAacAssetName = 'src/encoding/generated/android_aac_bindings.dart';
const _androidAacLibraryBaseName = 'speech_utils_android_aac_encoder';
const _iosAacAssetName = 'src/encoding/generated/ios_aac_bindings.dart';
const _iosAacLibraryBaseName = 'speech_utils_ios_aac_encoder';
const _macosAacAssetName = 'src/encoding/generated/macos_aac_bindings.dart';
const _macosAacLibraryBaseName = 'speech_utils_macos_aac_encoder';

Future<void> buildWindowsAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  final os = input.config.code.targetOS;
  final arch = input.config.code.targetArchitecture;
  if (os != OS.windows || arch != Architecture.x64) {
    return;
  }

  final source = File.fromUri(
    input.packageRoot.resolve('native/windows/speech_utils_windows_aac_encoder.cpp'),
  );
  if (!source.existsSync()) {
    throw StateError('Missing Windows AAC encoder source file at ${source.path}.');
  }

  final WindowsFfmpegSdk ffmpegSdk;
  try {
    ffmpegSdk = await ensureWindowsFfmpegSdk(input);
  } on MissingWindowsFfmpegSdkException catch (error) {
    if (_isTruthy(Platform.environment[_windowsFfmpegRequiredEnv])) {
      rethrow;
    }
    stderr.writeln(
      'speech_utils: Skipping Windows native AAC/metadata asset build '
      'because FFmpeg SDK is not configured.',
    );
    stderr.writeln('speech_utils: $error');
    stderr.writeln(
      'speech_utils: Set $_windowsFfmpegRequiredEnv=1 to fail the build '
      'when FFmpeg is missing.',
    );
    return;
  }
  final runtimeDlls = collectWindowsFfmpegRuntimeDlls(ffmpegSdk);

  await CBuilder.library(
    name: _windowsAacLibraryBaseName,
    assetName: _windowsAacAssetName,
    language: Language.cpp,
    sources: ['native/windows/speech_utils_windows_aac_encoder.cpp'],
    includes: [ffmpegSdk.includeDir.path],
    std: 'c++17',
    flags: ['/EHsc', '/O2'],
    defines: const {'UNICODE': '1', '_UNICODE': '1', 'WIN32_LEAN_AND_MEAN': '1', 'NOMINMAX': '1'},
    libraries: ['avformat', 'avcodec', 'avutil', 'swresample', 'bcrypt', 'ws2_32', 'secur32'],
    libraryDirectories: [ffmpegSdk.libDir.path],
  ).run(input: input, output: output);

  _bundleWindowsFfmpegRuntimeDlls(input: input, output: output, runtimeDlls: runtimeDlls);
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
    bundledFile.parent.createSync(recursive: true);
    sourceDll.copySync(bundledFile.path);

    final assetBaseName = p.basenameWithoutExtension(fileName);
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: '$_windowsFfmpegRuntimeAssetNamePrefix/${assetBaseName}_bindings.dart',
        linkMode: DynamicLoadingBundled(),
        file: bundledLibrary,
      ),
    );
  }
}

Future<void> buildAndroidAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  final os = input.config.code.targetOS;
  if (os != OS.android) {
    return;
  }

  final source = File.fromUri(
    input.packageRoot.resolve('native/android/speech_utils_android_aac_encoder.cpp'),
  );
  if (!source.existsSync()) {
    throw StateError('Missing Android AAC encoder source file at ${source.path}.');
  }

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

bool _isTruthy(String? value) {
  if (value == null) {
    return false;
  }
  final normalized = value.trim().toLowerCase();
  return normalized == '1' || normalized == 'true' || normalized == 'yes' || normalized == 'on';
}

Future<void> buildIosAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  final os = input.config.code.targetOS;
  if (os != OS.iOS) {
    return;
  }

  final source = File.fromUri(
    input.packageRoot.resolve('native/ios/speech_utils_ios_aac_encoder.mm'),
  );
  if (!source.existsSync()) {
    throw StateError('Missing iOS AAC encoder source file at ${source.path}.');
  }

  await CBuilder.library(
    name: _iosAacLibraryBaseName,
    assetName: _iosAacAssetName,
    language: Language.objectiveC,
    sources: ['native/ios/speech_utils_ios_aac_encoder.mm'],
    std: 'c++17',
    flags: ['-fobjc-arc'],
    frameworks: ['Foundation', 'AVFoundation', 'CoreMedia', 'AudioToolbox'],
    libraries: ['c++'],
  ).run(input: input, output: output);
}

Future<void> buildMacosAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
  final os = input.config.code.targetOS;
  if (os != OS.macOS) {
    return;
  }

  final source = File.fromUri(
    input.packageRoot.resolve('native/macos/speech_utils_macos_aac_encoder.mm'),
  );
  if (!source.existsSync()) {
    throw StateError('Missing macOS AAC encoder source file at ${source.path}.');
  }

  await CBuilder.library(
    name: _macosAacLibraryBaseName,
    assetName: _macosAacAssetName,
    language: Language.objectiveC,
    sources: ['native/macos/speech_utils_macos_aac_encoder.mm'],
    std: 'c++17',
    flags: ['-fobjc-arc'],
    frameworks: ['Foundation', 'AVFoundation', 'CoreMedia', 'AudioToolbox'],
    libraries: ['c++'],
  ).run(input: input, output: output);
}
