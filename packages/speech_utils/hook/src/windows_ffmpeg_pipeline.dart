import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;

const _ffmpegAutobuildEnv = 'SPEECH_UTILS_WINDOWS_FFMPEG_AUTOBUILD';
const _ffmpegSourceDirEnv = 'SPEECH_UTILS_WINDOWS_FFMPEG_SOURCE_DIR';
const _ffmpegBuildDirName = '.build-minimal';
const _defaultFfmpegSourceRelativePath = 'third_party/ffmpeg/source/ffmpeg';

const _requiredLibNames = <String>['avcodec.lib', 'avformat.lib', 'avutil.lib', 'swresample.lib'];

const _requiredRuntimeDllPrefixes = <String>['avcodec', 'avformat', 'avutil', 'swresample'];

final class WindowsFfmpegSdk {
  WindowsFfmpegSdk({
    required this.rootDir,
    required this.includeDir,
    required this.libDir,
    required this.binDir,
    required this.runtimeDlls,
  });

  final Directory rootDir;
  final Directory includeDir;
  final Directory libDir;
  final Directory binDir;
  final List<File> runtimeDlls;
}

Future<WindowsFfmpegSdk> ensureWindowsFfmpegSdk(BuildInput input) async {
  final rootDir = Directory.fromUri(input.packageRoot.resolve('third_party/ffmpeg/windows'));
  final includeDir = Directory(p.join(rootDir.path, 'include'));
  final libDir = Directory(p.join(rootDir.path, 'lib'));
  final binDir = Directory(p.join(rootDir.path, 'bin'));

  if (!_hasRequiredHeadersAndImportLibs(includeDir: includeDir, libDir: libDir) ||
      _collectRuntimeDlls(binDir).isEmpty) {
    await _maybeAutobuildMinimalWindowsFfmpeg(
      input: input,
      rootDir: rootDir,
      includeDir: includeDir,
      libDir: libDir,
      binDir: binDir,
    );
  }

  _validateRequiredHeadersAndImportLibs(includeDir: includeDir, libDir: libDir);
  final runtimeDlls = _collectRuntimeDlls(binDir);
  _validateRequiredRuntimeDllPrefixes(runtimeDlls, binDir.path);

  return WindowsFfmpegSdk(
    rootDir: rootDir,
    includeDir: includeDir,
    libDir: libDir,
    binDir: binDir,
    runtimeDlls: runtimeDlls,
  );
}

List<File> collectWindowsFfmpegRuntimeDlls(WindowsFfmpegSdk sdk) {
  final runtimeDlls = _collectRuntimeDlls(sdk.binDir);
  _validateRequiredRuntimeDllPrefixes(runtimeDlls, sdk.binDir.path);
  return runtimeDlls;
}

Future<void> _maybeAutobuildMinimalWindowsFfmpeg({
  required BuildInput input,
  required Directory rootDir,
  required Directory includeDir,
  required Directory libDir,
  required Directory binDir,
}) async {
  final configuredAutobuildValue = Platform.environment[_ffmpegAutobuildEnv];
  final configuredAutobuild = _isTruthy(configuredAutobuildValue);
  final sourceDir = _resolveWindowsFfmpegSourceDir(input);

  final canAttemptAutobuild = Platform.isWindows && (configuredAutobuild || sourceDir.existsSync());
  if (!canAttemptAutobuild) {
    throw StateError(
      _missingSdkMessage(
        includeDir: includeDir,
        libDir: libDir,
        binDir: binDir,
        sourceDir: sourceDir,
        configuredAutobuildValue: configuredAutobuildValue,
      ),
    );
  }

  await _autobuildMinimalWindowsFfmpeg(rootDir: rootDir, sourceDir: sourceDir);

  if (!_hasRequiredHeadersAndImportLibs(includeDir: includeDir, libDir: libDir)) {
    throw StateError(
      'FFmpeg auto-build finished, but required headers/import libs are still missing in '
      '${rootDir.path}.',
    );
  }
  if (_collectRuntimeDlls(binDir).isEmpty) {
    throw StateError(
      'FFmpeg auto-build finished, but no runtime DLLs were found in ${binDir.path}.',
    );
  }
}

