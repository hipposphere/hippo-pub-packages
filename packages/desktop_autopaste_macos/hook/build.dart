import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

const _assetName = 'src/generated/desktop_autopaste_macos_bindings.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets ||
        input.config.code.targetOS != OS.macOS) {
      return;
    }

    final architecture = switch (input.config.code.targetArchitecture) {
      Architecture.arm64 => 'arm64',
      Architecture.x64 => 'x86_64',
      final value => throw UnsupportedError(
        'Unsupported desktop_autopaste macOS architecture: $value',
      ),
    };
    final source = File.fromUri(
      input.packageRoot.resolve(
        'native/macos/desktop_autopaste_macos_ffi.swift',
      ),
    );
    output.dependencies.add(source.absolute.uri);

    final libraryName = input.config.code.targetOS.dylibFileName(
      'desktop_autopaste_macos',
    );
    final outputUri = input.outputDirectory.resolve(
      'desktop_autopaste/macos/$architecture/$libraryName',
    );
    final outputFile = File.fromUri(outputUri);
    outputFile.parent.createSync(recursive: true);
    final moduleCache = Directory.fromUri(
      input.outputDirectory.resolve('swift-module-cache/$architecture/'),
    )..createSync(recursive: true);

    final result = await Process.run('xcrun', [
      '--sdk',
      'macosx',
      'swiftc',
      '-module-cache-path',
      moduleCache.path,
      '-emit-library',
      '-module-name',
      'desktop_autopaste',
      '-o',
      outputFile.path,
      source.path,
      '-framework',
      'AppKit',
      '-framework',
      'ApplicationServices',
      '-framework',
      'Foundation',
      '-target',
      '$architecture-apple-macosx10.15',
    ]);
    if (result.exitCode != 0) {
      throw StateError(
        'Failed to compile desktop_autopaste macOS library.\n'
        'stdout:\n${result.stdout}\n'
        'stderr:\n${result.stderr}',
      );
    }

    final architectureCheck = await Process.run('lipo', [
      outputFile.path,
      '-verify_arch',
      architecture,
    ]);
    if (architectureCheck.exitCode != 0) {
      throw StateError(
        'desktop_autopaste macOS library does not contain $architecture: '
        '${architectureCheck.stderr}',
      );
    }

    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: _assetName,
        linkMode: DynamicLoadingBundled(),
        file: outputUri,
      ),
    );
  });
}
