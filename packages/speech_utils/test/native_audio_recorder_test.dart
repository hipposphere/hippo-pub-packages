import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:math' as math;

import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NativeAudioRecorder', () {
    test('supportsInputSelection reports capability by platform', () {
      NativeAudioRecorder recorderFor(NativeAudioRecorderPlatform platform) {
        return NativeAudioRecorder(
          platform: platform,
          availabilityFn: () => true,
          hasPermissionFn: () => true,
          requestPermissionFn: () => true,
          listInputDevicesFn: () => const <InputDevice>[],
          startFileFn:
              ({
                required outputPath,
                required sampleRateHz,
                required channelCount,
                required inputDeviceId,
              }) {},
          startStreamFn:
              ({
                required sampleRateHz,
                required channelCount,
                required framesPerChunk,
                required inputDeviceId,
              }) {},
          readStreamFn: ({required maxSamples}) => Uint8List(0),
          stopFn: () {},
          isRecordingFn: () => false,
        );
      }

      expect(recorderFor(NativeAudioRecorderPlatform.macOS).supportsInputSelection, isTrue);
      expect(recorderFor(NativeAudioRecorderPlatform.windows).supportsInputSelection, isTrue);
      expect(recorderFor(NativeAudioRecorderPlatform.iOS).supportsInputSelection, isTrue);
      expect(recorderFor(NativeAudioRecorderPlatform.unsupported).supportsInputSelection, isFalse);
    });

    test('starts file recording with configured sample rate/channels', () async {
      late String usedOutputPath;
      late int usedSampleRate;
      late int usedChannelCount;
      String? usedInputDeviceId;
      var stopCalls = 0;

      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.macOS,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {
              usedOutputPath = outputPath;
              usedSampleRate = sampleRateHz;
              usedChannelCount = channelCount;
              usedInputDeviceId = inputDeviceId;
            },
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {
          stopCalls++;
        },
        isRecordingFn: () => true,
      );

      await recorder.start(
        outputPath: '/tmp/recording.wav',
        config: const AudioRecorderConfig(sampleRateHz: 24000, channelCount: 2),
      );

      expect(usedOutputPath, '/tmp/recording.wav');
      expect(usedSampleRate, 24000);
      expect(usedChannelCount, 2);
      expect(usedInputDeviceId, isNull);

      await recorder.stop();
      expect(stopCalls, 1);
    });

    test('startStream drains native PCM chunks', () async {
      var readCalls = 0;
      var stopCalls = 0;
      String? usedInputDeviceId;

      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.windows,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {
              expect(sampleRateHz, 16000);
              expect(channelCount, 1);
              expect(framesPerChunk, 1024);
              usedInputDeviceId = inputDeviceId;
            },
        readStreamFn: ({required maxSamples}) {
          readCalls++;
          if (readCalls == 1) {
            return Uint8List.fromList(<int>[1, 2, 3, 4]);
          }
          return Uint8List(0);
        },
        stopFn: () {
          stopCalls++;
        },
        isRecordingFn: () => true,
      );

      final stream = await recorder.startStream(pollInterval: const Duration(milliseconds: 5));

      final firstChunk = await stream.first.timeout(const Duration(seconds: 1));
      expect(firstChunk, Uint8List.fromList(<int>[1, 2, 3, 4]));

      await recorder.stop();
      expect(stopCalls, 1);
      expect(readCalls, greaterThanOrEqualTo(1));
      expect(usedInputDeviceId, isNull);
    });

    test('throws when starting while already running', () async {
      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.macOS,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
      );

      await recorder.start(outputPath: '/tmp/file.wav');

      expect(() => recorder.start(outputPath: '/tmp/other.wav'), throwsA(isA<StateError>()));
    });

    test('unsupported platform reports unavailable and throws', () async {
      final recorder = NativeAudioRecorder(platform: NativeAudioRecorderPlatform.unsupported);

      expect(await recorder.isAvailable(), isFalse);
      expect(() => recorder.start(outputPath: '/tmp/file.wav'), throwsA(isA<UnsupportedError>()));
      expect(() => recorder.startStream(), throwsA(isA<UnsupportedError>()));
    });

    test('AudioRecorderConfig.inputDeviceId is forwarded to native start calls', () async {
      String? usedInputDeviceId;

      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.windows,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[
          InputDevice(id: 'mic-default', label: 'Default', isDefault: true),
          InputDevice(id: 'usb-mic', label: 'USB Mic'),
        ],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {
              usedInputDeviceId = inputDeviceId;
            },
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
      );

      await recorder.start(
        outputPath: '/tmp/recording.wav',
        config: const AudioRecorderConfig(inputDeviceId: 'mic-default'),
      );

      expect(usedInputDeviceId, 'mic-default');
      await recorder.stop();
    });

    test('start rejects unsupported encoding for native file output', () {
      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.macOS,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
      );

      expect(
        () => recorder.start(
          outputPath: '/tmp/file.wav',
          config: const AudioRecorderConfig(
            encoding: AudioEncodingConfig(encoder: AudioEncoder.flac),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('start uses direct macOS AAC file output for m4a', () async {
      final fakeAacEncoder = _FakeAacEncoder();
      late String nativeOutputPath;
      var stopCalls = 0;

      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.macOS,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {
              nativeOutputPath = outputPath;
            },
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {
          stopCalls++;
          File(nativeOutputPath).writeAsBytesSync(const <int>[1, 2, 3, 4], flush: true);
        },
        isRecordingFn: () => true,
      );

      await recorder.start(
        outputPath: '/tmp/recording.m4a',
        config: AudioRecorderConfig(
          sampleRateHz: 16000,
          channelCount: 1,
          encoding: AudioEncodingConfig(
            encoder: AudioEncoder.aacLc,
            bitrateBps: 64000,
            aacEncoder: fakeAacEncoder,
          ),
        ),
      );

      expect(nativeOutputPath, '/tmp/recording.m4a');
      await recorder.stop();

      expect(stopCalls, 1);
      expect(fakeAacEncoder.encodeAudioFileToAacCalls, 0);
    });

    test('start rejects non-m4a output for direct macOS AAC recording', () {
      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.macOS,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
      );

      expect(
        () => recorder.start(
          outputPath: '/tmp/recording.wav',
          config: const AudioRecorderConfig(
            encoding: AudioEncodingConfig(encoder: AudioEncoder.aacLc),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('onAmplitudeChanged emits native amplitude updates', () async {
      final chunk = Uint8List.view(Int16List.fromList(<int>[12000, -12000, 9000, -9000]).buffer);
      var readCalls = 0;

      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.windows,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) {
          readCalls++;
          if (readCalls == 1) {
            return chunk;
          }
          return Uint8List(0);
        },
        stopFn: () {},
        isRecordingFn: () => true,
      );

      final amplitudeEvents = recorder.onAmplitudeChanged(const Duration(milliseconds: 1));
      await recorder.startStream(pollInterval: const Duration(milliseconds: 5));
      final amplitude = await amplitudeEvents.first.timeout(const Duration(seconds: 1));

      expect(amplitude.current, greaterThan(-30));
      expect(amplitude.max, greaterThan(-30));
      await recorder.stop();
    });

    test('onAmplitudeChanged polls native amplitude in file mode', () async {
      var readAmplitudeCalls = 0;
      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.macOS,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
        getAmplitudeFn: () {
          readAmplitudeCalls++;
          return const Amplitude(current: -28.5, max: -12.0);
        },
      );

      final amplitudeEvents = recorder.onAmplitudeChanged(const Duration(milliseconds: 5));
      await recorder.start(outputPath: '/tmp/amp-file.wav');
      final amplitude = await amplitudeEvents.first.timeout(const Duration(seconds: 1));

      expect(readAmplitudeCalls, greaterThan(0));
      expect(amplitude.current, closeTo(-28.5, 0.001));
      expect(amplitude.max, closeTo(-12.0, 0.001));

      await recorder.stop();
    });

    test('startWithVadSegmentation rejects unsupported segment encoders', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-segments-unsupported-');
      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.windows,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
      );

      expect(
        () => recorder.startWithVadSegmentation(
          outputDirectory: outputDir,
          splitOptions: const PauseSplitOptions(sampleRateHz: 16000, channelCount: 1),
          config: const AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
            encoding: AudioEncodingConfig(encoder: AudioEncoder.opus),
          ),
          vadConfig: const SpeechVadConfig.energyOnly(),
        ),
        throwsA(isA<ArgumentError>()),
      );

      await outputDir.delete(recursive: true);
    });

    test('startWithVadSegmentation flushes trailing speech when enabled', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-segments-flush-');
      final pcmBytes = Uint8List.view(
        _sineWave(sampleRateHz: 16000, duration: const Duration(milliseconds: 450)).buffer,
      );

      var emittedChunk = false;
      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.windows,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) {
          if (emittedChunk) {
            return Uint8List(0);
          }
          emittedChunk = true;
          return pcmBytes;
        },
        stopFn: () {},
        isRecordingFn: () => true,
      );

      final stream = await recorder.startWithVadSegmentation(
        outputDirectory: outputDir,
        splitOptions: const PauseSplitOptions(
          sampleRateHz: 16000,
          channelCount: 1,
          frameDuration: Duration(milliseconds: 20),
          minSpeechDuration: Duration(milliseconds: 100),
          minSilenceDuration: Duration(milliseconds: 600),
        ),
        config: const AudioRecorderConfig(
          sampleRateHz: 16000,
          channelCount: 1,
          encoding: AudioEncodingConfig(encoder: AudioEncoder.wav),
        ),
        vadConfig: const SpeechVadConfig.energyOnly(),
        flushOnStop: true,
        pollInterval: const Duration(milliseconds: 5),
      );

      final segmentsFuture = stream.toList();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await recorder.stop();
      final segments = await segmentsFuture;

      expect(segments, hasLength(1));
      expect(File(segments.first.file.path).existsSync(), isTrue);
      expect(segments.first.fileExtension, 'wav');
      expect(segments.first.metadata.duration.inMilliseconds, greaterThan(300));

      await outputDir.delete(recursive: true);
    });

    test('startWithVadSegmentation can skip trailing flush', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-segments-no-flush-');
      final pcmBytes = Uint8List.view(
        _sineWave(sampleRateHz: 16000, duration: const Duration(milliseconds: 450)).buffer,
      );

      var emittedChunk = false;
      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.windows,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) {
          if (emittedChunk) {
            return Uint8List(0);
          }
          emittedChunk = true;
          return pcmBytes;
        },
        stopFn: () {},
        isRecordingFn: () => true,
      );

      final stream = await recorder.startWithVadSegmentation(
        outputDirectory: outputDir,
        splitOptions: const PauseSplitOptions(
          sampleRateHz: 16000,
          channelCount: 1,
          frameDuration: Duration(milliseconds: 20),
          minSpeechDuration: Duration(milliseconds: 100),
          minSilenceDuration: Duration(milliseconds: 600),
        ),
        config: const AudioRecorderConfig(
          sampleRateHz: 16000,
          channelCount: 1,
          encoding: AudioEncodingConfig(encoder: AudioEncoder.wav),
        ),
        vadConfig: const SpeechVadConfig.energyOnly(),
        flushOnStop: false,
        pollInterval: const Duration(milliseconds: 5),
      );

      final segmentsFuture = stream.toList();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await recorder.stop();
      final segments = await segmentsFuture;

      expect(segments, isEmpty);
      await outputDir.delete(recursive: true);
    });

    test('startWithVadSegmentation uses configured AAC encoder', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-segments-aac-');
      final pcmBytes = Uint8List.view(
        _sineWave(sampleRateHz: 16000, duration: const Duration(milliseconds: 450)).buffer,
      );
      final fakeAacEncoder = _FakeAacEncoder();

      var emittedChunk = false;
      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.windows,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) {
          if (emittedChunk) {
            return Uint8List(0);
          }
          emittedChunk = true;
          return pcmBytes;
        },
        stopFn: () {},
        isRecordingFn: () => true,
      );

      final stream = await recorder.startWithVadSegmentation(
        outputDirectory: outputDir,
        splitOptions: const PauseSplitOptions(
          sampleRateHz: 16000,
          channelCount: 1,
          frameDuration: Duration(milliseconds: 20),
          minSpeechDuration: Duration(milliseconds: 100),
          minSilenceDuration: Duration(milliseconds: 600),
        ),
        config: AudioRecorderConfig(
          sampleRateHz: 16000,
          channelCount: 1,
          encoding: AudioEncodingConfig(
            encoder: AudioEncoder.aacHe,
            bitrateBps: 56000,
            aacEncoder: fakeAacEncoder,
          ),
        ),
        vadConfig: const SpeechVadConfig.energyOnly(),
        flushOnStop: true,
        pollInterval: const Duration(milliseconds: 5),
      );

      final segmentsFuture = stream.toList();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await recorder.stop();
      final segments = await segmentsFuture;

      expect(fakeAacEncoder.encodePcm16BytesToAacCalls, greaterThan(0));
      expect(segments, hasLength(1));
      expect(segments.first.fileExtension, 'm4a');
      expect(segments.first.mimeType, 'audio/aac');

      await outputDir.delete(recursive: true);
    });

    test('startWithVadSegmentation emits error and continues on segment encode failure', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-segments-continue-');
      final pcmBytes = Uint8List.view(
        _concatInt16([
          _sineWave(sampleRateHz: 16000, duration: const Duration(milliseconds: 400)),
          _silence(sampleRateHz: 16000, duration: const Duration(milliseconds: 800)),
          _sineWave(sampleRateHz: 16000, duration: const Duration(milliseconds: 350)),
        ]).buffer,
      );
      final fakeAacEncoder = _FakeAacEncoder(failOnEncodeCalls: {1});

      var emittedChunk = false;
      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.windows,
        availabilityFn: () => true,
        hasPermissionFn: () => true,
        requestPermissionFn: () => true,
        listInputDevicesFn: () => const <InputDevice>[],
        startFileFn:
            ({
              required outputPath,
              required sampleRateHz,
              required channelCount,
              required inputDeviceId,
            }) {},
        startStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readStreamFn: ({required maxSamples}) {
          if (emittedChunk) {
            return Uint8List(0);
          }
          emittedChunk = true;
          return pcmBytes;
        },
        stopFn: () {},
        isRecordingFn: () => true,
      );

      final stream = await recorder.startWithVadSegmentation(
        outputDirectory: outputDir,
        splitOptions: const PauseSplitOptions(
          sampleRateHz: 16000,
          channelCount: 1,
          frameDuration: Duration(milliseconds: 20),
          minSpeechDuration: Duration(milliseconds: 100),
          minSilenceDuration: Duration(milliseconds: 500),
        ),
        config: AudioRecorderConfig(
          sampleRateHz: 16000,
          channelCount: 1,
          encoding: AudioEncodingConfig(encoder: AudioEncoder.aacLc, aacEncoder: fakeAacEncoder),
        ),
        vadConfig: const SpeechVadConfig.energyOnly(),
        flushOnStop: true,
        pollInterval: const Duration(milliseconds: 5),
      );

      final segments = <VoiceSegment>[];
      final errors = <Object>[];
      final done = Completer<void>();
      final subscription = stream.listen(
        segments.add,
        onError: (Object error, StackTrace stackTrace) {
          errors.add(error);
        },
        onDone: () {
          done.complete();
        },
      );

      await Future<void>.delayed(const Duration(milliseconds: 80));
      await recorder.stop();
      await done.future.timeout(const Duration(seconds: 2));
      await subscription.cancel();

      expect(errors, isNotEmpty);
      expect(segments, isNotEmpty);

      await outputDir.delete(recursive: true);
    });
  });
}