Future<void> _autobuildMinimalWindowsFfmpeg({
  required Directory rootDir,
  required Directory sourceDir,
}) async {
  if (!sourceDir.existsSync()) {
    throw StateError(
      'FFmpeg source directory does not exist: ${sourceDir.path}\n'
      'Set $_ffmpegSourceDirEnv to your FFmpeg source checkout path.',
    );
  }

  final configureFile = File(p.join(sourceDir.path, 'configure'));
  if (!configureFile.existsSync()) {
    throw StateError(
      'FFmpeg source directory does not contain configure script: ${configureFile.path}',
    );
  }

  final buildDir = Directory(p.join(rootDir.path, _ffmpegBuildDirName));
  buildDir.createSync(recursive: true);
  rootDir.createSync(recursive: true);

  final sourceDirMsys = _toMsysPath(sourceDir.path);
  final buildDirMsys = _toMsysPath(buildDir.path);
  final installDirMsys = _toMsysPath(rootDir.path);
  final jobs = Platform.numberOfProcessors > 1 ? Platform.numberOfProcessors : 1;

  final script =
      '''
set -euo pipefail
cd "$buildDirMsys"
rm -rf "$installDirMsys/include" "$installDirMsys/lib" "$installDirMsys/bin"
"$sourceDirMsys/configure" \\
  --prefix="$installDirMsys" \\
  --target-os=win64 \\
  --arch=x86_64 \\
  --toolchain=msvc \\
  --disable-everything \\
  --disable-programs \\
  --disable-doc \\
  --disable-network \\
  --enable-shared \\
  --disable-static \\
  --enable-small \\
  --enable-avcodec \\
  --enable-avformat \\
  --enable-avutil \\
  --enable-swresample \\
  --enable-encoder=aac \\
  --enable-decoder=pcm_s16le,aac,mp3 \\
  --enable-parser=aac,mpegaudio \\
  --enable-demuxer=wav,mov,mp3,aac \\
  --enable-muxer=ipod,adts \\
  --enable-protocol=file
make -j$jobs
make install
''';

  final result = await Process.run(
    'bash',
    ['-lc', script],
    environment: {...Platform.environment, 'MSYS2_ARG_CONV_EXCL': '*'},
    runInShell: true,
  );

  if (result.exitCode != 0) {
    final stdoutText = '${result.stdout}'.trim();
    final stderrText = '${result.stderr}'.trim();
    throw StateError(
      'Failed to auto-build minimal Windows FFmpeg SDK.\n'
      'Source: ${sourceDir.path}\n'
      'Exit code: ${result.exitCode}\n'
      'stdout:\n$stdoutText\n'
      'stderr:\n$stderrText',
    );
  }
}

Directory _resolveWindowsFfmpegSourceDir(BuildInput input) {
  final sourceDirFromEnv = Platform.environment[_ffmpegSourceDirEnv];
  if (sourceDirFromEnv != null && sourceDirFromEnv.trim().isNotEmpty) {
    return Directory(sourceDirFromEnv.trim());
  }
  return Directory.fromUri(input.packageRoot.resolve(_defaultFfmpegSourceRelativePath));
}

bool _hasRequiredHeadersAndImportLibs({required Directory includeDir, required Directory libDir}) {
  if (!includeDir.existsSync() || !libDir.existsSync()) {
    return false;
  }

  final requiredHeader = File(p.join(includeDir.path, 'libavcodec', 'avcodec.h'));
  if (!requiredHeader.existsSync()) {
    return false;
  }

  for (final requiredLibName in _requiredLibNames) {
    final libFile = File(p.join(libDir.path, requiredLibName));
    if (!libFile.existsSync()) {
      return false;
    }
  }
  return true;
}

