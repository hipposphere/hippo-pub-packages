import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const _tenVadAssetName = 'src/vad/generated/ten_vad_bindings.dart';
const _tenVadLibraryBaseName = 'speech_utils_ten_vad';
const _windowsAacAssetName = 'src/encoding/generated/windows_aac_bindings.dart';
const _windowsAacLibraryBaseName = 'speech_utils_windows_aac_encoder';
const _androidAacAssetName = 'src/encoding/generated/android_aac_bindings.dart';
const _androidAacLibraryBaseName = 'speech_utils_android_aac_encoder';
const _iosAacAssetName = 'src/encoding/generated/ios_aac_bindings.dart';
const _iosAacLibraryBaseName = 'speech_utils_ios_aac_encoder';
const _macosAudioMetadataAssetName = 'src/metadata/generated/macos_audio_metadata_bindings.dart';
const _macosAudioMetadataLibraryBaseName = 'speech_utils_macos_audio_metadata';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }

    await _maybeBundleTenVadAsset(input, output);
    await _maybeBuildWindowsAacEncoderAsset(input, output);
    await _maybeBuildAndroidAacEncoderAsset(input, output);
    await _maybeBuildIosAacEncoderAsset(input, output);
    await _maybeBuildMacosAudioMetadataAsset(input, output);
  });
}

Future<void> _maybeBundleTenVadAsset(BuildInput input, BuildOutputBuilder output) async {
  final sourceLibrary = _tenVadSourceLibraryUri(input);
  if (sourceLibrary == null) {
    return;
  }

  final sourceFile = File.fromUri(sourceLibrary);
  if (!sourceFile.existsSync()) {
    throw StateError('Missing TEN VAD native library at ${sourceFile.path}.');
  }

  final bundledFileName = input.config.code.targetOS.dylibFileName(_tenVadLibraryBaseName);
  final bundledLibrary = input.outputDirectoryShared.resolve('speech_utils/$bundledFileName');

  final bundledFile = File.fromUri(bundledLibrary);
  bundledFile.parent.createSync(recursive: true);
  await _copyLibraryForTarget(input: input, sourceFile: sourceFile, bundledFile: bundledFile);

  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: _tenVadAssetName,
      linkMode: DynamicLoadingBundled(),
      file: bundledLibrary,
    ),
  );
}

Uri? _tenVadSourceLibraryUri(BuildInput input) {
  final root = input.packageRoot;
  final os = input.config.code.targetOS;
  final arch = input.config.code.targetArchitecture;

  if (os == OS.windows) {
    return switch (arch) {
      Architecture.x64 => root.resolve('third_party/ten_vad/lib/windows/x64/ten_vad.dll'),
      _ => null,
    };
  }
  if (os == OS.android) {
    return switch (arch) {
      Architecture.arm64 => root.resolve('third_party/ten_vad/lib/android/arm64-v8a/libten_vad.so'),
      Architecture.arm => root.resolve('third_party/ten_vad/lib/android/armeabi-v7a/libten_vad.so'),
      _ => null,
    };
  }
  if (os == OS.iOS) {
    return switch (arch) {
      Architecture.arm64 => root.resolve('third_party/ten_vad/lib/ios/ten_vad.framework/ten_vad'),
      _ => null,
    };
  }
  if (os == OS.macOS) {
    return root.resolve('third_party/ten_vad/lib/macos/ten_vad');
  }
  return null;
}

Future<void> _maybeBuildWindowsAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
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

  await CBuilder.library(
    name: _windowsAacLibraryBaseName,
    assetName: _windowsAacAssetName,
    language: Language.cpp,
    sources: ['native/windows/speech_utils_windows_aac_encoder.cpp'],
    std: 'c++17',
    flags: ['/EHsc', '/O2'],
    defines: const {'UNICODE': '1', '_UNICODE': '1', 'WIN32_LEAN_AND_MEAN': '1', 'NOMINMAX': '1'},
    libraries: ['mfplat', 'mfreadwrite', 'mfuuid', 'mf', 'ole32'],
  ).run(input: input, output: output);
}

Future<void> _maybeBuildAndroidAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
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

Future<void> _maybeBuildIosAacEncoderAsset(BuildInput input, BuildOutputBuilder output) async {
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

Future<void> _maybeBuildMacosAudioMetadataAsset(BuildInput input, BuildOutputBuilder output) async {
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

Future<void> _copyLibraryForTarget({
  required BuildInput input,
  required File sourceFile,
  required File bundledFile,
}) async {
  final os = input.config.code.targetOS;
  if (os != OS.macOS) {
    sourceFile.copySync(bundledFile.path);
    return;
  }

  final thinArch = switch (input.config.code.targetArchitecture) {
    Architecture.arm64 => 'arm64',
    Architecture.x64 => 'x86_64',
    _ => throw UnsupportedError('Unsupported macOS target architecture.'),
  };

  final result = await Process.run('lipo', [
    '-thin',
    thinArch,
    sourceFile.path,
    '-output',
    bundledFile.path,
  ]);
  if (result.exitCode != 0) {
    throw StateError(
      'Failed to thin TEN VAD library for macOS ($thinArch): '
      '${result.stderr}',
    );
  }
}
