import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;

import 'hook_helpers.dart';

const _requiredSharedLibraryPrefixes = <String>[
  'avcodec',
  'avformat',
  'avutil',
  'swresample',
];
const _optionalSharedLibraryPrefixes = <String>[
  'avdevice',
  'avfilter',
  'swscale',
];

final class LinuxFfmpegSdk {
  LinuxFfmpegSdk({
    required this.rootDir,
    required this.includeDir,
    required this.libDir,
    required this.libraryDirectories,
    required this.runtimeLibraries,
  });

  final Directory rootDir;
  final Directory includeDir;
  final Directory libDir;
  final List<Directory> libraryDirectories;
  final List<File> runtimeLibraries;
}

Future<LinuxFfmpegSdk> loadLinuxFfmpegSdk(
  BuildInput input, {
  BuildOutputBuilder? output,
}) async {
  final rootDir = Directory.fromUri(
    input.packageRoot.resolve('third_party/ffmpeg/linux'),
  );
  final includeDir = Directory(p.join(rootDir.path, 'include'));
  final libDir = Directory(p.join(rootDir.path, 'lib'));

  _validateRequiredHeaders(includeDir, output: output);
  final linkerLibraries = _resolveRequiredLinkerLibraries(libDir);
  final runtimeLibraries = _resolveBundledRuntimeLibraries(libDir);
  _validateRequiredRuntimeLibraryPrefixes(runtimeLibraries, libDir.path);

  if (output != null) {
    addFileDependencies(output, linkerLibraries.values);
    addFileDependencies(output, runtimeLibraries);
  }

  return LinuxFfmpegSdk(
    rootDir: rootDir,
    includeDir: includeDir,
    libDir: libDir,
    libraryDirectories: [libDir],
    runtimeLibraries: runtimeLibraries,
  );
}

void _validateRequiredHeaders(
  Directory includeDir, {
  BuildOutputBuilder? output,
}) {
  if (!includeDir.existsSync()) {
    throw StateError('Missing FFmpeg headers directory at ${includeDir.path}.');
  }

  const requiredHeaders = <String>[
    'libavcodec/avcodec.h',
    'libavformat/avformat.h',
    'libavutil/avutil.h',
    'libswresample/swresample.h',
  ];

  for (final relativeHeaderPath in requiredHeaders) {
    final header = File(p.join(includeDir.path, relativeHeaderPath));
    if (!header.existsSync()) {
      throw StateError('Missing FFmpeg header at ${header.path}.');
    }
    output?.dependencies.add(header.absolute.uri);
  }
}

Map<String, File> _resolveRequiredLinkerLibraries(Directory libDir) {
  final resolved = <String, File>{};
  for (final prefix in _requiredSharedLibraryPrefixes) {
    final library = File(p.join(libDir.path, 'lib$prefix.so'));
    if (library.existsSync()) {
      resolved[prefix] = library;
    }
  }

  final missingPrefixes = _requiredSharedLibraryPrefixes
      .where((prefix) => !resolved.containsKey(prefix))
      .toList(growable: false);
  if (missingPrefixes.isNotEmpty) {
    final missingNames = missingPrefixes
        .map((prefix) => 'lib$prefix.so')
        .join(', ');
    throw StateError(
      'Missing FFmpeg linker libraries ($missingNames) in ${libDir.path}. '
      'The Linux bundle must include unversioned linker .so files in lib/.',
    );
  }

  return resolved;
}

List<File> _resolveBundledRuntimeLibraries(Directory libDir) {
  if (!libDir.existsSync()) {
    throw StateError('Missing FFmpeg library directory at ${libDir.path}.');
  }

  final allSharedLibrariesByName = <String, File>{};
  for (final entity in libDir.listSync(followLinks: false)) {
    if (entity is! File && entity is! Link) {
      continue;
    }
    final fileName = p.basename(entity.path);
    if (!fileName.contains('.so')) {
      continue;
    }
    final file = File(entity.path);
    if (file.existsSync()) {
      allSharedLibrariesByName[fileName] = file;
    }
  }

  final selected = <String, File>{};
  for (final prefix in [
    ..._requiredSharedLibraryPrefixes,
    ..._optionalSharedLibraryPrefixes,
  ]) {
    for (final library in _runtimeLibrariesForPrefix(
      allSharedLibrariesByName,
      prefix,
    )) {
      selected[p.basename(library.path)] = library;
    }
  }

  final runtimeLibraries = selected.values.toList(growable: false)
    ..sort(
      (left, right) => p.basename(left.path).compareTo(p.basename(right.path)),
    );
  return runtimeLibraries;
}

List<File> _runtimeLibrariesForPrefix(
  Map<String, File> allLibrariesByName,
  String prefix,
) {
  final baseName = 'lib$prefix.so';
  final matches = allLibrariesByName.entries
      .where(
        (entry) => entry.key == baseName || entry.key.startsWith('$baseName.'),
      )
      .map((entry) => entry.value)
      .toList(growable: false);

  matches.sort(
    (left, right) => p.basename(left.path).compareTo(p.basename(right.path)),
  );
  return matches;
}

void _validateRequiredRuntimeLibraryPrefixes(
  List<File> runtimeLibraries,
  String ffmpegLibPath,
) {
  if (runtimeLibraries.isEmpty) {
    throw StateError(
      'No FFmpeg runtime libraries selected from $ffmpegLibPath. '
      'Expected at least libavcodec/libavformat/libavutil/libswresample shared libraries.',
    );
  }

  final runtimeNames = runtimeLibraries
      .map((file) => p.basename(file.path))
      .toList(growable: false);
  for (final requiredPrefix in _requiredSharedLibraryPrefixes) {
    final requiredName = 'lib$requiredPrefix.so';
    final hasPrefix = runtimeNames.any(
      (name) => name == requiredName || name.startsWith('$requiredName.'),
    );
    if (!hasPrefix) {
      throw StateError(
        'Missing FFmpeg runtime library matching "$requiredName*" in $ffmpegLibPath.',
      );
    }
  }
}
