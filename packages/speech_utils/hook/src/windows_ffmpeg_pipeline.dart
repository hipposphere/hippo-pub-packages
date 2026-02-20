import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;

const _requiredImportLibPrefixes = <String>['avcodec', 'avformat', 'avutil', 'swresample'];
const _requiredRuntimeDllPrefixes = <String>['avcodec', 'avformat', 'avutil', 'swresample'];
const _optionalRuntimeDllPrefixes = <String>['avdevice', 'avfilter', 'swscale'];
const _optionalTransitiveRuntimeDllNames = <String>[
  'libiconv-2.dll',
  'libwinpthread-1.dll',
  'zlib1.dll',
];

final class WindowsFfmpegSdk {
  WindowsFfmpegSdk({
    required this.rootDir,
    required this.includeDir,
    required this.libDir,
    required this.binDir,
    required this.importLibDirectories,
    required this.runtimeDlls,
  });

  final Directory rootDir;
  final Directory includeDir;
  final Directory libDir;
  final Directory binDir;
  final List<Directory> importLibDirectories;
  final List<File> runtimeDlls;
}

Future<WindowsFfmpegSdk> loadWindowsFfmpegSdk(BuildInput input) async {
  final rootDir = Directory.fromUri(input.packageRoot.resolve('third_party/ffmpeg/windows'));
  final includeDir = Directory(p.join(rootDir.path, 'include'));
  final libDir = Directory(p.join(rootDir.path, 'lib'));
  final binDir = Directory(p.join(rootDir.path, 'bin'));

  _validateRequiredHeaders(includeDir);
  final resolvedImportLibs = _resolveRequiredImportLibs(libDir: libDir, binDir: binDir);
  final importLibDirectories = _uniqueDirectoriesInOrder(
    resolvedImportLibs.values
        .map((file) => Directory(p.dirname(file.path)))
        .toList(growable: false),
  );
  final runtimeDlls = _resolveBundledRuntimeDlls(binDir);
  _validateRequiredRuntimeDllPrefixes(runtimeDlls, binDir.path);
  _validateTransitiveRuntimeDllCompatibility(runtimeDlls, binDir.path);

  return WindowsFfmpegSdk(
    rootDir: rootDir,
    includeDir: includeDir,
    libDir: libDir,
    binDir: binDir,
    importLibDirectories: importLibDirectories,
    runtimeDlls: runtimeDlls,
  );
}

void _validateRequiredHeaders(Directory includeDir) {
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
  }
}

Map<String, File> _resolveRequiredImportLibs({
  required Directory libDir,
  required Directory binDir,
}) {
  final resolved = <String, File>{};
  for (final prefix in _requiredImportLibPrefixes) {
    final fromLibDir = _findImportLibByPrefix(libDir, prefix);
    if (fromLibDir != null) {
      resolved[prefix] = fromLibDir;
      continue;
    }
    final fromBinDir = _findImportLibByPrefix(binDir, prefix);
    if (fromBinDir != null) {
      resolved[prefix] = fromBinDir;
    }
  }

  final missingPrefixes = _requiredImportLibPrefixes
      .where((prefix) => !resolved.containsKey(prefix))
      .toList(growable: false);
  if (missingPrefixes.isNotEmpty) {
    final missingNames = missingPrefixes.map((prefix) => '$prefix.lib').join(', ');
    throw StateError(
      'Missing FFmpeg import libraries ($missingNames). '
      'Searched in ${libDir.path} and ${binDir.path}.',
    );
  }

  return resolved;
}

File? _findImportLibByPrefix(Directory directory, String prefix) {
  if (!directory.existsSync()) {
    return null;
  }

  final exactName = '$prefix.lib';
  final exactMatch = File(p.join(directory.path, exactName));
  if (exactMatch.existsSync()) {
    return exactMatch;
  }

  final versionedMatches = <File>[];
  for (final entity in directory.listSync(followLinks: false)) {
    if (entity is! File) {
      continue;
    }
    final fileName = p.basename(entity.path).toLowerCase();
    if (fileName.startsWith('$prefix-') && fileName.endsWith('.lib')) {
      versionedMatches.add(entity);
    }
  }

  if (versionedMatches.isEmpty) {
    return null;
  }

  versionedMatches.sort(
    (left, right) =>
        p.basename(left.path).toLowerCase().compareTo(p.basename(right.path).toLowerCase()),
  );
  return versionedMatches.last;
}

List<File> _resolveBundledRuntimeDlls(Directory binDir) {
  if (!binDir.existsSync()) {
    throw StateError('Missing FFmpeg runtime directory at ${binDir.path}.');
  }

  final allDllsByLowerName = <String, File>{};
  for (final entity in binDir.listSync(followLinks: false)) {
    if (entity is! File) {
      continue;
    }
    if (p.extension(entity.path).toLowerCase() != '.dll') {
      continue;
    }
    allDllsByLowerName[p.basename(entity.path).toLowerCase()] = entity;
  }

  final selected = <String, File>{};
  for (final prefix in [..._requiredRuntimeDllPrefixes, ..._optionalRuntimeDllPrefixes]) {
    final dll = _pickLatestRuntimeDllForPrefix(allDllsByLowerName, prefix);
    if (dll != null) {
      selected[p.basename(dll.path).toLowerCase()] = dll;
    }
  }

  for (final dllName in _optionalTransitiveRuntimeDllNames) {
    final dll = allDllsByLowerName[dllName];
    if (dll != null) {
      selected[dllName] = dll;
    }
  }

  final runtimeDlls = selected.values.toList(growable: false)
    ..sort(
      (left, right) =>
          p.basename(left.path).toLowerCase().compareTo(p.basename(right.path).toLowerCase()),
    );
  return runtimeDlls;
}

