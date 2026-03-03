import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import 'hook_helpers.dart';

const _tenVadAssetName = 'src/generated/vad/ten_vad_bindings.dart';
const _tenVadLibraryBaseName = 'speech_utils_ten_vad';

Future<void> bundleTenVadAsset(BuildInput input, BuildOutputBuilder output) async {
  final sourceLibrary = _tenVadSourceLibraryUri(input);
  if (sourceLibrary == null) {
    return;
  }

  final sourceFile = File.fromUri(sourceLibrary);
  if (!sourceFile.existsSync()) {
    throw StateError('Missing TEN VAD native library at ${sourceFile.path}.');
  }
  addFileDependency(output, sourceFile);

  final bundledFileName = input.config.code.targetOS.dylibFileName(_tenVadLibraryBaseName);
  final bundledLibrary = input.outputDirectory.resolve('speech_utils/$bundledFileName');

  final bundledFile = File.fromUri(bundledLibrary);
  await _copyLibraryForTarget(input: input, sourceFile: sourceFile, bundledFile: bundledFile);

  addBundledDynamicAsset(
    input: input,
    output: output,
    assetName: _tenVadAssetName,
    fileUri: bundledLibrary,
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
    if (input.config.code.iOS.targetSdk != IOSSdk.iPhoneOS) {
      return null;
    }
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

Future<void> _copyLibraryForTarget({
  required BuildInput input,
  required File sourceFile,
  required File bundledFile,
}) async {
  final os = input.config.code.targetOS;
  if (os != OS.macOS) {
    copyFile(sourceFile, bundledFile);
    return;
  }

  bundledFile.parent.createSync(recursive: true);
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
