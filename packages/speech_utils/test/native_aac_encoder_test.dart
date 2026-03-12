import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NativeAudioEncoder', () {
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

      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.macOS,
        availabilityFn: () => true,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          usedInputPath = inputPath;
          usedOutputPath = outputPath;
          usedBitrateBps = bitrateBps;
          intermediateWavBytes = File(inputPath).readAsBytesSync();
        },
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

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

    test('throws NativeAudioEncoderUnsupportedPlatformException on unsupported platform', () {
      var encodeCalled = false;
      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.unsupported,
        availabilityFn: () => true,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          encodeCalled = true;
        },
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

      expect(
        () => encoder.encodeAudioFileToAac(inputPath: 'in.wav', outputPath: 'out.m4a'),
        throwsA(isA<NativeAudioEncoderUnsupportedPlatformException>()),
      );
      expect(encodeCalled, isFalse);
    });

    test('throws AacEncodingException when macOS native encoder fails', () {
      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.macOS,
        availabilityFn: () => true,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          throw AacEncodingException(
            'macOS native AAC encoder failed',
            exitCode: 1,
            stderr: 'boom',
          );
        },
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

      expect(
        () => encoder.encodeAudioFileToAac(inputPath: 'in.wav', outputPath: 'out.m4a'),
        throwsA(isA<AacEncodingException>()),
      );
    });

    test('propagates macOS availability probe', () async {
      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.macOS,
        availabilityFn: () => true,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {},
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

      expect(await encoder.isAvailable(), isTrue);
    });

    test('delegates windows encode call to platform implementation', () async {
      late String usedInputPath;
      late String usedOutputPath;
      late int usedBitrateBps;

      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.windows,
        availabilityFn: () => true,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          usedInputPath = inputPath;
          usedOutputPath = outputPath;
          usedBitrateBps = bitrateBps;
        },
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

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
      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.windows,
        availabilityFn: () => true,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {},
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

      expect(await encoder.isAvailable(), isTrue);
    });

    test('delegates android encode call to platform implementation', () async {
      late String usedInputPath;
      late String usedOutputPath;
      late int usedBitrateBps;

      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.android,
        availabilityFn: () => true,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          usedInputPath = inputPath;
          usedOutputPath = outputPath;
          usedBitrateBps = bitrateBps;
        },
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

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
      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.android,
        availabilityFn: () => true,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {},
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

      expect(await encoder.isAvailable(), isTrue);
    });

    test('returns false when android availability probe throws', () async {
      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.android,
        availabilityFn: () => throw StateError('probe failed'),
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {},
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

      expect(await encoder.isAvailable(), isFalse);
    });

    test('attempts encode even when android availability probe returns false', () async {
      var encodeCalled = false;
      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.android,
        availabilityFn: () => false,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          encodeCalled = true;
        },
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

      await encoder.encodeAudioFileToAac(inputPath: 'input.wav', outputPath: 'output.m4a');
      expect(encodeCalled, isTrue);
    });

    test('delegates iOS encode call to platform implementation', () async {
      late String usedInputPath;
      late String usedOutputPath;
      late int usedBitrateBps;

      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.iOS,
        availabilityFn: () => true,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {
          usedInputPath = inputPath;
          usedOutputPath = outputPath;
          usedBitrateBps = bitrateBps;
        },
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

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
      final implementation = _FakeNativeAudioEncoderPlatformImplementation(
        platform: NativeAudioEncoderPlatform.iOS,
        availabilityFn: () => true,
        encodeFn: ({required inputPath, required outputPath, required bitrateBps}) {},
      );
      final encoder = NativeAudioEncoder.custom(platformImplementation: implementation);

      expect(await encoder.isAvailable(), isTrue);
    });
  });
}

class _FakeNativeAudioEncoderPlatformImplementation
    extends NativeAudioEncoderPlatformImplementation {
  _FakeNativeAudioEncoderPlatformImplementation({
    required super.platform,
    required this.availabilityFn,
    required this.encodeFn,
  });

  final bool Function() availabilityFn;
  final FutureOr<void> Function({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  })
  encodeFn;

  @override
  bool isAvailable() => availabilityFn();

  @override
  FutureOr<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    required int bitrateBps,
  }) {
    encodeFn(inputPath: inputPath, outputPath: outputPath, bitrateBps: bitrateBps);
  }
}
