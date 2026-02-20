import 'dart:io';
import 'dart:typed_data';

import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NativeAacEncoder', () {
    test('uses macOS native encoder with wav intermediary for pcm bytes', () async {
      late String usedInputPath;
      late String usedOutputPath;
      late int usedBitrateBps;
      late Uint8List intermediateWavBytes;

      final outputDir = await Directory.systemTemp.createTemp('speech_utils_native_aac_test_');
      addTearDown(() async {
        await outputDir.delete(recursive: true);
      });
      final outputPath = '${outputDir.path}${Platform.pathSeparator}out.m4a';

      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.macOS,
        macosAvailabilityFn: () => true,
        macosEncodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          usedInputPath = inputPath;
          usedOutputPath = outputPath;
          usedBitrateBps = bitrateBps;
          intermediateWavBytes = File(inputPath).readAsBytesSync();
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

      expect(usedOutputPath, outputPath);
      expect(usedBitrateBps, 56000);
      expect(usedInputPath, isNotEmpty);
      expect(intermediateWavBytes.sublist(0, 4), orderedEquals(<int>[82, 73, 70, 70]));
      expect(intermediateWavBytes.sublist(8, 12), orderedEquals(<int>[87, 65, 86, 69]));
      expect(intermediateWavBytes.sublist(44), orderedEquals(pcm));
    });

    test('throws UnsupportedError on unsupported platform', () {
      final encoder = NativeAacEncoder(platform: NativeAacPlatform.unsupported);

      expect(
        () => encoder.encodeAudioFileToAac(inputPath: 'in.wav', outputPath: 'out.m4a'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('throws AacEncodingException when macOS native encoder fails', () {
      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.macOS,
        macosAvailabilityFn: () => true,
        macosEncodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          throw AacEncodingException(
            'macOS native AAC encoder failed',
            exitCode: 1,
            stderr: 'boom',
          );
        },
      );

      expect(
        () => encoder.encodeAudioFileToAac(inputPath: 'in.wav', outputPath: 'out.m4a'),
        throwsA(isA<AacEncodingException>()),
      );
    });

    test('propagates macOS availability probe', () async {
      final encoder = NativeAacEncoder(
        platform: NativeAacPlatform.macOS,
        macosAvailabilityFn: () => true,
        macosEncodeFn: ({required inputPath, required outputPath, required bitrateBps}) {},
      );

      expect(await encoder.isAvailable(), isTrue);
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
