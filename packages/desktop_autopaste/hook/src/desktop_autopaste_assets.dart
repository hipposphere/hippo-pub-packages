import 'package:code_assets/code_assets.dart';
import 'dart:io';

import 'package:hippo_native_deps/hippo_native_deps.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

import 'hook_helpers.dart';

const _assetName = 'src/ffi/generated/desktop_autopaste_bindings.dart';
const _windowsLibraryBaseName = 'desktop_autopaste_windows';
const _macosLibraryBaseName = 'desktop_autopaste_macos';

const _windowsSources = <String>[
  'native/windows/desktop_autopaste_windows_ffi.cpp',
  'native/windows/autopaste_text.cpp',
  'native/windows/focused_text_field_context.cpp',
];

const _macosSources = <String>[
  'native/macos/desktop_autopaste_macos_ffi.swift',
];

Future<void> buildDesktopAutopasteWindowsAsset(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  if (!matchesTarget(input, os: OS.windows, arch: Architecture.x64)) {
    return;
  }

  for (final source in _windowsSources) {
    requireSourceFile(
      input,
      relativePath: source,
      label: 'desktop_autopaste windows',
      output: output,
    );
  }
  requireSourceFile(
    input,
    relativePath: 'native/include/desktop_autopaste_ffi.h',
    label: 'desktop_autopaste ffi header',
    output: output,
  );
  final nativeDepsIncludes = requireNativeDepsWindowsIncludeDirs(input);

  await CBuilder.library(
    name: _windowsLibraryBaseName,
    assetName: _assetName,
    language: Language.cpp,
    sources: _windowsSources,
    includes: ['native/include', 'native/windows', ...nativeDepsIncludes],
    std: 'c++17',
    flags: windowsCommonCppFlags,
    defines: windowsCommonDefines,
    libraries: ['ole32', 'oleaut32', 'user32', 'uiautomationcore'],
  ).run(input: input, output: output);
}

Future<void> buildDesktopAutopasteMacosAsset(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  if (!matchesTarget(input, os: OS.macOS)) {
    return;
  }

  requireSourceFile(
    input,
    relativePath: 'native/include/desktop_autopaste_ffi.h',
    label: 'desktop_autopaste ffi header',
    output: output,
  );
  final sourceFiles = <File>[];
  for (final source in _macosSources) {
    sourceFiles.add(
      requireSourceFile(
        input,
        relativePath: source,
        label: 'desktop_autopaste macOS',
        output: output,
      ),
    );
  }

  final archFlag = switch (input.config.code.targetArchitecture) {
    Architecture.arm64 => 'arm64',
    Architecture.x64 => 'x86_64',
    _ => null,
  };

  final outputFileName = input.config.code.targetOS.dylibFileName(
    _macosLibraryBaseName,
  );
  final outputUri = input.outputDirectory.resolve(
    'desktop_autopaste/$outputFileName',
  );
  final outputFile = File.fromUri(outputUri);
  outputFile.parent.createSync(recursive: true);

  final args = <String>[
    '--sdk',
    'macosx',
    'swiftc',
    '-emit-library',
    '-module-name',
    'desktop_autopaste',
    '-o',
    outputFile.path,
    ...sourceFiles.map((source) => source.path),
    '-framework',
    'AppKit',
    '-framework',
    'ApplicationServices',
    '-framework',
    'Foundation',
  ];
  if (archFlag != null) {
    args.addAll(<String>['-target', '$archFlag-apple-macosx10.15']);
  }

  final result = await Process.run('xcrun', args);
  if (result.exitCode != 0) {
    throw StateError(
      'Failed to compile macOS swift desktop_autopaste library.\\n'
      'stdout:\\n${result.stdout}\\n'
      'stderr:\\n${result.stderr}',
    );
  }

  addBundledDynamicAsset(
    input: input,
    output: output,
    assetName: _assetName,
    fileUri: outputUri,
  );
}