void _validateRequiredHeadersAndImportLibs({
  required Directory includeDir,
  required Directory libDir,
}) {
  if (!includeDir.existsSync()) {
    throw StateError('Missing FFmpeg headers directory at ${includeDir.path}.');
  }
  if (!libDir.existsSync()) {
    throw StateError('Missing FFmpeg import libraries directory at ${libDir.path}.');
  }

  final requiredHeader = File(p.join(includeDir.path, 'libavcodec', 'avcodec.h'));
  if (!requiredHeader.existsSync()) {
    throw StateError('Missing FFmpeg header at ${requiredHeader.path}.');
  }

  for (final requiredLibName in _requiredLibNames) {
    final libFile = File(p.join(libDir.path, requiredLibName));
    if (!libFile.existsSync()) {
      throw StateError('Missing FFmpeg import library at ${libFile.path}.');
    }
  }
}

List<File> _collectRuntimeDlls(Directory ffmpegBinDir) {
  if (!ffmpegBinDir.existsSync()) {
    return const <File>[];
  }

  final runtimeDlls =
      ffmpegBinDir
          .listSync(followLinks: false)
          .whereType<File>()
          .where((file) => p.extension(file.path).toLowerCase() == '.dll')
          .toList()
        ..sort(
          (left, right) =>
              p.basename(left.path).toLowerCase().compareTo(p.basename(right.path).toLowerCase()),
        );
  return runtimeDlls;
}

void _validateRequiredRuntimeDllPrefixes(List<File> runtimeDlls, String ffmpegBinPath) {
  if (runtimeDlls.isEmpty) {
    throw StateError(
      'No FFmpeg runtime DLLs found in $ffmpegBinPath. '
      'Expected at least avcodec/avformat/avutil/swresample DLLs.',
    );
  }

  final runtimeDllNames = runtimeDlls
      .map((file) => p.basename(file.path).toLowerCase())
      .toList(growable: false);

  for (final requiredPrefix in _requiredRuntimeDllPrefixes) {
    final hasPrefix = runtimeDllNames.any((name) => name.startsWith(requiredPrefix));
    if (!hasPrefix) {
      throw StateError(
        'Missing FFmpeg runtime DLL matching "$requiredPrefix*.dll" in $ffmpegBinPath.',
      );
    }
  }
}

String _missingSdkMessage({
  required Directory includeDir,
  required Directory libDir,
  required Directory binDir,
  required Directory sourceDir,
  required String? configuredAutobuildValue,
}) {
  return 'Windows FFmpeg SDK is missing or incomplete.\n'
      'Expected:\n'
      '- include: ${includeDir.path}\n'
      '- lib: ${libDir.path}\n'
      '- bin: ${binDir.path}\n'
      '\n'
      'To auto-build a minimal FFmpeg SDK via build hook on Windows:\n'
      '1) Ensure FFmpeg source exists at "${sourceDir.path}" '
      'or set $_ffmpegSourceDirEnv.\n'
      '2) Set $_ffmpegAutobuildEnv=1 in your environment.\n'
      '\n'
      'Current $_ffmpegAutobuildEnv value: ${configuredAutobuildValue ?? '(unset)'}';
}

bool _isTruthy(String? value) {
  if (value == null) {
    return false;
  }
  final normalized = value.trim().toLowerCase();
  return normalized == '1' || normalized == 'true' || normalized == 'yes' || normalized == 'on';
}

String _toMsysPath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final driveMatch = RegExp(r'^([A-Za-z]):/(.*)$').firstMatch(normalized);
  if (driveMatch == null) {
    return normalized;
  }
  final drive = driveMatch.group(1)!.toLowerCase();
  final rest = driveMatch.group(2)!;
  return '/$drive/$rest';
}
