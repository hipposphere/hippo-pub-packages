import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

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

  final bundledFileName = input.config.code.targetOS.dylibFileName(_windowsAacLibraryBaseName);
  final bundledLibrary = input.outputDirectoryShared.resolve('speech_utils/$bundledFileName');
  final bundledFile = File.fromUri(bundledLibrary);
  bundledFile.parent.createSync(recursive: true);

  await _buildWindowsAacEncoderDll(input: input, sourceFile: source, bundledDll: bundledFile);

  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: _windowsAacAssetName,
      linkMode: DynamicLoadingBundled(),
      file: bundledLibrary,
    ),
  );
}

Future<void> _buildWindowsAacEncoderDll({
  required BuildInput input,
  required File sourceFile,
  required File bundledDll,
}) async {
  final clArgs = <String>[
    '/nologo',
    '/std:c++17',
    '/EHsc',
    '/O2',
    '/LD',
    '/DUNICODE',
    '/D_UNICODE',
    '/DWIN32_LEAN_AND_MEAN',
    '/DNOMINMAX',
    sourceFile.path,
    '/link',
    '/NOLOGO',
    '/OUT:${bundledDll.path}',
    'mfplat.lib',
    'mfreadwrite.lib',
    'mfuuid.lib',
    'mf.lib',
    'ole32.lib',
  ];

  final setupScript = _resolveVisualStudioSetupScript(input);
  final setupScriptExists = setupScript != null && File(setupScript.path).existsSync();
  ProcessResult? setupCompileResult;
  ProcessResult? configuredCompilerResult;

  if (setupScriptExists) {
    try {
      setupCompileResult = await _runClViaVisualStudioSetup(setupScript: setupScript, clArgs: clArgs);
    } on ProcessException catch (error) {
      throw StateError(
        'Failed to start Windows developer command prompt script '
        '`${setupScript.path}`.\n'
        'Details: ${error.message}',
      );
    }

    if (setupCompileResult.exitCode == 0) {
      return;
    }
  }

  final cCompiler = input.config.code.cCompiler;
  final configuredCl = cCompiler?.compiler.toFilePath();

  if (configuredCl != null && File(configuredCl).existsSync()) {
    configuredCompilerResult = await Process.run(configuredCl, clArgs);
    if (configuredCompilerResult.exitCode == 0) {
      return;
    }
  }

  final pathResult = await _runCommandIfAvailable(command: 'cl', args: clArgs);
  if (pathResult != null && pathResult.exitCode == 0) {
    return;
  }

  final setupDescription = switch ((setupScript, setupScriptExists)) {
    (null, _) => 'not configured',
    (_, false) => 'configured but missing',
    (_, true) => 'configured and executed',
  };
  throw StateError(
    'Failed to compile Windows AAC encoder DLL.\n'
    'Visual Studio setup script: $setupDescription.\n'
    '${setupCompileResult == null ? '' : _formatCommandFailure(command: 'cmd.exe /d /c call ""${setupScript?.path ?? ''}"" ${setupScript?.arguments.join(' ') ?? ''} >nul && cl ${clArgs.join(' ')}', exitCode: setupCompileResult.exitCode, stdout: '${setupCompileResult.stdout}', stderr: '${setupCompileResult.stderr}')}\n'
    'Configured compiler path: ${configuredCl ?? 'not configured'}.\n'
    '${configuredCompilerResult == null ? '' : _formatCommandFailure(command: '${configuredCl ?? 'cl.exe'} ${clArgs.join(' ')}', exitCode: configuredCompilerResult.exitCode, stdout: '${configuredCompilerResult.stdout}', stderr: '${configuredCompilerResult.stderr}')}\n'
    'PATH compiler fallback (`cl`): ${pathResult == null ? 'not available' : 'executed (exit code ${pathResult.exitCode})'}.\n'
    '${pathResult == null ? '' : _formatCommandFailure(command: 'cl ${clArgs.join(' ')}', exitCode: pathResult.exitCode, stdout: '${pathResult.stdout}', stderr: '${pathResult.stderr}')}',
  );
}

