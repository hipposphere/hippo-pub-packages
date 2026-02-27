import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;

const _requiredHeaderPath = 'modules/audio_processing/include/audio_processing.h';
const _preferredImportLibPrefixes = <String>[
  'webrtc-audio-processing',
  'webrtc_audio_processing',
  'audio_processing',
];

final class WindowsWebRtcApmSdk {
  WindowsWebRtcApmSdk({
    required this.rootDir,
    required this.includeDir,
    required this.libDir,
    required this.binDir,
    required this.importLibDirectories,
    required this.libraries,
    required this.runtimeDlls,
  });

  final Directory rootDir;
  final Directory includeDir;
  final Directory libDir;
  final Directory binDir;
  final List<String> importLibDirectories;
  final List<String> libraries;
  final List<File> runtimeDlls;
}

Future<WindowsWebRtcApmSdk> requireVendoredWindowsWebRtcApmSdk(BuildInput input) async {
  final rootDir = Directory.fromUri(input.packageRoot.resolve('third_party/webrtc_apm/windows'));
  if (!rootDir.existsSync()) {
    throw StateError('Missing vendored WebRTC APM SDK directory at ${rootDir.path}.');
  }

  final includeRootDir = Directory(p.join(rootDir.path, 'include'));
  final libDir = Directory(p.join(rootDir.path, 'lib'));
  final binDir = Directory(p.join(rootDir.path, 'bin'));

  final includeDir = _resolveIncludeDir(includeRootDir);
  if (includeDir == null) {
    throw StateError(
      'Missing WebRTC APM headers. Expected '
      '${p.join(includeRootDir.path, _requiredHeaderPath)} or '
      '${p.join(includeRootDir.path, 'webrtc-audio-processing-1', _requiredHeaderPath)}.',
    );
  }

  final importLib = _findImportLibByPreferredPrefixes(libDir: libDir, binDir: binDir);
  if (importLib == null) {
    throw StateError(
      'Missing WebRTC APM import library in ${libDir.path} or ${binDir.path}. '
      'Expected prefixes: ${_preferredImportLibPrefixes.join(', ')}.',
    );
  }

  final libraryName = p.basenameWithoutExtension(importLib.path);
  final libraries = [libraryName, ..._collectAdditionalLibraryNames(libDir, binDir, libraryName)];
  final runtimeDlls = _resolveRuntimeDlls(binDir, libraries);
  if (runtimeDlls.isEmpty) {
    throw StateError(
      'Missing WebRTC APM runtime DLLs in ${binDir.path}. '
      'Expected DLL names matching: ${libraries.join(', ')}.',
    );
  }

  return WindowsWebRtcApmSdk(
    rootDir: rootDir,
    includeDir: includeDir,
    libDir: libDir,
    binDir: binDir,
    importLibDirectories: _uniqueDirectoriesInOrder([
      p.dirname(importLib.path),
      if (libDir.existsSync()) libDir.path,
      if (binDir.existsSync()) binDir.path,
    ]),
    libraries: libraries,
    runtimeDlls: runtimeDlls,
  );
}

Directory? _resolveIncludeDir(Directory includeRootDir) {
  if (!includeRootDir.existsSync()) {
    return null;
  }

  final directHeader = File(p.join(includeRootDir.path, _requiredHeaderPath));
  if (directHeader.existsSync()) {
    return includeRootDir;
  }

  final prefixedDir = Directory(p.join(includeRootDir.path, 'webrtc-audio-processing-1'));
  final prefixedHeader = File(p.join(prefixedDir.path, _requiredHeaderPath));
  if (prefixedHeader.existsSync()) {
    return prefixedDir;
  }

  return null;
}

File? _findImportLibByPreferredPrefixes({
  required Directory libDir,
  required Directory binDir,
}) {
  for (final prefix in _preferredImportLibPrefixes) {
    final fromLib = _findImportLibByPrefix(libDir, prefix);
    if (fromLib != null) {
      return fromLib;
    }
    final fromBin = _findImportLibByPrefix(binDir, prefix);
    if (fromBin != null) {
      return fromBin;
    }
  }
  return null;
}

File? _findImportLibByPrefix(Directory directory, String prefix) {
  if (!directory.existsSync()) {
    return null;
  }

  final exactFile = File(p.join(directory.path, '$prefix.lib'));
  if (exactFile.existsSync()) {
    return exactFile;
  }

  final matches = directory
      .listSync(followLinks: false)
      .whereType<File>()
      .where((file) {
        final fileName = p.basename(file.path).toLowerCase();
        return fileName.startsWith('${prefix.toLowerCase()}-') && fileName.endsWith('.lib');
      })
      .toList(growable: false);
  if (matches.isEmpty) {
    return null;
  }

  final sorted = matches.toList(growable: false)
    ..sort((left, right) => p.basename(left.path).compareTo(p.basename(right.path)));
  return sorted.last;
}

List<File> _resolveRuntimeDlls(Directory binDir, List<String> libraryNames) {
  if (!binDir.existsSync()) {
    return const <File>[];
  }

  final lowerLibraryNames = libraryNames.map((name) => name.toLowerCase()).toList(growable: false);
  final runtimeDlls = binDir
      .listSync(followLinks: false)
      .whereType<File>()
      .where((file) {
        final fileName = p.basename(file.path).toLowerCase();
        if (!fileName.endsWith('.dll')) {
          return false;
        }
        for (final libraryName in lowerLibraryNames) {
          if (fileName == '$libraryName.dll' || fileName.startsWith('$libraryName-')) {
            return true;
          }
        }
        return false;
      })
      .toList(growable: false)
    ..sort((left, right) => p.basename(left.path).compareTo(p.basename(right.path)));

  return runtimeDlls;
}

List<String> _uniqueDirectoriesInOrder(List<String> directories) {
  final unique = <String>[];
  final seen = <String>{};
  for (final directory in directories) {
    final normalized = p.normalize(directory).toLowerCase();
    if (seen.add(normalized)) {
      unique.add(directory);
    }
  }
  return unique;
}

List<String> _collectAdditionalLibraryNames(
  Directory libDir,
  Directory binDir,
  String primaryLibraryName,
) {
  final names = <String>{};
  for (final directory in [libDir, binDir]) {
    if (!directory.existsSync()) {
      continue;
    }
    for (final file in directory.listSync(followLinks: false).whereType<File>()) {
      if (p.extension(file.path).toLowerCase() != '.lib') {
        continue;
      }
      names.add(p.basenameWithoutExtension(file.path));
    }
  }
  names.removeWhere((name) => name.toLowerCase() == primaryLibraryName.toLowerCase());
  final sorted = names.toList(growable: false)..sort((left, right) => left.compareTo(right));
  return sorted;
}
