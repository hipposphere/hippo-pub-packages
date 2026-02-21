import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speech_utils/speech_utils.dart';

const _maxFirstAudioLatencyMs = int.fromEnvironment(
  'SPEECH_UTILS_MAX_FIRST_AUDIO_LATENCY_MS',
  defaultValue: 1200,
);
const _firstAudioCaptureTimeoutMs = int.fromEnvironment(
  'SPEECH_UTILS_FIRST_AUDIO_TIMEOUT_MS',
  defaultValue: 6000,
);

final _supportsDesktopMicrophonePipeline =
    Platform.isMacOS || Platform.isWindows;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'captures first microphone audio chunk quickly',
    (tester) async {
      final recorder = NativeAudioRecorder();
      await _ensureRecorderReady(recorder: recorder);
      expect(_maxFirstAudioLatencyMs, greaterThan(0));
      expect(_firstAudioCaptureTimeoutMs, greaterThan(_maxFirstAudioLatencyMs));

      final stopwatch = Stopwatch()..start();
      try {
        final stream = await recorder.startStream(
          config: const AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
            framesPerChunk: 256,
          ),
          pollInterval: const Duration(milliseconds: 10),
          readSampleCapacity: 4096,
        );

        final firstChunk = await stream
            .firstWhere((chunk) => chunk.isNotEmpty)
            .timeout(Duration(milliseconds: _firstAudioCaptureTimeoutMs));
        stopwatch.stop();

        final firstAudioLatencyMs = stopwatch.elapsedMilliseconds;
        debugPrint(
          'First microphone chunk in ${firstAudioLatencyMs}ms '
          '(${firstChunk.lengthInBytes} bytes).',
        );

        expect(firstChunk, isNotEmpty);
        expect(
          firstAudioLatencyMs,
          lessThanOrEqualTo(_maxFirstAudioLatencyMs),
          reason:
              'Expected first captured microphone audio <= ${_maxFirstAudioLatencyMs}ms. '
              'Tune threshold with --dart-define=SPEECH_UTILS_MAX_FIRST_AUDIO_LATENCY_MS=<ms>.',
        );
      } finally {
        await recorder.stop();
        await recorder.dispose();
      }
    },
    skip: !_supportsDesktopMicrophonePipeline,
  );

  testWidgets(
    'records microphone through VAD segmentation and native AAC encoding',
    (tester) async {
      final recorder = NativeAudioRecorder();
      final encoder = NativeAacEncoder();
      final metadataReader = NativeAudioMetadataReader();
      Directory? outputDirectory;

      await _ensureRecorderReady(recorder: recorder);
      expect(
        await encoder.isAvailable(),
        isTrue,
        reason:
            'NativeAacEncoder must be available for end-to-end AAC pipeline coverage.',
      );
      expect(
        await metadataReader.isAvailable(),
        isTrue,
        reason:
            'NativeAudioMetadataReader must be available to validate encoded segment output.',
      );

      try {
        outputDirectory = await Directory.systemTemp.createTemp(
          'speech_utils_mic_pipeline_it_',
        );
        final segmentStream = await recorder.startWithVadSegmentation(
          outputDirectory: outputDirectory,
          splitOptions: const PauseSplitOptions(
            sampleRateHz: 16000,
            channelCount: 1,
            frameDuration: Duration(milliseconds: 20),
            minSpeechDuration: Duration(milliseconds: 20),
            minSilenceDuration: Duration(milliseconds: 120),
            preSpeechPadding: Duration.zero,
            postSpeechPadding: Duration.zero,
          ),
          config: AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
            framesPerChunk: 256,
            encoding: AudioEncodingConfig(
              encoder: AudioEncoder.aacLc,
              bitrateBps: 64000,
              aacEncoder: encoder,
            ),
          ),
          vadConfig: const SpeechVadConfig.energyOnly(
            energy: EnergyVadConfig(
              primaryRmsThreshold: 0.0,
              secondaryRmsThreshold: 0.0,
              minZeroCrossingRate: 0.0,
            ),
          ),
          pollInterval: const Duration(milliseconds: 10),
          readSampleCapacity: 4096,
        );

        final firstSegmentFuture = segmentStream.first.timeout(
          const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
            'No VAD segment emitted within timeout. Check mic routing/permission.',
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 900));
        await recorder.stop();

        final segment = await firstSegmentFuture;
        final encodedSegmentFile = File(segment.file.path);

        expect(segment.fileExtension, equals('m4a'));
        expect(await encodedSegmentFile.exists(), isTrue);
        expect(await encodedSegmentFile.length(), greaterThan(0));
        expect(segment.voiceActivity.speechFrameCount ?? 0, greaterThan(0));
        expect(segment.voiceActivity.analyzedFrameCount ?? 0, greaterThan(0));
        expect(segment.metrics.inputPcmByteCount, greaterThan(0));
        expect(segment.metrics.outputByteCount, greaterThan(0));

        final metadata = await metadataReader.readAudioMetadata(
          inputPath: encodedSegmentFile.path,
        );
        expect(
          metadata.duration,
          greaterThan(const Duration(milliseconds: 100)),
        );
        expect(
          metadata.codec?.toLowerCase(),
          contains('aac'),
          reason: 'Encoded VAD segment must be AAC.',
        );
      } finally {
        await recorder.stop();
        await recorder.dispose();
        if (outputDirectory != null) {
          try {
            await outputDirectory.delete(recursive: true);
          } on Object {
            // Best-effort cleanup only.
          }
        }
      }
    },
    skip: !_supportsDesktopMicrophonePipeline,
  );
}

Future<void> _ensureRecorderReady({
  required NativeAudioRecorder recorder,
}) async {
  expect(
    await recorder.isAvailable(),
    isTrue,
    reason: 'NativeAudioRecorder must be available on this runtime.',
  );

  var permissionGranted = await recorder.hasPermission();
  if (!permissionGranted) {
    permissionGranted = await recorder.requestPermission();
  }

  expect(
    permissionGranted,
    isTrue,
    reason:
        'Microphone permission is required for this integration test. '
        'Grant mic permission and rerun.',
  );
}