class _FakeAacEncoder implements AacEncoder {
  _FakeAacEncoder({this.failOnEncodeCalls = const <int>{}});

  final Set<int> failOnEncodeCalls;
  int encodePcm16BytesToAacCalls = 0;
  int encodeAudioFileToAacCalls = 0;
  String? lastEncodeAudioOutputPath;

  @override
  Future<void> encodePcm16BytesToAac({
    required Uint8List pcm16leBytes,
    required int sampleRateHz,
    required int channelCount,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    encodePcm16BytesToAacCalls++;
    if (failOnEncodeCalls.contains(encodePcm16BytesToAacCalls)) {
      throw AacEncodingException('forced failure');
    }
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> encodeAudioFileToAac({
    required String inputPath,
    required String outputPath,
    int bitrateKbps = 48,
  }) async {
    encodeAudioFileToAacCalls++;
    lastEncodeAudioOutputPath = outputPath;
    final file = File(outputPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(<int>[5, 6, 7, 8], flush: true);
  }
}

Int16List _sineWave({
  required int sampleRateHz,
  required Duration duration,
  double amplitude = 0.65,
  double frequencyHz = 220.0,
}) {
  final sampleCount = (sampleRateHz * duration.inMicroseconds / Duration.microsecondsPerSecond)
      .round();
  final output = Int16List(sampleCount);

  for (var i = 0; i < sampleCount; i++) {
    final sample = math.sin((2 * math.pi * frequencyHz * i) / sampleRateHz);
    output[i] = (sample * amplitude * 32767.0).round();
  }
  return output;
}

Int16List _silence({required int sampleRateHz, required Duration duration}) {
  final sampleCount = (sampleRateHz * duration.inMicroseconds / Duration.microsecondsPerSecond)
      .round();
  return Int16List(sampleCount);
}

Int16List _concatInt16(List<Int16List> segments) {
  final totalLength = segments.fold<int>(0, (sum, segment) => sum + segment.length);
  final output = Int16List(totalLength);
  var offset = 0;
  for (final segment in segments) {
    output.setRange(offset, offset + segment.length, segment);
    offset += segment.length;
  }
  return output;
}
