import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_recorder/speech_recorder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('streaming stop waits for final segment encoding', () async {
    final outputDirectory = await Directory.systemTemp.createTemp(
      'speech_recorder_streaming_stop_',
    );
    final emittedSegments = <SpeechRecorderSegmentData>[];
    final delayedEncoder = _DelayedAacEncoder(
      const Duration(milliseconds: 2500),
    );
    final recorder = NativeAudioRecorder.custom(
      platformImplementation: _FakeRecorderPlatformImplementation(
        pcmChunk: _sinePcmChunk(
          sampleRateHz: 16000,
          duration: const Duration(milliseconds: 420),
        ),
      ),
    );

    final controller = SpeechRecorderController(
      audioRecorder: recorder,
      optionsBuilder: () async {
        return SpeechRecorderOptions(
          path: '${outputDirectory.path}${Platform.pathSeparator}session.m4a',
          recordConfig: AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
            encoding: AudioEncodingConfig(
              encoder: AudioEncoder.aacLc,
              audioEncoder: delayedEncoder,
            ),
          ),
          vadConfig: const SpeechVadConfig.energyOnly(
            energy: EnergyVadConfig(
              primaryRmsThreshold: 0.005,
              secondaryRmsThreshold: 0.003,
              minZeroCrossingRate: 0.02,
            ),
          ),
          streaming: SpeechRecorderStreamingOptions(
            pauseSplitOptions: const PauseSplitOptions(
              sampleRateHz: 16000,
              channelCount: 1,
              frameDuration: Duration(milliseconds: 20),
              minSpeechDuration: Duration(milliseconds: 120),
              minSilenceDuration: Duration(milliseconds: 600),
            ),
            onSegmentFinished: emittedSegments.add,
          ),
        );
      },
    );

    try {
      final session = await controller.start();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await controller.stop(session);

      expect(delayedEncoder.encodePcm16BytesToAacCallCount, 1);
      expect(emittedSegments, hasLength(1));

      final outputFile = File(emittedSegments.single.file.path);
      expect(await outputFile.exists(), isTrue);
      expect(await outputFile.length(), greaterThan(0));
    } finally {
      await controller.dispose();
      if (await outputDirectory.exists()) {
        await outputDirectory.delete(recursive: true);
      }
    }
  });
}

Uint8List _sinePcmChunk({
  required int sampleRateHz,
  required Duration duration,
  double frequencyHz = 440.0,
  double amplitude = 0.7,
}) {
  final sampleCount =
      ((sampleRateHz * duration.inMicroseconds) ~/
      Duration.microsecondsPerSecond);
  final samples = Int16List(sampleCount);
  for (var i = 0; i < sampleCount; i++) {
    final wave = math.sin((2 * math.pi * frequencyHz * i) / sampleRateHz);
    final scaled = (wave * amplitude * 32767).round();
    samples[i] = (scaled.clamp(-32768, 32767) as num).toInt();
  }
  return Uint8List.view(samples.buffer);
}

final class _DelayedAacEncoder implements AacEncoder {
  _DelayedAacEncoder(this.delay);

  final Duration delay;

  int encodePcm16BytesToAacCallCount = 0;

  @override
  Future<void> encodePcm16BytesToAac({
    required Uint8List pcm16leBytes,
    required int sampleRateHz,
    required int channelCount,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    encodePcm16BytesToAacCallCount++;
    await Future<void>.delayed(delay);
    final file = File(outputPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(<int>[1, 2, 3, 4], flush: true);
  }

  @override
  Future<void> encodePcm16FileToAac({
    required String inputPath,
    required int sampleRateHz,
    required int channelCount,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    throw UnimplementedError(
      'encodePcm16FileToAac is not used by this streaming controller test.',
    );
  }

  @override
  Future<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    throw UnimplementedError(
      'encodeAudioFileToAac is not used by this streaming controller test.',
    );
  }
}

final class _FakeRecorderPlatformImplementation
    extends NativeAudioRecorderPlatformImplementation {
  _FakeRecorderPlatformImplementation({required Uint8List pcmChunk})
    : _pcmChunk = pcmChunk,
      super(
        platform: NativeAudioRecorderPlatform.windows,
        supportsInputSelection: true,
        capabilities: const NativeAudioRecorderCapabilities(
          supportsNoiseCancellation: false,
          supportsEchoCancellation: false,
          supportsVoiceIsolation: false,
        ),
      );

  final Uint8List _pcmChunk;
  bool _isRecording = false;
  bool _chunkConsumed = false;

  @override
  bool isAvailable() => true;

  @override
  bool hasPermission() => true;

  @override
  bool requestPermission() => true;

  @override
  List<InputDevice> listInputDevices() => const <InputDevice>[];

  @override
  void startFile({
    required String outputPath,
    required AudioRecorderConfig config,
  }) {
    _isRecording = true;
  }

  @override
  void startStream({required AudioRecorderConfig config}) {
    _isRecording = true;
    _chunkConsumed = false;
  }

  @override
  Uint8List readStream({required int maxSamples}) {
    if (!_isRecording || _chunkConsumed) {
      return Uint8List(0);
    }
    _chunkConsumed = true;
    return Uint8List.fromList(_pcmChunk);
  }

  @override
  void stop() {
    _isRecording = false;
  }

  @override
  void reset() {
    _isRecording = false;
    _chunkConsumed = false;
  }

  @override
  bool isRecording() => _isRecording;

  @override
  Amplitude getAmplitude() => const Amplitude(current: -24, max: -12);
}
