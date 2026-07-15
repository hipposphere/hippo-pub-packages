import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:path/path.dart' as p;

const _source = 'native/android/speech_utils_android_audio_encoder.cpp';
const _encoderAsset = 'src/generated/android_audio_encoder_bindings.dart';
const _runtimeAsset = 'src/generated/android_cxx_runtime_bindings.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets ||
        input.config.code.targetOS != OS.android) {
      return;
    }

    final source = File.fromUri(input.packageRoot.resolve(_source));
    if (!source.existsSync()) {
      throw StateError('Missing Android AAC source at ${source.path}.');
    }
    output.dependencies.add(source.absolute.uri);

    final architecture = input.config.code.targetArchitecture;
    final targetTriple = switch (architecture) {
      Architecture.arm => 'armv7a-linux-androideabi',
      Architecture.arm64 => 'aarch64-linux-android',
      Architecture.ia32 => 'i686-linux-android',
      Architecture.x64 => 'x86_64-linux-android',
      Architecture.riscv64 => 'riscv64-linux-android',
      _ => throw UnsupportedError(
        'Unsupported Android AAC architecture: $architecture',
      ),
    };
    final configuredApi = input.config.code.android.targetNdkApi;
    final api = configuredApi < 26 ? 26 : configuredApi;

    await CBuilder.library(
      name: 'speech_utils_android_audio_encoder',
      assetName: _encoderAsset,
      language: Language.cpp,
      sources: const [_source],
      cppLinkStdLib: 'c++_shared',
      std: 'c++17',
      flags: ['-O2', '--target=$targetTriple$api'],
      libraries: const ['android', 'mediandk', 'log'],
    ).run(input: input, output: output);

    final compiler = input.config.code.cCompiler?.compiler;
    if (compiler == null) {
      throw StateError('Missing Android C compiler configuration.');
    }
    final runtimeTriple = switch (architecture) {
      Architecture.arm => 'arm-linux-androideabi',
      Architecture.arm64 => 'aarch64-linux-android',
      Architecture.ia32 => 'i686-linux-android',
      Architecture.x64 => 'x86_64-linux-android',
      Architecture.riscv64 => 'riscv64-linux-android',
      _ => throw UnsupportedError(
        'Unsupported Android runtime architecture: $architecture',
      ),
    };
    final compilerFile = File.fromUri(compiler);
    final runtime = File(
      p.join(
        compilerFile.parent.parent.path,
        'sysroot',
        'usr',
        'lib',
        runtimeTriple,
        'libc++_shared.so',
      ),
    );
    if (!runtime.existsSync()) {
      throw StateError('Missing Android libc++ runtime at ${runtime.path}.');
    }
    output.dependencies.add(runtime.absolute.uri);
    final bundledUri = input.outputDirectory.resolve(
      'speech_utils_android/libc++_shared.so',
    );
    final bundled = File.fromUri(bundledUri)
      ..parent.createSync(recursive: true);
    runtime.copySync(bundled.path);
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: _runtimeAsset,
        linkMode: DynamicLoadingBundled(),
        file: bundledUri,
      ),
    );
  });
}
