import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;

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

  await _buildWindowsAacEncoderDll(sourceFile: source, bundledDll: bundledFile);

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

  final setupScript = await _resolveVisualStudioSetupScript();
  final hasMsvcEnv = _hasMsvcCompilerEnvironment();
  if (!hasMsvcEnv && setupScript != null) {
    final setupResult = await _runClViaVisualStudioSetup(setupScript: setupScript, clArgs: clArgs);
    if (setupResult.exitCode == 0) {
      return;
    }
    throw StateError(
      'Failed to compile Windows AAC encoder DLL via `cl` using '
      '`${setupScript.path}`.\n'
      'stdout:\n${setupResult.stdout}\n'
      'stderr:\n${setupResult.stderr}',
    );
  }

  ProcessResult directResult;
  try {
    directResult = await Process.run('cl', clArgs);
  } on ProcessException catch (error) {
    if (setupScript != null) {
      final setupResult = await _runClViaVisualStudioSetup(
        setupScript: setupScript,
        clArgs: clArgs,
      );
      if (setupResult.exitCode == 0) {
        return;
      }
      throw StateError(
        'Failed to start MSVC compiler (`cl`) directly and fallback via '
        '`${setupScript.path}` also failed.\n'
        'direct error: ${error.message}\n'
        'fallback stdout:\n${setupResult.stdout}\n'
        'fallback stderr:\n${setupResult.stderr}',
      );
    }
    throw StateError(
      'Failed to start MSVC compiler (`cl`) while building the Windows AAC encoder. '
      'Ensure Visual Studio Build Tools are installed. '
      'If your shell is not a Developer Prompt, add Visual Studio C++ tools '
      'to PATH/INCLUDE/LIB or install `vswhere`.\n'
      'Details: ${error.message}',
    );
  }

  if (directResult.exitCode == 0) {
    return;
  }

  if (setupScript != null) {
    final setupResult = await _runClViaVisualStudioSetup(setupScript: setupScript, clArgs: clArgs);
    if (setupResult.exitCode == 0) {
      return;
    }
    throw StateError(
      'Failed to compile Windows AAC encoder DLL via `cl`.\n'
      'direct stdout:\n${directResult.stdout}\n'
      'direct stderr:\n${directResult.stderr}\n'
      'fallback (${setupScript.path}) stdout:\n${setupResult.stdout}\n'
      'fallback (${setupScript.path}) stderr:\n${setupResult.stderr}',
    );
  }

  throw StateError(
    'Failed to compile Windows AAC encoder DLL via `cl`.\n'
    'stdout:\n${directResult.stdout}\n'
    'stderr:\n${directResult.stderr}',
  );
}

bool _hasMsvcCompilerEnvironment() {
  final include = Platform.environment['INCLUDE'];
  final lib = Platform.environment['LIB'];
  return include != null && include.trim().isNotEmpty && lib != null && lib.trim().isNotEmpty;
}

Future<_VisualStudioSetupScript?> _resolveVisualStudioSetupScript() async {
  final candidates = <_VisualStudioSetupScript>[];
  final seen = <String>{};

  void addCandidate(_VisualStudioSetupScript candidate) {
    final normalized = candidate.path.toLowerCase();
    if (!seen.add(normalized)) {
      return;
    }
    if (!File(candidate.path).existsSync()) {
      return;
    }
    candidates.add(candidate);
  }

  final env = Platform.environment;
  final vsInstallDir = env['VSINSTALLDIR'];
  if (vsInstallDir != null && vsInstallDir.trim().isNotEmpty) {
    addCandidate(
      _VisualStudioSetupScript(
        p.windows.join(vsInstallDir.trim(), 'Common7', 'Tools', 'VsDevCmd.bat'),
        const ['-arch=x64', '-host_arch=x64'],
      ),
    );
  }

  final vcInstallDir = env['VCINSTALLDIR'];
  if (vcInstallDir != null && vcInstallDir.trim().isNotEmpty) {
    addCandidate(
      _VisualStudioSetupScript(
        p.windows.join(vcInstallDir.trim(), 'Auxiliary', 'Build', 'vcvars64.bat'),
        const [],
      ),
    );
  }

  final programFilesX86 = env['ProgramFiles(x86)'];
  if (programFilesX86 != null && programFilesX86.trim().isNotEmpty) {
    final vsWherePath = p.windows.join(
      programFilesX86.trim(),
      'Microsoft Visual Studio',
      'Installer',
      'vswhere.exe',
    );
    final vsWhereFile = File(vsWherePath);
    if (vsWhereFile.existsSync()) {
      try {
        final result = await Process.run(vsWhereFile.path, [
          '-latest',
          '-products',
          '*',
          '-requires',
          'Microsoft.VisualStudio.Component.VC.Tools.x86.x64',
          '-property',
          'installationPath',
        ]);
        if (result.exitCode == 0) {
          final installPath = '${result.stdout}'
              .split(RegExp(r'[\r\n]+'))
              .map((line) => line.trim())
              .firstWhere((line) => line.isNotEmpty, orElse: () => '');
          if (installPath.isNotEmpty) {
            addCandidate(
              _VisualStudioSetupScript(
                p.windows.join(installPath, 'Common7', 'Tools', 'VsDevCmd.bat'),
                const ['-arch=x64', '-host_arch=x64'],
              ),
            );
            addCandidate(
              _VisualStudioSetupScript(
                p.windows.join(installPath, 'VC', 'Auxiliary', 'Build', 'vcvars64.bat'),
                const [],
              ),
            );
          }
        }
      } on ProcessException {
        // Ignore and continue with environment-based candidates.
      }
    }
  }

  if (candidates.isEmpty) {
    return null;
  }
  return candidates.first;
}

Future<ProcessResult> _runClViaVisualStudioSetup({
  required _VisualStudioSetupScript setupScript,
  required List<String> clArgs,
}) async {
  final setupArgs = setupScript.arguments.map(_quoteForWindowsCmd).join(' ');
  final clCommand = ['cl', ...clArgs.map(_quoteForWindowsCmd)].join(' ');
  final command = StringBuffer()
    ..write('call ')
    ..write(_quoteForWindowsCmd(setupScript.path));
  if (setupArgs.isNotEmpty) {
    command
      ..write(' ')
      ..write(setupArgs);
  }
  command
    ..write(' >nul && ')
    ..write(clCommand);

  return Process.run('cmd.exe', ['/d', '/s', '/c', command.toString()]);
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
