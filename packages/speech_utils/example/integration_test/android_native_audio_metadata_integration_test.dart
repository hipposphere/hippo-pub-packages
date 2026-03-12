import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_utils/speech_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'android native metadata reader reports AAC details for encoded files',
    (tester) async {
      final encoder = NativeAudioEncoder();
      final metadataReader = NativeAudioMetadataReader();
      Directory? outputDirectory;

      expect(
        await encoder.isAvailable(),
        isTrue,
        reason:
            'NativeAudioEncoder must be available for Android AAC metadata coverage.',
      );
      expect(
        await metadataReader.isAvailable(),
        isTrue,
        reason:
            'NativeAudioMetadataReader must be available to expose codec/container details.',
      );

      try {
        final tempRoot = await getTemporaryDirectory();
        outputDirectory = Directory(
          '${tempRoot.path}${Platform.pathSeparator}speech_utils_android_metadata_it_${DateTime.now().millisecondsSinceEpoch}',
        );
        await outputDirectory.create(recursive: true);

        final pcm16leBytes = _buildSineWavePcm16le(
          sampleRateHz: 16000,
          channelCount: 1,
          duration: const Duration(milliseconds: 900),
        );

        for (var i = 0; i < 6; i++) {
          final outputPath =
              '${outputDirectory.path}${Platform.pathSeparator}metadata_probe_$i.m4a';
          await encoder.encodePcm16BytesToAac(
            pcm16leBytes: pcm16leBytes,
            sampleRateHz: 16000,
            channelCount: 1,
            outputPath: outputPath,
            bitrateKbps: 64,
          );

          final metadata = await metadataReader.readAudioMetadata(
            inputPath: outputPath,
          );
          debugPrint(
            'metadata_probe_$i: duration=${metadata.duration.inMilliseconds}ms '
            'sampleRate=${metadata.sampleRateHz} channels=${metadata.channelCount} '
            'bitrate=${metadata.bitrateBps} container=${metadata.containerFormat} '
            'codec=${metadata.codec} profile=${metadata.codecProfile}',
          );

          expect(File(outputPath).existsSync(), isTrue);
          expect(File(outputPath).lengthSync(), greaterThan(0));
          expect(
            metadata.duration,
            greaterThan(const Duration(milliseconds: 700)),
          );
          expect(
            metadata.duration,
            lessThan(const Duration(milliseconds: 1200)),
          );
          expect(metadata.sampleRateHz, 16000);
          expect(metadata.channelCount, 1);
          expect(metadata.containerFormat?.toLowerCase(), anyOf('m4a', 'mp4'));
          expect(
            metadata.codec?.toLowerCase() ?? '',
            anyOf(contains('aac'), contains('mp4a')),
          );
          expect(
            metadata.codecProfile?.trim().isNotEmpty ?? false,
            isTrue,
            reason: 'AAC codec profile should be visible for metadata info UI.',
          );
        }
      } finally {
        if (outputDirectory != null) {
          try {
            await outputDirectory.delete(recursive: true);
          } on Object {
            // Best-effort cleanup only.
          }
        }
      }
    },
    skip: !Platform.isAndroid,
  );
}

Uint8List _buildSineWavePcm16le({
  required int sampleRateHz,
  required int channelCount,
  required Duration duration,
}) {
  final sampleCount =
      (sampleRateHz * duration.inMicroseconds / Duration.microsecondsPerSecond)
          .round();
  final output = Int16List(sampleCount * channelCount);

  for (var frame = 0; frame < sampleCount; frame++) {
    final value =
        (math.sin((2 * math.pi * 220.0 * frame) / sampleRateHz) * 0.6 * 32767.0)
            .round();
    for (var channel = 0; channel < channelCount; channel++) {
      output[(frame * channelCount) + channel] = value;
    }
  }

  return Uint8List.view(output.buffer);
}
