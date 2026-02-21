import 'dart:io';

import 'package:ffigen/ffigen.dart' as fg;
import 'package:swiftgen/swiftgen.dart';

Future<void> main() async {
  final packageRoot = Directory.current.uri;
  final swiftApiFile = packageRoot.resolve(
    'native/macos/desktop_autopaste_macos_ffi.swift',
  );
  final generatedDartFile = packageRoot.resolve(
    'lib/src/ffi/generated/desktop_autopaste_macos_swiftgen_bindings.dart',
  );
  final generatedObjcFile = packageRoot.resolve(
    'native/macos/generated/desktop_autopaste_macos_swiftgen_bindings.m',
  );

  final target = await Target.host();

  await SwiftGenerator(
    target: target,
    inputs: [
      ObjCCompatibleSwiftFileInput(files: [swiftApiFile]),
    ],
    include: (declaration) => declaration.name == 'DesktopAutopasteMacosBridge',
    output: Output(
      module: 'desktop_autopaste',
      dartFile: generatedDartFile,
      objectiveCFile: generatedObjcFile,
      preamble: '// Experimental swiftgen-generated bindings for macOS.\n',
      assetId:
          'package:desktop_autopaste/src/ffi/generated/desktop_autopaste_macos_swiftgen_bindings.dart',
    ),
    ffigen: FfiGeneratorOptions(
      objectiveC: fg.ObjectiveC(
        interfaces: fg.Interfaces(
          include: (decl) => decl.originalName == 'DesktopAutopasteMacosBridge',
        ),
      ),
    ),
  ).generate(logger: null);

  final objectiveCFile = File.fromUri(generatedObjcFile);
  stdout.writeln('Generated swiftgen bindings:');
  stdout.writeln('  ${generatedDartFile.toFilePath()}');
  if (objectiveCFile.existsSync()) {
    stdout.writeln('  ${generatedObjcFile.toFilePath()}');
  } else {
    stdout.writeln(
      '  (note) Objective-C bindings file was not emitted by current swiftgen build.',
    );
  }
}
