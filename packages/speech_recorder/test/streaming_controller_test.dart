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
        );
      },
    );

    try {
      final session = await controller.startStreaming(
        SpeechRecorderStreamingOptions(
          pauseSplitOptions: const PauseSplitOptions(
            sampleRateHz: 16000,
            channelCount: 1,
            frameDuration: Duration(milliseconds: 20),
            minSpeechDuration: Duration(milliseconds: 120),
            minSilenceDuration: Duration(milliseconds: 600),
          ),
          vadConfig: const SpeechVadConfig.energyOnly(
            energy: EnergyVadConfig(
              primaryRmsThreshold: 0.005,
              secondaryRmsThreshold: 0.003,
              minZeroCrossingRate: 0.02,
            ),
          ),
          onSegmentFinished: emittedSegments.add,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await controller.stop(session);

      expect(delayedEncoder.encodePcm16BytesToAacCallCount, 1);
      expect(emittedSegments, hasLength(1));
      expect(session.segmentsSubject.value, hasLength(1));
      expect(
        session.segmentsSubject.value.single.file.path,
        emittedSegments.single.file.path,
      );

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

  test('streaming can manually split without VAD options', () async {
    final outputDirectory = await Directory.systemTemp.createTemp(
      'speech_recorder_manual_split_',
    );
    final emittedSegments = <SpeechRecorderSegmentData>[];
    final recorder = NativeAudioRecorder.custom(
      platformImplementation: _FakeRecorderPlatformImplementation(
        pcmChunk: _sinePcmChunk(
          sampleRateHz: 16000,
          duration: const Duration(milliseconds: 220),
        ),
      ),
    );

    final controller = SpeechRecorderController(
      audioRecorder: recorder,
      optionsBuilder: () async {
        return SpeechRecorderOptions(
          path: '${outputDirectory.path}${Platform.pathSeparator}session.wav',
          recordConfig: const AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
            encoding: AudioEncodingConfig(encoder: AudioEncoder.wav),
          ),
        );
      },
    );

    try {
      final session = await controller.startStreaming(
        SpeechRecorderStreamingOptions(
          splitMode: AudioSegmentSplitMode.manual,
          onSegmentFinished: emittedSegments.add,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 60));
      await session.splitSegment();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await controller.stop(session);

      expect(emittedSegments, hasLength(1));
      expect(session.segmentsSubject.value, hasLength(1));
      expect(
        session.segmentsSubject.value.single.metrics.speechProbability,
        isNull,
      );
      expect(session.segmentsSubject.value.single.sampleRateHz, 16000);
    } finally {
      await controller.dispose();
      if (await outputDirectory.exists()) {
        await outputDirectory.delete(recursive: true);
      }
    }
  });

  test('streaming pause keeps the native stream session open', () async {
    final outputDirectory = await Directory.systemTemp.createTemp(
      'speech_recorder_streaming_pause_',
    );
    final events = <String>[];
    final recorder = NativeAudioRecorder.custom(
      platformImplementation: _FakeRecorderPlatformImplementation(
        pcmChunk: Uint8List(0),
        events: events,
      ),
    );

    final controller = SpeechRecorderController(
      audioRecorder: recorder,
      optionsBuilder: () async {
        return SpeechRecorderOptions(
          path: '${outputDirectory.path}${Platform.pathSeparator}session.wav',
          recordConfig: const AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
          ),
        );
      },
    );

    try {
      final session = await controller.startStreaming(
        const SpeechRecorderStreamingOptions(
          splitMode: AudioSegmentSplitMode.manual,
        ),
      );

      await controller.pause(session);
      expect(session.stateSubject.value, SpeechRecorderSessionState.paused);
      await controller.resume(session);
      expect(session.stateSubject.value, SpeechRecorderSessionState.recording);
      await controller.stop(session);

      expect(events, <String>['startStream', 'stop']);
    } finally {
      await controller.dispose();
      if (await outputDirectory.exists()) {
        await outputDirectory.delete(recursive: true);
      }
    }
  });

  test(
    'prepareForAppExit stops active session and releases recorder resources',
    () async {
      final outputDirectory = await Directory.systemTemp.createTemp(
        'speech_recorder_prepare_exit_',
      );
      final events = <String>[];
      final recorder = NativeAudioRecorder.custom(
        platformImplementation: _FakeRecorderPlatformImplementation(
          pcmChunk: Uint8List(0),
          events: events,
        ),
      );

      final controller = SpeechRecorderController(
        audioRecorder: recorder,
        optionsBuilder: () async {
          return SpeechRecorderOptions(
            path: '${outputDirectory.path}${Platform.pathSeparator}session.wav',
            recordConfig: const AudioRecorderConfig(),
          );
        },
      );

      try {
        await recorder.setContinousRecording(true);
        final session = await controller.start();
        await controller.prepareForAppExit();

        expect(session.stateSubject.value, SpeechRecorderSessionState.stopped);
        expect(controller.sessionSubject.value, isNull);
        expect(events, <String>[
          'continuous:true',
          'startFile',
          'continuous:false',
          'stop',
          'reset',
        ]);
      } finally {
        await controller.dispose();
        if (await outputDirectory.exists()) {
          await outputDirectory.delete(recursive: true);
        }
      }
    },
  );
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
  _FakeRecorderPlatformImplementation({
    required this._pcmChunk,
    List<String>? events,
  }) : events = events ?? <String>[],
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
  final List<String> events;
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
    events.add('startFile');
    _isRecording = true;
  }

  @override
  void startStream({required AudioRecorderConfig config}) {
    events.add('startStream');
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
    events.add('stop');
    _isRecording = false;
  }

  @override
  void reset() {
    events.add('reset');
    _isRecording = false;
    _chunkConsumed = false;
  }

  @override
  void setContinousRecording(
    bool enabled, {
    AudioRecorderConfig config = const AudioRecorderConfig(),
  }) {
    events.add('continuous:$enabled');
  }

  @override
  bool isRecording() => _isRecording;

  @override
  Amplitude getAmplitude() => const Amplitude(current: -24, max: -12);
}
