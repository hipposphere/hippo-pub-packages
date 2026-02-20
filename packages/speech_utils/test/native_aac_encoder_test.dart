import 'dart:io';
import 'dart:typed_data';

import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NativeAacEncoder', () {
    test('uses afconvert with wav intermediary for pcm bytes', () async {
      late String usedExecutable;
      late List<String> usedArguments;
      late Uint8List intermediateWavBytes;

      final outputDir = await Directory.systemTemp.createTemp('speech_utils_native_aac_test_');
      addTearDown(() async {
        await outputDir.delete(recursive: true);
      });
      final outputPath = '${outputDir.path}${Platform.pathSeparator}out.m4a';

      final encoder = NativeAacEncoder(
        executable: 'afconvert-custom',
        platform: NativeAacPlatform.macOS,
        commandRunner: (executable, arguments) async {
          usedExecutable = executable;
          usedArguments = List<String>.from(arguments);

          final inputPath = arguments[arguments.length - 2];
          intermediateWavBytes = await File(inputPath).readAsBytes();
          return const NativeAacCommandResult(exitCode: 0, stderr: '');
        },
      );

      final pcm = Uint8List.fromList(<int>[1, 2, 3, 4]);
      await encoder.encodePcm16BytesToAac(
        pcm16leBytes: pcm,
        sampleRateHz: 16000,
        channelCount: 1,
        outputPath: outputPath,
        bitrateKbps: 56,
      );

      expect(usedExecutable, 'afconvert-custom');
      expect(usedArguments, containsAllInOrder(<Object>['-f', 'm4af', '-d', 'aac', '-b', '56000']));
      expect(usedArguments.last, outputPath);
      expect(intermediateWavBytes.sublist(0, 4), orderedEquals(<int>[82, 73, 70, 70]));
      expect(intermediateWavBytes.sublist(8, 12), orderedEquals(<int>[87, 65, 86, 69]));
      expect(intermediateWavBytes.sublist(44), orderedEquals(pcm));
    });

    test('throws UnsupportedError on unsupported platform', () {
      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.unsupported,
        commandRunner: (executable, arguments) async {
          return const NativeAacCommandResult(exitCode: 0, stderr: '');
        },
      );

      expect(
        () => encoder.encodeAudioFileToAac(inputPath: 'in.wav', outputPath: 'out.m4a'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('throws AacEncodingException on non-zero exit code', () {
      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.macOS,
        commandRunner: (executable, arguments) async {
          return const NativeAacCommandResult(exitCode: 1, stderr: 'boom');
        },
      );

      expect(
        () => encoder.encodeAudioFileToAac(inputPath: 'in.wav', outputPath: 'out.m4a'),
        throwsA(isA<AacEncodingException>()),
      );
    });

    test('uses windows ffi libavcodec path', () async {
      late String usedInputPath;
      late String usedOutputPath;
      late int usedBitrateBps;

      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.windows,
        windowsAvailabilityFn: () => true,
        windowsEncodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          usedInputPath = inputPath;
          usedOutputPath = outputPath;
          usedBitrateBps = bitrateBps;
        },
      );

      await encoder.encodeAudioFileToAac(
        inputPath: 'input.wav',
        outputPath: 'output.m4a',
        bitrateKbps: 64,
      );

      expect(usedInputPath, 'input.wav');
      expect(usedOutputPath, 'output.m4a');
      expect(usedBitrateBps, 64000);
    });

    test('propagates windows availability probe', () async {
      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.windows,
        windowsAvailabilityFn: () => true,
        windowsEncodeFn: ({required inputPath, required outputPath, required bitrateBps}) {},
      );

      expect(await encoder.isAvailable(), isTrue);
    });

    test('uses android ffi encoder path', () async {
      late String usedInputPath;
      late String usedOutputPath;
      late int usedBitrateBps;

      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.android,
        androidAvailabilityFn: () => true,
        androidEncodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          usedInputPath = inputPath;
          usedOutputPath = outputPath;
          usedBitrateBps = bitrateBps;
        },
      );

      await encoder.encodeAudioFileToAac(
        inputPath: 'input.wav',
        outputPath: 'output.m4a',
        bitrateKbps: 96,
      );

      expect(usedInputPath, 'input.wav');
      expect(usedOutputPath, 'output.m4a');
      expect(usedBitrateBps, 96000);
    });

    test('propagates android availability probe', () async {
      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.android,
        androidAvailabilityFn: () => true,
        androidEncodeFn: ({required inputPath, required outputPath, required bitrateBps}) {},
      );

      expect(await encoder.isAvailable(), isTrue);
    });

    test('uses iOS ffi encoder path', () async {
      late String usedInputPath;
      late String usedOutputPath;
      late int usedBitrateBps;

      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.iOS,
        iosAvailabilityFn: () => true,
        iosEncodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          usedInputPath = inputPath;
          usedOutputPath = outputPath;
          usedBitrateBps = bitrateBps;
        },
      );

      await encoder.encodeAudioFileToAac(
        inputPath: 'input.wav',
        outputPath: 'output.m4a',
        bitrateKbps: 72,
      );

      expect(usedInputPath, 'input.wav');
      expect(usedOutputPath, 'output.m4a');
      expect(usedBitrateBps, 72000);
    });

    test('propagates iOS availability probe', () async {
      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.iOS,
        iosAvailabilityFn: () => true,
        iosEncodeFn: ({required inputPath, required outputPath, required bitrateBps}) {},
      );

      expect(await encoder.isAvailable(), isTrue);
    });
  });
}
