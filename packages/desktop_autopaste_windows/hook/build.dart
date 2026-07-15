import 'package:code_assets/code_assets.dart';
import 'package:hippo_native_deps/hippo_native_deps.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const _assetName = 'src/generated/desktop_autopaste_windows_bindings.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final target = input.config.code;
    if (!input.config.buildCodeAssets ||
        target.targetOS != OS.windows ||
        target.targetArchitecture != Architecture.x64) {
      return;
    }

    final nativeDepsIncludes = requireNativeDepsWindowsIncludeDirs(input);
    await CBuilder.library(
      name: 'desktop_autopaste_windows',
      assetName: _assetName,
      language: Language.cpp,
      sources: const [
        'native/windows/desktop_autopaste_windows_ffi.cpp',
        'native/windows/autopaste_text.cpp',
        'native/windows/focused_text_field_context.cpp',
      ],
      includes: ['native/include', 'native/windows', ...nativeDepsIncludes],
      std: 'c++17',
      flags: const ['/EHsc', '/O2'],
      defines: const {
        'UNICODE': '1',
        '_UNICODE': '1',
        'WIN32_LEAN_AND_MEAN': '1',
        'NOMINMAX': '1',
      },
      libraries: const ['ole32', 'oleaut32', 'user32', 'uiautomationcore'],
    ).run(input: input, output: output);
  });
}
