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
          startPcmStreamFn:
              ({
                required sampleRateHz,
                required channelCount,
                required framesPerChunk,
                required inputDeviceId,
              }) {},
          readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
          stopFn: () {},
          isRecordingFn: () => false,
        );
      }

      expect(recorderFor(NativeAudioRecorderPlatform.macOS).supportsInputSelection, isTrue);
      expect(recorderFor(NativeAudioRecorderPlatform.windows).supportsInputSelection, isTrue);
      expect(recorderFor(NativeAudioRecorderPlatform.iOS).supportsInputSelection, isTrue);
      expect(recorderFor(NativeAudioRecorderPlatform.unsupported).supportsInputSelection, isFalse);
    });

    test('getCapabilities returns current enhancement support by platform', () async {
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
          startPcmStreamFn:
              ({
                required sampleRateHz,
                required channelCount,
                required framesPerChunk,
                required inputDeviceId,
              }) {},
          readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
          stopFn: () {},
          isRecordingFn: () => false,
        );
      }

      Future<void> expectAllFalse(NativeAudioRecorderPlatform platform) async {
        final capabilities = await recorderFor(platform).getCapabilities();
        expect(capabilities.supportsNoiseCancellation, isFalse);
        expect(capabilities.supportsEchoCancellation, isFalse);
        expect(capabilities.supportsVoiceIsolation, isFalse);
      }

      Future<void> expectAllTrue(NativeAudioRecorderPlatform platform) async {
        final capabilities = await recorderFor(platform).getCapabilities();
        expect(capabilities.supportsNoiseCancellation, isTrue);
        expect(capabilities.supportsEchoCancellation, isTrue);
        expect(capabilities.supportsVoiceIsolation, isTrue);
      }

      await expectAllTrue(NativeAudioRecorderPlatform.macOS);
      await expectAllFalse(NativeAudioRecorderPlatform.windows);
      await expectAllTrue(NativeAudioRecorderPlatform.iOS);
      await expectAllFalse(NativeAudioRecorderPlatform.unsupported);
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {
          stopCalls++;
        },
        isRecordingFn: () => true,
      );

      await recorder.startFileRecording(
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

    test('startPcmStream drains native PCM chunks', () async {
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
        startPcmStreamFn:
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
        readPcmStreamFn: ({required maxSamples}) {
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

      final stream = await recorder.startPcmStream(pollInterval: const Duration(milliseconds: 5));

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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
      );

      await recorder.startFileRecording(outputPath: '/tmp/file.wav');

      expect(
        () => recorder.startFileRecording(outputPath: '/tmp/other.wav'),
        throwsA(isA<StateError>()),
      );
    });

    test('unsupported platform reports unavailable and throws', () async {
      final recorder = NativeAudioRecorder(platform: NativeAudioRecorderPlatform.unsupported);

      expect(await recorder.isAvailable(), isFalse);
      expect(
        () => recorder.startFileRecording(outputPath: '/tmp/file.wav'),
        throwsA(isA<UnsupportedError>()),
      );
      expect(() => recorder.startPcmStream(), throwsA(isA<UnsupportedError>()));
      expect(() => recorder.reset(), throwsA(isA<UnsupportedError>()));
    });

    test('reset invokes native reset path and closes stream', () async {
      var resetCalls = 0;
      var stopCalls = 0;

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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {
          stopCalls++;
        },
        resetFn: () {
          resetCalls++;
        },
        isRecordingFn: () => true,
      );

      await recorder.startFileRecording(outputPath: '/tmp/reset.wav');
      await recorder.reset();

      expect(resetCalls, 1);
      expect(stopCalls, 0);
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
      );

      await recorder.startFileRecording(
        outputPath: '/tmp/recording.wav',
        config: const AudioRecorderConfig(inputDeviceId: 'mic-default'),
      );

      expect(usedInputDeviceId, 'mic-default');
      await recorder.stop();
    });

    test('startFileRecording rejects unsupported encoding for native file output', () {
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
      );

      expect(
        () => recorder.startFileRecording(
          outputPath: '/tmp/file.wav',
          config: const AudioRecorderConfig(
            encoding: AudioEncodingConfig(encoder: AudioEncoder.flac),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'startFileRecording uses direct macOS AAC file output for m4a when voice processing is disabled',
      () async {
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
          startPcmStreamFn:
              ({
                required sampleRateHz,
                required channelCount,
                required framesPerChunk,
                required inputDeviceId,
              }) {},
          readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
          stopFn: () {
            stopCalls++;
            File(nativeOutputPath).writeAsBytesSync(const <int>[1, 2, 3, 4], flush: true);
          },
          isRecordingFn: () => true,
        );

        await recorder.startFileRecording(
          outputPath: '/tmp/recording.m4a',
          config: AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
            processing: const AudioProcessingConfig(preset: AudioCapturePreset.raw),
            encoding: AudioEncodingConfig(
              encoder: AudioEncoder.aacLc,
              bitrateBps: 64000,
              audioEncoder: fakeAacEncoder,
            ),
          ),
        );

        expect(nativeOutputPath, '/tmp/recording.m4a');
        await recorder.stop();

        expect(stopCalls, 1);
        expect(fakeAacEncoder.encodeAudioFileToAacCalls, 0);
      },
    );

    test(
      'startFileRecording finalizes AAC on macOS via temp WAV output when voice processing is requested',
      () async {
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
          startPcmStreamFn:
              ({
                required sampleRateHz,
                required channelCount,
                required framesPerChunk,
                required inputDeviceId,
              }) {},
          readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
          stopFn: () {
            stopCalls++;
            File(nativeOutputPath).writeAsBytesSync(const <int>[1, 2, 3, 4], flush: true);
          },
          isRecordingFn: () => true,
        );

        await recorder.startFileRecording(
          outputPath: '/tmp/recording_vp.m4a',
          config: AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
            processing: const AudioProcessingConfig(preset: AudioCapturePreset.voice),
            encoding: AudioEncodingConfig(
              encoder: AudioEncoder.aacLc,
              bitrateBps: 64000,
              audioEncoder: fakeAacEncoder,
            ),
          ),
        );

        expect(nativeOutputPath, isNot('/tmp/recording_vp.m4a'));
        expect(nativeOutputPath.endsWith('/capture.wav'), isTrue);

        await recorder.stop();
        expect(stopCalls, 1);
        expect(fakeAacEncoder.encodeAudioFileToAacCalls, 1);
        expect(fakeAacEncoder.lastEncodeAudioInputPath, nativeOutputPath);
        expect(fakeAacEncoder.lastEncodeAudioOutputPath, '/tmp/recording_vp.m4a');
      },
    );

    test('startFileRecording finalizes AAC on iOS via temp WAV output', () async {
      final fakeAacEncoder = _FakeAacEncoder();
      late String nativeOutputPath;
      var stopCalls = 0;

      final recorder = NativeAudioRecorder(
        platform: NativeAudioRecorderPlatform.iOS,
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {
          stopCalls++;
          File(nativeOutputPath).writeAsBytesSync(const <int>[1, 2, 3, 4], flush: true);
        },
        isRecordingFn: () => true,
      );

      await recorder.startFileRecording(
        outputPath: '/tmp/recording_ios.m4a',
        config: AudioRecorderConfig(
          sampleRateHz: 16000,
          channelCount: 1,
          encoding: AudioEncodingConfig(
            encoder: AudioEncoder.aacLc,
            bitrateBps: 64000,
            audioEncoder: fakeAacEncoder,
          ),
        ),
      );

      expect(nativeOutputPath, isNot('/tmp/recording_ios.m4a'));
      expect(nativeOutputPath.endsWith('/capture.wav'), isTrue);

      await recorder.stop();
      expect(stopCalls, 1);
      expect(fakeAacEncoder.encodeAudioFileToAacCalls, 1);
      expect(fakeAacEncoder.lastEncodeAudioInputPath, nativeOutputPath);
      expect(fakeAacEncoder.lastEncodeAudioOutputPath, '/tmp/recording_ios.m4a');
    });

    test('startFileRecording rejects non-m4a output for direct macOS AAC recording', () {
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
      );

      expect(
        () => recorder.startFileRecording(
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) {
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
      await recorder.startPcmStream(pollInterval: const Duration(milliseconds: 5));
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
        getAmplitudeFn: () {
          readAmplitudeCalls++;
          return const Amplitude(current: -28.5, max: -12.0);
        },
      );

      final amplitudeEvents = recorder.onAmplitudeChanged(const Duration(milliseconds: 5));
      await recorder.startFileRecording(outputPath: '/tmp/amp-file.wav');
      final amplitude = await amplitudeEvents.first.timeout(const Duration(seconds: 1));

      expect(readAmplitudeCalls, greaterThan(0));
      expect(amplitude.current, closeTo(-28.5, 0.001));
      expect(amplitude.max, closeTo(-12.0, 0.001));

      await recorder.stop();
    });

    test('startVadCapture rejects unsupported segment encoders', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-capture-unsupported-');
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {},
        isRecordingFn: () => true,
      );

      expect(
        () => recorder.startVadCapture(
          VadCaptureRequest(
            split: const PauseSplitOptions(sampleRateHz: 16000, channelCount: 1),
            audio: const AudioRecorderConfig(sampleRateHz: 16000, channelCount: 1),
            vad: const SpeechVadConfig.energyOnly(),
            output: VadCaptureOutputConfig(
              outputDirectory: outputDir,
              segmentEncoding: const AudioEncodingConfig(encoder: AudioEncoder.opus),
            ),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );

      await outputDir.delete(recursive: true);
    });

    test('startVadCapture flushes trailing speech when enabled', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-capture-flush-');
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) {
          if (emittedChunk) {
            return Uint8List(0);
          }
          emittedChunk = true;
          return pcmBytes;
        },
        stopFn: () {},
        isRecordingFn: () => true,
      );

      final capture = await recorder.startVadCapture(
        VadCaptureRequest(
          split: const PauseSplitOptions(
            sampleRateHz: 16000,
            channelCount: 1,
            frameDuration: Duration(milliseconds: 20),
            minSpeechDuration: Duration(milliseconds: 100),
            minSilenceDuration: Duration(milliseconds: 600),
          ),
          audio: const AudioRecorderConfig(sampleRateHz: 16000, channelCount: 1),
          vad: const SpeechVadConfig.energyOnly(),
          flushOnStop: true,
          pollInterval: const Duration(milliseconds: 5),
          output: VadCaptureOutputConfig(outputDirectory: outputDir),
        ),
      );

      final segmentsFuture = capture.segments.toList();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      final stopResult = await capture.stop();
      final segments = await segmentsFuture;

      expect(stopResult.segmentCount, 1);
      expect(segments, hasLength(1));
      expect(File(segments.first.file.path).existsSync(), isTrue);
      expect(segments.first.fileExtension, 'wav');
      expect(segments.first.metadata.duration.inMilliseconds, greaterThan(300));

      await outputDir.delete(recursive: true);
    });

    test('startVadCapture can skip trailing flush', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-capture-no-flush-');
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) {
          if (emittedChunk) {
            return Uint8List(0);
          }
          emittedChunk = true;
          return pcmBytes;
        },
        stopFn: () {},
        isRecordingFn: () => true,
      );

      final capture = await recorder.startVadCapture(
        VadCaptureRequest(
          split: const PauseSplitOptions(
            sampleRateHz: 16000,
            channelCount: 1,
            frameDuration: Duration(milliseconds: 20),
            minSpeechDuration: Duration(milliseconds: 100),
            minSilenceDuration: Duration(milliseconds: 600),
          ),
          audio: const AudioRecorderConfig(sampleRateHz: 16000, channelCount: 1),
          vad: const SpeechVadConfig.energyOnly(),
          flushOnStop: false,
          pollInterval: const Duration(milliseconds: 5),
          output: VadCaptureOutputConfig(outputDirectory: outputDir),
        ),
      );

      final segmentsFuture = capture.segments.toList();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      final stopResult = await capture.stop();
      final segments = await segmentsFuture;

      expect(stopResult.segmentCount, 0);
      expect(segments, isEmpty);
      await outputDir.delete(recursive: true);
    });

    test('startVadCapture uses configured AAC encoder for segments', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-capture-segments-aac-');
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) {
          if (emittedChunk) {
            return Uint8List(0);
          }
          emittedChunk = true;
          return pcmBytes;
        },
        stopFn: () {},
        isRecordingFn: () => true,
      );

      final capture = await recorder.startVadCapture(
        VadCaptureRequest(
          split: const PauseSplitOptions(
            sampleRateHz: 16000,
            channelCount: 1,
            frameDuration: Duration(milliseconds: 20),
            minSpeechDuration: Duration(milliseconds: 100),
            minSilenceDuration: Duration(milliseconds: 600),
          ),
          audio: const AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
            encoding: AudioEncodingConfig(encoder: AudioEncoder.wav),
          ),
          vad: const SpeechVadConfig.energyOnly(),
          flushOnStop: true,
          pollInterval: const Duration(milliseconds: 5),
          output: VadCaptureOutputConfig(
            outputDirectory: outputDir,
            segmentEncoding: AudioEncodingConfig(
              encoder: AudioEncoder.aacHe,
              bitrateBps: 56000,
              audioEncoder: fakeAacEncoder,
            ),
          ),
        ),
      );

      final segmentsFuture = capture.segments.toList();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      final stopResult = await capture.stop();
      final segments = await segmentsFuture;

      expect(stopResult.segmentCount, 1);
      expect(fakeAacEncoder.encodePcm16BytesToAacCalls, greaterThan(0));
      expect(segments, hasLength(1));
      expect(segments.first.fileExtension, 'm4a');
      expect(segments.first.mimeType, 'audio/aac');

      await outputDir.delete(recursive: true);
    });

    test('startVadCapture can emit full recording artifact on stop', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-capture-full-recording-');
      final pcmBytes = Uint8List.view(
        _sineWave(sampleRateHz: 16000, duration: const Duration(milliseconds: 350)).buffer,
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) {
          if (emittedChunk) {
            return Uint8List(0);
          }
          emittedChunk = true;
          return pcmBytes;
        },
        stopFn: () {},
        isRecordingFn: () => true,
      );

      final capture = await recorder.startVadCapture(
        VadCaptureRequest(
          split: const PauseSplitOptions(
            sampleRateHz: 16000,
            channelCount: 1,
            frameDuration: Duration(milliseconds: 20),
            minSpeechDuration: Duration(milliseconds: 100),
            minSilenceDuration: Duration(milliseconds: 600),
          ),
          audio: const AudioRecorderConfig(
            sampleRateHz: 16000,
            channelCount: 1,
            encoding: AudioEncodingConfig(encoder: AudioEncoder.wav),
          ),
          vad: const SpeechVadConfig.energyOnly(),
          flushOnStop: true,
          pollInterval: const Duration(milliseconds: 5),
          output: VadCaptureOutputConfig(
            outputDirectory: outputDir,
            emitFullRecordingOnStop: true,
            fullRecordingFileStem: 'recording_final',
            fullRecordingEncoding: const AudioEncodingConfig(encoder: AudioEncoder.wav),
          ),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 60));
      final stopResult = await capture.stop();

      expect(stopResult.fullRecording, isNotNull);
      final fullRecording = stopResult.fullRecording!;
      expect(fullRecording.fileExtension, 'wav');
      expect(File(fullRecording.file.path).existsSync(), isTrue);
      expect(fullRecording.metrics.inputPcmByteCount, greaterThan(0));

      await outputDir.delete(recursive: true);
    });

    test('startVadCapture emits error and continues on segment encode failure', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-capture-continue-');
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
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {},
        readPcmStreamFn: ({required maxSamples}) {
          if (emittedChunk) {
            return Uint8List(0);
          }
          emittedChunk = true;
          return pcmBytes;
        },
        stopFn: () {},
        isRecordingFn: () => true,
      );

      final capture = await recorder.startVadCapture(
        VadCaptureRequest(
          split: const PauseSplitOptions(
            sampleRateHz: 16000,
            channelCount: 1,
            frameDuration: Duration(milliseconds: 20),
            minSpeechDuration: Duration(milliseconds: 100),
            minSilenceDuration: Duration(milliseconds: 500),
          ),
          audio: const AudioRecorderConfig(sampleRateHz: 16000, channelCount: 1),
          vad: const SpeechVadConfig.energyOnly(),
          flushOnStop: true,
          pollInterval: const Duration(milliseconds: 5),
          output: VadCaptureOutputConfig(
            outputDirectory: outputDir,
            segmentEncoding: AudioEncodingConfig(
              encoder: AudioEncoder.aacLc,
              audioEncoder: fakeAacEncoder,
            ),
          ),
        ),
      );

      final segments = <VoiceSegment>[];
      final errors = <Object>[];
      final done = Completer<void>();
      final subscription = capture.segments.listen(
        segments.add,
        onError: (Object error, StackTrace stackTrace) {
          errors.add(error);
        },
        onDone: () {
          done.complete();
        },
      );

      await Future<void>.delayed(const Duration(milliseconds: 80));
      await capture.stop();
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
  String? lastEncodeAudioInputPath;
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
    lastEncodeAudioInputPath = inputPath;
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