_VisualStudioSetupScript? _resolveVisualStudioSetupScript(BuildInput input) {
  final cCompiler = input.config.code.cCompiler;
  if (cCompiler == null) {
    return null;
  }

  try {
    final developerPrompt = cCompiler.windows.developerCommandPrompt;
    if (developerPrompt == null) {
      return null;
    }
    return _VisualStudioSetupScript(developerPrompt.script.toFilePath(), developerPrompt.arguments);
  } on StateError {
    return null;
  }
}

String _formatCommandFailure({
  required String command,
  required int exitCode,
  required String stdout,
  required String stderr,
}) {
  return 'Command: $command\n'
      'Exit code: $exitCode\n'
      'stdout:\n$stdout\n'
      'stderr:\n$stderr';
}

Future<ProcessResult> _runClViaVisualStudioSetup({
  required _VisualStudioSetupScript setupScript,
  required List<String> clArgs,
}) async {
  final setupArgs = setupScript.arguments.map(_quoteForWindowsCmd).join(' ');
  final clCommand = ['cl', ...clArgs.map(_quoteForWindowsCmd)].join(' ');
  final tempDir = await Directory.systemTemp.createTemp('speech_utils_windows_build_');
  final commandFile = File('${tempDir.path}\\run_cl.cmd');
  final script = StringBuffer()
    ..writeln('@echo off')
    ..write('call "')
    ..write(setupScript.path)
    ..write('"');
  if (setupArgs.isNotEmpty) {
    script
      ..write(' ')
      ..write(setupArgs);
  }
  script
    ..writeln(' >nul')
    ..writeln('if errorlevel 1 exit /b %errorlevel%')
    ..write(clCommand)
    ..writeln()
    ..writeln('exit /b %errorlevel%');

  await commandFile.writeAsString(script.toString());
  try {
    return await Process.run('cmd.exe', ['/d', '/c', commandFile.path]);
  } finally {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  }
}

Future<ProcessResult?> _runCommandIfAvailable({
  required String command,
  required List<String> args,
}) async {
  try {
    return await Process.run(command, args);
  } on ProcessException {
    return null;
  }
}

String _quoteForWindowsCmd(String value) {
  if (value.isEmpty) {
    return '""';
  }
  if (!RegExp(r'[\s"&|<>^()]').hasMatch(value)) {
    return value;
  }
  return '"${value.replaceAll('"', '""')}"';
}

final class _VisualStudioSetupScript {
  const _VisualStudioSetupScript(this.path, this.arguments);

  final String path;
  final List<String> arguments;
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

  final bundledFileName = input.config.code.targetOS.dylibFileName(_androidAacLibraryBaseName);
  final bundledLibrary = input.outputDirectoryShared.resolve('speech_utils/$bundledFileName');
  final bundledFile = File.fromUri(bundledLibrary);
  bundledFile.parent.createSync(recursive: true);

  final targetNdkApi = input.config.code.android.targetNdkApi;
  final effectiveNdkApi = targetNdkApi < 26 ? 26 : targetNdkApi;
  await _buildWithCCompiler(
    input: input,
    sourceFile: source,
    bundledLibrary: bundledFile,
    args: [
      '-std=c++17',
      '-O2',
      '-fPIC',
      '-shared',
      '-D__ANDROID_API__=$effectiveNdkApi',
      source.path,
      '-o',
      bundledFile.path,
      '-landroid',
      '-lmediandk',
      '-llog',
    ],
  );

  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: _androidAacAssetName,
      linkMode: DynamicLoadingBundled(),
      file: bundledLibrary,
    ),
  );
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

  final bundledFileName = input.config.code.targetOS.dylibFileName(_iosAacLibraryBaseName);
  final bundledLibrary = input.outputDirectoryShared.resolve('speech_utils/$bundledFileName');
  final bundledFile = File.fromUri(bundledLibrary);
  bundledFile.parent.createSync(recursive: true);

  await _buildWithCCompiler(
    input: input,
    sourceFile: source,
    bundledLibrary: bundledFile,
    args: [
      '-std=c++17',
      '-fobjc-arc',
      '-fPIC',
      '-dynamiclib',
      source.path,
      '-o',
      bundledFile.path,
      '-framework',
      'Foundation',
      '-framework',
      'AVFoundation',
      '-framework',
      'CoreMedia',
      '-framework',
      'AudioToolbox',
      '-lc++',
    ],
  );

  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: _iosAacAssetName,
      linkMode: DynamicLoadingBundled(),
      file: bundledLibrary,
    ),
  );
}

