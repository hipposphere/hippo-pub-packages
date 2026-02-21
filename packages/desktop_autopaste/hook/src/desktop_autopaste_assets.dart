import 'package:code_assets/code_assets.dart';
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

const _macosSources = <String>['native/apple/desktop_autopaste_macos_ffi.mm'];

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
    );
  }
  requireSourceFile(
    input,
    relativePath: 'native/include/desktop_autopaste_ffi.h',
    label: 'desktop_autopaste ffi header',
  );

  await CBuilder.library(
    name: _windowsLibraryBaseName,
    assetName: _assetName,
    language: Language.cpp,
    sources: _windowsSources,
    includes: ['native/include', 'native/windows'],
    std: 'c++17',
    flags: windowsCommonCppFlags,
    defines: windowsCommonDefines,
    libraries: ['ole32', 'uiautomationcore'],
  ).run(input: input, output: output);
}

Future<void> buildDesktopAutopasteMacosAsset(
  BuildInput input,
  BuildOutputBuilder output,
) async {
  if (!matchesTarget(input, os: OS.macOS)) {
    return;
  }

  for (final source in _macosSources) {
    requireSourceFile(
      input,
      relativePath: source,
      label: 'desktop_autopaste macOS',
    );
  }
  requireSourceFile(
    input,
    relativePath: 'native/include/desktop_autopaste_ffi.h',
    label: 'desktop_autopaste ffi header',
  );

  await CBuilder.library(
    name: _macosLibraryBaseName,
    assetName: _assetName,
    language: Language.objectiveC,
    sources: _macosSources,
    includes: ['native/include'],
    std: 'c++17',
    flags: appleObjectiveCArcFlags,
    frameworks: appleFrameworks,
    libraries: appleLibraries,
  ).run(input: input, output: output);
}
