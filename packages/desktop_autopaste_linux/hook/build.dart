import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const _assetName = 'src/generated/desktop_autopaste_linux_bindings.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets ||
        input.config.code.targetOS != OS.linux) {
      return;
    }

    await CBuilder.library(
      name: 'desktop_autopaste_linux',
      assetName: _assetName,
      language: Language.cpp,
      sources: const ['native/linux/desktop_autopaste_linux_ffi.cpp'],
      includes: const ['native/include'],
      std: 'c++17',
      flags: const ['-O2', '-pthread'],
      libraries: const ['X11', 'Xtst', 'pthread'],
    ).run(input: input, output: output);
  });
}