Future<void> _maybeBuildMacosAudioMetadataAsset(BuildInput input, BuildOutputBuilder output) async {
  final os = input.config.code.targetOS;
  if (os != OS.macOS) {
    return;
  }
  if (input.config.code.cCompiler == null) {
    return;
  }
  final sdkPath = await _resolveAppleSdkPath('macosx');
  if (sdkPath == null) {
    return;
  }

  final source = File.fromUri(
    input.packageRoot.resolve('native/macos/speech_utils_macos_audio_metadata.mm'),
  );
  if (!source.existsSync()) {
    throw StateError('Missing macOS audio metadata source file at ${source.path}.');
  }

  final bundledFileName = input.config.code.targetOS.dylibFileName(
    _macosAudioMetadataLibraryBaseName,
  );
  final bundledLibrary = input.outputDirectoryShared.resolve('speech_utils/$bundledFileName');
  final bundledFile = File.fromUri(bundledLibrary);
  bundledFile.parent.createSync(recursive: true);

  await _buildWithCCompiler(
    input: input,
    sourceFile: source,
    bundledLibrary: bundledFile,
    args: [
      '-isysroot',
      sdkPath,
      '-std=c++17',
      '-fobjc-arc',
      '-fPIC',
      '-dynamiclib',
      source.path,
      '-o',
      bundledFile.path,
      '-framework',
      'Foundation',
      '-framework',
      'AVFoundation',
      '-framework',
      'CoreMedia',
      '-framework',
      'AudioToolbox',
      '-lc++',
    ],
  );

  output.assets.code.add(
    CodeAsset(
      package: input.packageName,
      name: _macosAudioMetadataAssetName,
      linkMode: DynamicLoadingBundled(),
      file: bundledLibrary,
    ),
  );
}

Future<String?> _resolveAppleSdkPath(String sdkName) async {
  ProcessResult result;
  try {
    result = await Process.run('xcrun', ['--sdk', sdkName, '--show-sdk-path']);
  } on ProcessException {
    return null;
  }
  if (result.exitCode != 0) {
    return null;
  }

  final sdkPath = '${result.stdout}'.trim();
  if (sdkPath.isEmpty) {
    return null;
  }
  return sdkPath;
}

Future<void> _buildWithCCompiler({
  required BuildInput input,
  required File sourceFile,
  required File bundledLibrary,
  required List<String> args,
}) async {
  final cCompiler = input.config.code.cCompiler;
  if (cCompiler == null) {
    throw StateError(
      'No C compiler was provided for target '
      '${input.config.code.targetOS}/${input.config.code.targetArchitecture}.',
    );
  }

  final compilerPath = cCompiler.compiler.toFilePath();
  ProcessResult result;
  try {
    result = await Process.run(compilerPath, args);
  } on ProcessException catch (error) {
    throw StateError(
      'Failed to start C compiler at `$compilerPath` while building '
      '${sourceFile.path} -> ${bundledLibrary.path}.\n'
      'Details: ${error.message}',
    );
  }

  if (result.exitCode != 0) {
    throw StateError(
      'Failed to compile ${sourceFile.path}.\n'
      'Command: $compilerPath ${args.join(' ')}\n'
      'stdout:\n${result.stdout}\n'
      'stderr:\n${result.stderr}',
    );
  }
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
