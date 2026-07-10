import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;

import 'hook_helpers.dart';

const _assetName = 'src/generated/wake_word/sherpa_onnx_bindings.dart';
const _runtimeAssetPrefix = 'src/generated/wake_word/sherpa_onnx_runtime';
const _libraryBaseName = 'speech_utils_sherpa_onnx';

Future<void> bundleSherpaOnnxAssets(BuildInput input, BuildOutputBuilder output) async {
  final sourceLibrary = _sourceLibrary(input);
  if (sourceLibrary == null) {
    return;
  }

  final sourceFile = requireSourceFile(
    input,
    relativePath: sourceLibrary,
    label: 'sherpa-onnx C API library',
    output: output,
  );
  final bundledName = input.config.code.targetOS.dylibFileName(_libraryBaseName);
  final bundledUri = input.outputDirectory.resolve('speech_utils/$bundledName');
  await _copyForTarget(input, sourceFile, File.fromUri(bundledUri));
  addBundledDynamicAsset(input: input, output: output, assetName: _assetName, fileUri: bundledUri);

  for (final runtimePath in _runtimeLibraries(input)) {
    final runtime = requireSourceFile(
      input,
      relativePath: runtimePath,
      label: 'sherpa-onnx runtime dependency',
      output: output,
    );
    final bundledRuntimeUri = input.outputDirectory.resolve(
      'speech_utils/${p.basename(runtime.path)}',
    );
    await _copyForTarget(input, runtime, File.fromUri(bundledRuntimeUri));
    addBundledDynamicAsset(
      input: input,
      output: output,
      assetName: '$_runtimeAssetPrefix/${_assetSafeName(p.basename(runtime.path))}.dart',
      fileUri: bundledRuntimeUri,
    );
  }
}

String? _sourceLibrary(BuildInput input) {
  final target = input.config.code;
  return switch ((target.targetOS, target.targetArchitecture)) {
    (OS.iOS, Architecture.arm64) when target.iOS.targetSdk == IOSSdk.iPhoneOS =>
      'third_party/sherpa_onnx/lib/ios/device/sherpa_onnx',
    (OS.iOS, Architecture.arm64) => 'third_party/sherpa_onnx/lib/ios/simulator/sherpa_onnx',
    (OS.iOS, Architecture.x64) => 'third_party/sherpa_onnx/lib/ios/simulator/sherpa_onnx',
    (OS.macOS, Architecture.arm64) ||
    (OS.macOS, Architecture.x64) => 'third_party/sherpa_onnx/lib/macos/libsherpa-onnx-c-api.dylib',
    (OS.linux, Architecture.x64) => 'third_party/sherpa_onnx/lib/linux/x64/libsherpa-onnx-c-api.so',
    (OS.linux, Architecture.arm64) =>
      'third_party/sherpa_onnx/lib/linux/arm64/libsherpa-onnx-c-api.so',
    (OS.windows, Architecture.x64) =>
      'third_party/sherpa_onnx/lib/windows/x64/sherpa-onnx-c-api.dll',
    (OS.android, Architecture.arm64) =>
      'third_party/sherpa_onnx/lib/android/arm64-v8a/libsherpa-onnx-c-api.so',
    (OS.android, Architecture.arm) =>
      'third_party/sherpa_onnx/lib/android/armeabi-v7a/libsherpa-onnx-c-api.so',
    (OS.android, Architecture.ia32) =>
      'third_party/sherpa_onnx/lib/android/x86/libsherpa-onnx-c-api.so',
    (OS.android, Architecture.x64) =>
      'third_party/sherpa_onnx/lib/android/x86_64/libsherpa-onnx-c-api.so',
    _ => null,
  };
}

List<String> _runtimeLibraries(BuildInput input) {
  final target = input.config.code;
  return switch ((target.targetOS, target.targetArchitecture)) {
    (OS.macOS, Architecture.arm64) || (OS.macOS, Architecture.x64) => const [
      'third_party/sherpa_onnx/lib/macos/libonnxruntime.1.27.0.dylib',
    ],
    (OS.linux, Architecture.x64) => const [
      'third_party/sherpa_onnx/lib/linux/x64/libonnxruntime.so',
    ],
    (OS.linux, Architecture.arm64) => const [
      'third_party/sherpa_onnx/lib/linux/arm64/libonnxruntime.so',
    ],
    (OS.windows, Architecture.x64) => const [
      'third_party/sherpa_onnx/lib/windows/x64/onnxruntime.dll',
      'third_party/sherpa_onnx/lib/windows/x64/onnxruntime_providers_shared.dll',
    ],
    (OS.android, Architecture.arm64) => const [
      'third_party/sherpa_onnx/lib/android/arm64-v8a/libonnxruntime.so',
    ],
    (OS.android, Architecture.arm) => const [
      'third_party/sherpa_onnx/lib/android/armeabi-v7a/libonnxruntime.so',
    ],
    (OS.android, Architecture.ia32) => const [
      'third_party/sherpa_onnx/lib/android/x86/libonnxruntime.so',
    ],
    (OS.android, Architecture.x64) => const [
      'third_party/sherpa_onnx/lib/android/x86_64/libonnxruntime.so',
    ],
    _ => const [],
  };
}

Future<void> _copyForTarget(BuildInput input, File source, File destination) async {
  if (input.config.code.targetOS != OS.iOS && input.config.code.targetOS != OS.macOS) {
    copyFile(source, destination);
    return;
  }

  destination.parent.createSync(recursive: true);
  final architecture = switch (input.config.code.targetArchitecture) {
    Architecture.arm64 => 'arm64',
    Architecture.x64 => 'x86_64',
    _ => throw UnsupportedError('Unsupported Apple architecture.'),
  };
  final result = await Process.run('lipo', [
    '-thin',
    architecture,
    source.path,
    '-output',
    destination.path,
  ]);
  if (result.exitCode != 0) {
    throw StateError('Failed to thin ${source.path} for $architecture: ${result.stderr}');
  }
}

String _assetSafeName(String fileName) => fileName.replaceAll(RegExp('[^A-Za-z0-9_-]'), '_');