File? _pickLatestRuntimeDllForPrefix(Map<String, File> allDllsByLowerName, String prefix) {
  final matches = allDllsByLowerName.values
      .where((file) {
        final fileName = p.basename(file.path).toLowerCase();
        return fileName == '$prefix.dll' ||
            (fileName.startsWith('$prefix-') && fileName.endsWith('.dll'));
      })
      .toList(growable: false);

  if (matches.isEmpty) {
    return null;
  }

  final sorted = matches.toList(growable: false)
    ..sort(
      (left, right) => _compareRuntimeDllNames(
        p.basename(left.path).toLowerCase(),
        p.basename(right.path).toLowerCase(),
      ),
    );
  return sorted.last;
}

int _compareRuntimeDllNames(String leftName, String rightName) {
  int parseMajorVersion(String fileName) {
    final match = RegExp(r'-(\d+)').firstMatch(fileName);
    if (match == null) {
      return -1;
    }
    return int.tryParse(match.group(1)!) ?? -1;
  }

  final leftMajor = parseMajorVersion(leftName);
  final rightMajor = parseMajorVersion(rightName);
  if (leftMajor != rightMajor) {
    return leftMajor.compareTo(rightMajor);
  }
  return leftName.compareTo(rightName);
}

List<Directory> _uniqueDirectoriesInOrder(List<Directory> directories) {
  final unique = <Directory>[];
  final seenPaths = <String>{};
  for (final directory in directories) {
    final normalized = p.normalize(directory.path).toLowerCase();
    if (seenPaths.add(normalized)) {
      unique.add(directory);
    }
  }
  return unique;
}

void _validateRequiredRuntimeDllPrefixes(List<File> runtimeDlls, String ffmpegBinPath) {
  if (runtimeDlls.isEmpty) {
    throw StateError(
      'No FFmpeg runtime DLLs selected from $ffmpegBinPath. '
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

void _validateTransitiveRuntimeDllCompatibility(List<File> runtimeDlls, String ffmpegBinPath) {
  File? findRuntimeByPrefix(String prefix) {
    for (final dll in runtimeDlls) {
      final name = p.basename(dll.path).toLowerCase();
      if (name.startsWith(prefix)) {
        return dll;
      }
    }
    return null;
  }

  File? findRuntimeByExactName(String fileNameLower) {
    for (final dll in runtimeDlls) {
      if (p.basename(dll.path).toLowerCase() == fileNameLower) {
        return dll;
      }
    }
    return null;
  }

  final issues = <String>[];

  void validateDependency({
    required String importerPrefix,
    required String dependencyFileNameLower,
    required List<String> requiredSymbols,
  }) {
    final importer = findRuntimeByPrefix(importerPrefix);
    if (importer == null) {
      return;
    }

    if (!_binaryContainsToken(importer, dependencyFileNameLower)) {
      return;
    }

    final dependency = findRuntimeByExactName(dependencyFileNameLower);
    if (dependency == null) {
      issues.add('Missing $dependencyFileNameLower required by ${p.basename(importer.path)}.');
      return;
    }

    for (final symbol in requiredSymbols) {
      if (!_binaryContainsToken(dependency, symbol)) {
        issues.add(
          'Incompatible ${p.basename(dependency.path)}: missing symbol "$symbol" '
          'required by ${p.basename(importer.path)}.',
        );
      }
    }
  }

  validateDependency(
    importerPrefix: 'avcodec',
    dependencyFileNameLower: 'libiconv-2.dll',
    requiredSymbols: const ['libiconv', 'libiconv_open', 'libiconv_close'],
  );
  validateDependency(
    importerPrefix: 'avutil',
    dependencyFileNameLower: 'libwinpthread-1.dll',
    requiredSymbols: const ['clock_gettime64', 'nanosleep64'],
  );
  validateDependency(
    importerPrefix: 'avformat',
    dependencyFileNameLower: 'zlib1.dll',
    requiredSymbols: const ['uncompress'],
  );

  if (issues.isNotEmpty) {
    final message = [
      'Incompatible FFmpeg runtime bundle in $ffmpegBinPath.',
      ...issues,
      'Ensure all transitive runtime DLLs come from the same CI FFmpeg artifact.',
    ].join('\n');
    throw StateError(message);
  }
}

bool _binaryContainsToken(File file, String tokenLowerCase) {
  final bytes = file.readAsBytesSync();
  final text = latin1.decode(bytes, allowInvalid: true).toLowerCase();
  return text.contains(tokenLowerCase.toLowerCase());
}
