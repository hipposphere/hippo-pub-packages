import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import 'contract_model.dart';
import 'generator.dart';
import 'version.dart';

class HippoBluetoothClientBuilderRunner extends CommandRunner<void> {
  HippoBluetoothClientBuilderRunner() : super('hippo-bluetooth-client-builder', '') {
    argParser.addOption('input', abbr: 'i', help: 'Path to BLE contract.json input file.');
    argParser.addOption('output', abbr: 'o', help: 'Path to generated Dart output file.');
    argParser.addOption(
      'class-prefix',
      abbr: 'p',
      help: 'Optional class prefix for generated types.',
    );
    argParser.addOption(
      'library-name',
      abbr: 'l',
      help: 'Optional Dart library name for generated output.',
    );
    argParser.addOption(
      'default-codec',
      defaultsTo: 'bytes',
      help: 'Default channel codec. One of: bytes, utf8, jsonMap.',
    );
    argParser.addOption(
      'codec-overrides',
      help: 'Optional JSON file with protocol/channel codec overrides.',
    );
    argParser.addFlag('version', negatable: false, help: 'Print the tool version.');
  }

  @override
  String get description => '''
Generate ready-to-use Dart BLE client/service bindings from a BLE contract JSON.

Example:

  dart run hippo_bluetooth_client_builder:hippo_bluetooth_client_builder
    --input ./ble-contract.json
    --output ./lib/ble/generated_ble_client.dart
    --class-prefix Device

Codec overrides file format:

  {
    "auth/challenge": "jsonMap",
    "device-control/status": "utf8"
  }
''';

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      stdout.writeln(hippoBluetoothClientBuilderVersion);
      return;
    }

    if (topLevelResults['help'] != false) {
      return super.runCommand(topLevelResults);
    }

    final inputPath = topLevelResults['input'] as String?;
    final outputPath = topLevelResults['output'] as String?;
    if (inputPath == null || inputPath.trim().isEmpty) {
      throw const FormatException('--input is required.');
    }
    if (outputPath == null || outputPath.trim().isEmpty) {
      throw const FormatException('--output is required.');
    }

    final inputFile = File(inputPath);
    if (!inputFile.existsSync()) {
      throw FileSystemException('Input file does not exist.', inputPath);
    }

    final outputFile = File(outputPath);
    outputFile.parent.createSync(recursive: true);

    final defaultCodec = GeneratedChannelCodec.parse(
      (topLevelResults['default-codec'] as String?) ?? 'bytes',
    );

    Map<String, GeneratedChannelCodec> codecOverrides = const <String, GeneratedChannelCodec>{};
    final overridesPath = topLevelResults['codec-overrides'] as String?;
    if (overridesPath != null && overridesPath.trim().isNotEmpty) {
      final overridesFile = File(overridesPath);
      if (!overridesFile.existsSync()) {
        throw FileSystemException('Codec overrides file does not exist.', overridesPath);
      }
      final rawOverrides = jsonDecode(await overridesFile.readAsString());
      codecOverrides = parseCodecOverridesJsonMap(rawOverrides);
    }

    final contract = parseBleContractJsonString(await inputFile.readAsString());
    final resolved = resolveBleContract(contract);
    final generated = generateBleClientDart(
      contract: resolved,
      options: BleClientCodegenOptions(
        classPrefix: topLevelResults['class-prefix'] as String?,
        libraryName: topLevelResults['library-name'] as String?,
        defaultCodec: defaultCodec,
        codecOverrides: codecOverrides,
      ),
      sourceContractPath: path.normalize(inputPath),
    );

    await outputFile.writeAsString('$generated\n');
    stdout.writeln('Generated BLE client: ${path.normalize(outputPath)}');
  }
}
