import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show AppExitResponse;

import 'package:flutter/widgets.dart';
import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';
import 'fakes/native_audio_recorder_platform_implementation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('NativeAudioRecorder', () {
    test('supportsInputSelection reports capability by platform', () {
      NativeAudioRecorder recorderFor(NativeAudioRecorderPlatform platform) {
        return recorderFixture(
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
      expect(recorderFor(NativeAudioRecorderPlatform.linux).supportsInputSelection, isTrue);
      expect(recorderFor(NativeAudioRecorderPlatform.iOS).supportsInputSelection, isTrue);
      expect(recorderFor(NativeAudioRecorderPlatform.unsupported).supportsInputSelection, isFalse);
    });

    test('getCapabilities returns current enhancement support by platform', () async {
      NativeAudioRecorder recorderFor(NativeAudioRecorderPlatform platform) {
        return recorderFixture(
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

      Future<void> expectNoiseEchoOffVoiceIsolationOn(NativeAudioRecorderPlatform platform) async {
        final capabilities = await recorderFor(platform).getCapabilities();
        expect(capabilities.supportsNoiseCancellation, isFalse);
        expect(capabilities.supportsEchoCancellation, isFalse);
        expect(capabilities.supportsVoiceIsolation, isTrue);
      }

      await expectNoiseEchoOffVoiceIsolationOn(NativeAudioRecorderPlatform.macOS);
      final winCap = await recorderFor(NativeAudioRecorderPlatform.windows).getCapabilities();
      expect(winCap.supportsNoiseCancellation, isTrue);
      expect(winCap.supportsEchoCancellation, isFalse);
      expect(winCap.supportsVoiceIsolation, isTrue);
      final linuxCap = await recorderFor(NativeAudioRecorderPlatform.linux).getCapabilities();
      expect(linuxCap.supportsNoiseCancellation, isTrue);
      expect(linuxCap.supportsEchoCancellation, isFalse);
      expect(linuxCap.supportsVoiceIsolation, isTrue);
      await expectNoiseEchoOffVoiceIsolationOn(NativeAudioRecorderPlatform.iOS);
      await expectAllFalse(NativeAudioRecorderPlatform.unsupported);
    });

    test('setContinousRecording forwards toggle with latest recording config', () async {
      final enabledCalls = <bool>[];
      final configCalls = <AudioRecorderConfig>[];
      var isRecording = false;

      final recorder = recorderFixture(
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
            }) {
              isRecording = true;
            },
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {
              isRecording = true;
            },
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        setContinousRecordingFn: ({required enabled, required config}) {
          enabledCalls.add(enabled);
          configCalls.add(config);
        },
        stopFn: () {
          isRecording = false;
        },
        isRecordingFn: () => isRecording,
      );

      await recorder.setContinousRecording(true);
      expect(enabledCalls, <bool>[true]);
      expect(configCalls.single.sampleRateHz, 16000);
      expect(configCalls.single.channelCount, 1);

      await recorder.startPcmStream(
        config: const AudioRecorderConfig(sampleRateHz: 24000, channelCount: 2),
        pollInterval: const Duration(milliseconds: 50),
      );
      await recorder.stop();
      await recorder.setContinousRecording(false);

      expect(enabledCalls, <bool>[true, false]);
      expect(configCalls.last.sampleRateHz, 24000);
      expect(configCalls.last.channelCount, 2);
    });

    test('reset reapplies continous recording with the latest stream config', () async {
      final configCalls = <AudioRecorderConfig>[];
      var isRecording = false;
      var resetCalls = 0;

      final recorder = recorderFixture(
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
            }) {
              isRecording = true;
            },
        startPcmStreamFn:
            ({
              required sampleRateHz,
              required channelCount,
              required framesPerChunk,
              required inputDeviceId,
            }) {
              isRecording = true;
            },
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        setContinousRecordingFn: ({required enabled, required config}) {
          if (enabled) {
            configCalls.add(config);
          }
        },
        stopFn: () {
          isRecording = false;
        },
        resetFn: () {
          isRecording = false;
          resetCalls++;
        },
        isRecordingFn: () => isRecording,
      );

      await recorder.setContinousRecording(true);
      await recorder.startPcmStream(
        config: const AudioRecorderConfig(sampleRateHz: 32000, channelCount: 2),
        pollInterval: const Duration(milliseconds: 50),
      );
      await recorder.reset();

      expect(resetCalls, 1);
      expect(configCalls, hasLength(2));
      expect(configCalls.first.sampleRateHz, 16000);
      expect(configCalls.last.sampleRateHz, 32000);
      expect(configCalls.last.channelCount, 2);
    });

    test('setContinousRecording can preconfigure and switch the warm input device', () async {
      final configCalls = <AudioRecorderConfig>[];
      String? usedInputDeviceId;
      var isRecording = false;

      final recorder = recorderFixture(
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
            }) {
              usedInputDeviceId = inputDeviceId;
              isRecording = true;
            },
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        setContinousRecordingFn: ({required enabled, required config}) {
          configCalls.add(config);
        },
        stopFn: () {
          isRecording = false;
        },
        isRecordingFn: () => isRecording,
      );

      await recorder.setContinousRecording(true, inputDeviceId: 'mic-a');
      await recorder.setContinousRecording(true, inputDeviceId: 'mic-b');
      await recorder.startPcmStream(pollInterval: const Duration(milliseconds: 50));

      expect(configCalls.map((config) => config.inputDeviceId), <String?>['mic-a', 'mic-b']);
      expect(usedInputDeviceId, 'mic-b');

      await recorder.stop();
    });

    test(
      'macOS continuous capture resolves the default input device when no device id is provided',
      () async {
        final configCalls = <AudioRecorderConfig>[];
        String? usedInputDeviceId;
        var isRecording = false;

        final recorder = recorderFixture(
          platform: NativeAudioRecorderPlatform.macOS,
          availabilityFn: () => true,
          hasPermissionFn: () => true,
          requestPermissionFn: () => true,
          listInputDevicesFn: () => const <InputDevice>[
            InputDevice(id: 'mic-default', label: 'Default Mic', isDefault: true),
            InputDevice(id: 'mic-usb', label: 'USB Mic'),
          ],
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
                usedInputDeviceId = inputDeviceId;
                isRecording = true;
              },
          readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
          setContinousRecordingFn: ({required enabled, required config}) {
            configCalls.add(config);
          },
          stopFn: () {
            isRecording = false;
          },
          isRecordingFn: () => isRecording,
        );

        await recorder.setContinousRecording(true);
        await recorder.startPcmStream(pollInterval: const Duration(milliseconds: 50));

        expect(configCalls.single.inputDeviceId, 'mic-default');
        expect(usedInputDeviceId, 'mic-default');

        await recorder.stop();
      },
    );

    test(
      'macOS continuous capture retries after an initial default-device lookup failure',
      () async {
        final configCalls = <String?>[];
        var listCalls = 0;

        final recorder = recorderFixture(
          platform: NativeAudioRecorderPlatform.macOS,
          availabilityFn: () => true,
          hasPermissionFn: () => true,
          requestPermissionFn: () => true,
          listInputDevicesFn: () {
            listCalls++;
            if (listCalls == 1) {
              return const <InputDevice>[];
            }
            return const <InputDevice>[
              InputDevice(id: 'mic-default', label: 'Default Mic', isDefault: true),
            ];
          },
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
          setContinousRecordingFn: ({required enabled, required config}) {
            configCalls.add(config.inputDeviceId);
            if (enabled && configCalls.length == 1) {
              throw const AudioRecorderException(
                'Warm start failed',
                errorCode: -21,
                details: 'No audio capture device is available.',
              );
            }
          },
          stopFn: () {},
          isRecordingFn: () => false,
        );

        await recorder.setContinousRecording(true);

        expect(configCalls, <String?>[null, 'mic-default']);
        expect(recorder.continousRecordingState, NativeAudioRecorderContinousRecordingState.active);
      },
    );

    test(
      'Windows continuous capture resolves the default input device when no device id is provided',
      () async {
        final configCalls = <AudioRecorderConfig>[];
        String? usedInputDeviceId;
        var isRecording = false;

        final recorder = recorderFixture(
          platform: NativeAudioRecorderPlatform.windows,
          availabilityFn: () => true,
          hasPermissionFn: () => true,
          requestPermissionFn: () => true,
          listInputDevicesFn: () => const <InputDevice>[
            InputDevice(id: 'mic-default', label: 'Default Mic', isDefault: true),
            InputDevice(id: 'mic-usb', label: 'USB Mic'),
          ],
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
                usedInputDeviceId = inputDeviceId;
                isRecording = true;
              },
          readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
          setContinousRecordingFn: ({required enabled, required config}) {
            configCalls.add(config);
          },
          stopFn: () {
            isRecording = false;
          },
          isRecordingFn: () => isRecording,
        );

        await recorder.setContinousRecording(true);
        await recorder.startPcmStream(pollInterval: const Duration(milliseconds: 50));

        expect(configCalls.single.inputDeviceId, 'mic-default');
        expect(usedInputDeviceId, 'mic-default');

        await recorder.stop();
      },
    );

    test(
      'continousRecordingState hibernates after the warm duration and reactivates after stop',
      () async {
        final enabledCalls = <bool>[];
        var isRecording = false;

        final recorder = recorderFixture(
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
              }) {
                isRecording = true;
              },
          startPcmStreamFn:
              ({
                required sampleRateHz,
                required channelCount,
                required framesPerChunk,
                required inputDeviceId,
              }) {
                isRecording = true;
              },
          readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
          setContinousRecordingFn: ({required enabled, required config}) {
            enabledCalls.add(enabled);
          },
          stopFn: () {
            isRecording = false;
          },
          isRecordingFn: () => isRecording,
        );

        await recorder.setContinousRecording(true, duration: const Duration(milliseconds: 20));
        expect(recorder.continousRecordingState, NativeAudioRecorderContinousRecordingState.active);

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(
          recorder.continousRecordingState,
          NativeAudioRecorderContinousRecordingState.hibernation,
        );
        expect(enabledCalls, <bool>[true, false]);

        await recorder.startFileRecording(
          outputPath: '${Directory.systemTemp.path}${Platform.pathSeparator}hibernation-test.wav',
        );
        expect(recorder.continousRecordingState, NativeAudioRecorderContinousRecordingState.active);

        await recorder.stop();
        expect(enabledCalls, <bool>[true, false, true]);
        expect(recorder.continousRecordingState, NativeAudioRecorderContinousRecordingState.active);

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(enabledCalls, <bool>[true, false, true, false]);
        expect(
          recorder.continousRecordingState,
          NativeAudioRecorderContinousRecordingState.hibernation,
        );
      },
    );

    test('setContinousRecording retries transient Windows warm-start failures', () async {
      var toggleCalls = 0;
      var resetCalls = 0;

      final recorder = recorderFixture(
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
        setContinousRecordingFn: ({required enabled, required config}) {
          toggleCalls++;
          if (enabled && toggleCalls == 1) {
            throw const AudioRecorderException(
              'Warm start failed',
              details: 'Failed to start miniaudio capture device: device or resource busy',
            );
          }
        },
        resetFn: () {
          resetCalls++;
        },
        stopFn: () {},
        isRecordingFn: () => false,
      );

      await recorder.setContinousRecording(true);

      expect(toggleCalls, 2);
      expect(resetCalls, 1);
      expect(recorder.continousRecordingState, NativeAudioRecorderContinousRecordingState.active);
    });

    test('continousRecordingState reports error after a failed toggle', () async {
      var failNextToggle = true;

      final recorder = recorderFixture(
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
        setContinousRecordingFn: ({required enabled, required config}) {
          if (failNextToggle) {
            failNextToggle = false;
            throw StateError('warm toggle failed');
          }
        },
        stopFn: () {},
        isRecordingFn: () => false,
      );

      await expectLater(recorder.setContinousRecording(true), throwsA(isA<StateError>()));
      expect(recorder.continousRecordingState, NativeAudioRecorderContinousRecordingState.error);

      await recorder.setContinousRecording(true);
      expect(recorder.continousRecordingState, NativeAudioRecorderContinousRecordingState.active);
    });

    test('Windows app detach resets native recorder state', () async {
      var resetCalls = 0;

      final recorder = recorderFixture(
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
        setContinousRecordingFn: ({required enabled, required config}) {},
        resetFn: () {
          resetCalls++;
        },
        stopFn: () {},
        isRecordingFn: () => false,
      );

      await recorder.setContinousRecording(true);
      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.detached);
      await Future<void>.delayed(Duration.zero);

      expect(resetCalls, 1);

      WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await recorder.dispose();
    });

    test('Windows app exit request resets native recorder state', () async {
      var resetCalls = 0;

      final recorder = recorderFixture(
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
        setContinousRecordingFn: ({required enabled, required config}) {},
        resetFn: () {
          resetCalls++;
        },
        stopFn: () {},
        isRecordingFn: () => false,
      );

      await recorder.setContinousRecording(true);
      final response = await WidgetsBinding.instance.handleRequestAppExit();

      expect(response, AppExitResponse.exit);
      expect(resetCalls, 1);

      await recorder.dispose();
    });

    test('starts file recording with configured sample rate/channels', () async {
      late String usedOutputPath;
      late int usedSampleRate;
      late int usedChannelCount;
      String? usedInputDeviceId;
      var stopCalls = 0;

      final recorder = recorderFixture(
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

    test('retries transient Windows file start failures', () async {
      var startAttempts = 0;
      var stopCalls = 0;

      final recorder = recorderFixture(
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
            }) {
              startAttempts++;
              if (startAttempts == 1) {
                throw const AudioRecorderException(
                  'Windows file recording start failed',
                  errorCode: -7,
                  details: 'Failed to start miniaudio capture device: Resource unavailable',
                );
              }
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

      await recorder.startFileRecording(outputPath: '/tmp/retry.wav');

      expect(startAttempts, 2);
      await recorder.stop();
      expect(stopCalls, 1);
    });

    test('does not retry non-transient Windows file start failures', () async {
      var startAttempts = 0;

      final recorder = recorderFixture(
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
            }) {
              startAttempts++;
              throw const AudioRecorderException(
                'Windows file recording start failed',
                errorCode: -5,
                details: 'Failed to open output file for writing.',
              );
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
        isRecordingFn: () => false,
      );

      await expectLater(
        recorder.startFileRecording(outputPath: '/tmp/fail.wav'),
        throwsA(
          isA<AudioRecorderException>().having(
            (error) => error.details,
            'details',
            'Failed to open output file for writing.',
          ),
        ),
      );
      expect(startAttempts, 1);
    });

    test('startPcmStream drains native PCM chunks', () async {
      var readCalls = 0;
      var stopCalls = 0;
      String? usedInputDeviceId;

      final recorder = recorderFixture(
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

    test('retries transient Windows stream start failures', () async {
      var startAttempts = 0;
      var stopCalls = 0;

      final recorder = recorderFixture(
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
              startAttempts++;
              if (startAttempts == 1) {
                throw const AudioRecorderException(
                  'Windows stream recording start failed',
                  errorCode: -3,
                  details: 'Failed to start miniaudio capture device: Device or resource busy',
                );
              }
            },
        readPcmStreamFn: ({required maxSamples}) => Uint8List(0),
        stopFn: () {
          stopCalls++;
        },
        isRecordingFn: () => true,
      );

      await recorder.startPcmStream(pollInterval: const Duration(milliseconds: 50));

      expect(startAttempts, 2);
      await recorder.stop();
      expect(stopCalls, 1);
    });

    test('throws when starting while already running', () async {
      final recorder = recorderFixture(
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
        throwsA(isA<NativeAudioRecorderBusyException>()),
      );
    });

    test('unsupported platform reports unavailable and throws', () async {
      final recorder = recorderFixture(platform: NativeAudioRecorderPlatform.unsupported);

      expect(await recorder.isAvailable(), isFalse);
      expect(
        () => recorder.startFileRecording(outputPath: '/tmp/file.wav'),
        throwsA(isA<NativeAudioRecorderUnsupportedPlatformException>()),
      );
      expect(
        () => recorder.startPcmStream(),
        throwsA(isA<NativeAudioRecorderUnsupportedPlatformException>()),
      );
      expect(
        () => recorder.reset(),
        throwsA(isA<NativeAudioRecorderUnsupportedPlatformException>()),
      );
    });

    test('reset invokes native reset path and closes stream', () async {
      var resetCalls = 0;
      var stopCalls = 0;

      final recorder = recorderFixture(
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

      final recorder = recorderFixture(
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
      final recorder = recorderFixture(
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

    test('startFileRecording requires custom AAC encoder on Linux', () {
      final recorder = recorderFixture(
        platform: NativeAudioRecorderPlatform.linux,
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
          outputPath: '/tmp/file.m4a',
          config: const AudioRecorderConfig(
            encoding: AudioEncodingConfig(encoder: AudioEncoder.aacLc),
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('startFileRecording allows Linux AAC recording with custom encoder', () async {
      final outputDir = await Directory.systemTemp.createTemp('linux-aac-recorder-');
      final fakeAacEncoder = _FakeAacEncoder();
      final recorder = recorderFixture(
        platform: NativeAudioRecorderPlatform.linux,
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

      try {
        final outputPath = '${outputDir.path}${Platform.pathSeparator}file.m4a';
        await recorder.startFileRecording(
          outputPath: outputPath,
          config: AudioRecorderConfig(
            encoding: AudioEncodingConfig(
              encoder: AudioEncoder.aacLc,
              audioEncoder: fakeAacEncoder,
            ),
          ),
        );
        await recorder.stop();

        expect(fakeAacEncoder.encodeAudioFileToAacCalls, 1);
        expect(await File(outputPath).exists(), isTrue);
      } finally {
        await outputDir.delete(recursive: true);
      }
    });

    test(
      'startFileRecording uses direct Apple AAC output on macOS when voice processing is disabled',
      () async {
        final fakeAacEncoder = _FakeAacEncoder();
        late String nativeOutputPath;
        var stopCalls = 0;

        final recorder = recorderFixture(
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

    test('stop deletes partial AAC output when encoded file finalization fails', () async {
      final outputDirectory = await Directory.systemTemp.createTemp(
        'speech_utils_stop_failure_test_',
      );
      final outputPath = '${outputDirectory.path}${Platform.pathSeparator}recording.m4a';
      final fakeAacEncoder = _FakeAacEncoder(failOnEncodeAudioFileCalls: const <int>{1});
      late String nativeOutputPath;

      final recorder = recorderFixture(
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
          File(nativeOutputPath).writeAsBytesSync(const <int>[1, 2, 3, 4], flush: true);
          File(outputPath).writeAsBytesSync(const <int>[5, 6, 7, 8], flush: true);
        },
        isRecordingFn: () => true,
      );

      try {
        await recorder.startFileRecording(
          outputPath: outputPath,
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

        await expectLater(recorder.stop(), throwsA(isA<AacEncodingException>()));

        expect(File(outputPath).existsSync(), isFalse);
        expect(File(nativeOutputPath).parent.existsSync(), isFalse);
      } finally {
        await recorder.dispose();
        if (await outputDirectory.exists()) {
          await outputDirectory.delete(recursive: true);
        }
      }
    });

    test('startFileRecording uses direct native AAC output on Android', () async {
      final fakeAacEncoder = _FakeAacEncoder();
      late String nativeOutputPath;
      var stopCalls = 0;

      final recorder = recorderFixture(
        platform: NativeAudioRecorderPlatform.android,
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
        outputPath: '/tmp/recording_android.m4a',
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

      expect(nativeOutputPath, '/tmp/recording_android.m4a');

      await recorder.stop();
      expect(stopCalls, 1);
      expect(fakeAacEncoder.encodeAudioFileToAacCalls, 0);
    });

    test(
      'startFileRecording uses direct Apple AAC output on macOS when voice processing is requested',
      () async {
        final fakeAacEncoder = _FakeAacEncoder();
        late String nativeOutputPath;
        var stopCalls = 0;

        final recorder = recorderFixture(
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

        expect(nativeOutputPath, '/tmp/recording_vp.m4a');

        await recorder.stop();
        expect(stopCalls, 1);
        expect(fakeAacEncoder.encodeAudioFileToAacCalls, 0);
      },
    );

    test('startFileRecording uses direct Apple AAC output on iOS', () async {
      final fakeAacEncoder = _FakeAacEncoder();
      late String nativeOutputPath;
      var stopCalls = 0;

      final recorder = recorderFixture(
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

      expect(nativeOutputPath, '/tmp/recording_ios.m4a');

      await recorder.stop();
      expect(stopCalls, 1);
      expect(fakeAacEncoder.encodeAudioFileToAacCalls, 0);
    });

    test('startFileRecording rejects non-m4a output for macOS AAC recording', () {
      final recorder = recorderFixture(
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

    test('startFileRecording rejects non-m4a output for iOS AAC recording', () {
      final recorder = recorderFixture(
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

    test('startFileRecording rejects non-m4a output for Android AAC recording', () {
      final recorder = recorderFixture(
        platform: NativeAudioRecorderPlatform.android,
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

      final recorder = recorderFixture(
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
      expect(amplitude.isSpeechSegment, isNull);
      await recorder.stop();
    });

    test('onAmplitudeChanged polls native amplitude in file mode', () async {
      var readAmplitudeCalls = 0;
      final recorder = recorderFixture(
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
      expect(amplitude.isSpeechSegment, isNull);

      await recorder.stop();
    });

    test('startVadCapture exposes speech state on amplitude snapshots', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-capture-amplitude-state-');
      final speechChunk = Uint8List.view(
        _sineWave(sampleRateHz: 16000, duration: const Duration(milliseconds: 200)).buffer,
      );
      final silenceChunk = Uint8List.view(
        _silence(sampleRateHz: 16000, duration: const Duration(milliseconds: 200)).buffer,
      );

      var readCalls = 0;
      final recorder = recorderFixture(
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
            return speechChunk;
          }
          if (readCalls == 2) {
            return silenceChunk;
          }
          return Uint8List(0);
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
            minSpeechDuration: Duration(milliseconds: 60),
            minSilenceDuration: Duration(milliseconds: 80),
          ),
          audio: const AudioRecorderConfig(sampleRateHz: 16000, channelCount: 1),
          vad: const SpeechVadConfig.energyOnly(),
          telemetry: const VadCaptureTelemetryConfig(speechHoldDuration: Duration.zero),
          pollInterval: const Duration(milliseconds: 5),
          output: VadCaptureOutputConfig(outputDirectory: outputDir),
        ),
      );

      Future<void> captureAmplitudeInto(Completer<Amplitude> completer) async {
        try {
          completer.complete(await recorder.getAmplitude());
        } on Object catch (error, stackTrace) {
          completer.completeError(error, stackTrace);
        }
      }

      var sawSpeechEvent = false;
      final amplitudeDuringSpeechCompleter = Completer<Amplitude>();
      final amplitudeAfterSilenceCompleter = Completer<Amplitude>();
      final speechStateSubscription = capture.speechStates.listen((sample) {
        if (sample.speechDetected && !sawSpeechEvent) {
          sawSpeechEvent = true;
          unawaited(captureAmplitudeInto(amplitudeDuringSpeechCompleter));
          return;
        }
        if (!sample.speechDetected &&
            sawSpeechEvent &&
            !amplitudeAfterSilenceCompleter.isCompleted) {
          unawaited(captureAmplitudeInto(amplitudeAfterSilenceCompleter));
        }
      });

      final amplitudeDuringSpeech = await amplitudeDuringSpeechCompleter.future.timeout(
        const Duration(seconds: 1),
      );
      final amplitudeAfterSilence = await amplitudeAfterSilenceCompleter.future.timeout(
        const Duration(seconds: 1),
      );

      expect(amplitudeDuringSpeech.isSpeechSegment, isTrue);
      expect(amplitudeAfterSilence.isSpeechSegment, isFalse);

      await capture.stop();
      final amplitudeAfterStop = await recorder.getAmplitude();
      expect(amplitudeAfterStop.isSpeechSegment, isNull);
      await speechStateSubscription.cancel();
      await outputDir.delete(recursive: true);
    });

    test('startVadCapture rejects unsupported segment encoders', () async {
      final outputDir = await Directory.systemTemp.createTemp('vad-capture-unsupported-');
      final recorder = recorderFixture(
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
      final recorder = recorderFixture(
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
      final recorder = recorderFixture(
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
      final recorder = recorderFixture(
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
      final recorder = recorderFixture(
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
      final recorder = recorderFixture(
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
  _FakeAacEncoder({
    this.failOnEncodeCalls = const <int>{},
    this.failOnEncodeAudioFileCalls = const <int>{},
  });

  final Set<int> failOnEncodeCalls;
  final Set<int> failOnEncodeAudioFileCalls;
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
    if (failOnEncodeAudioFileCalls.contains(encodeAudioFileToAacCalls)) {
      throw AacEncodingException('forced failure');
    }
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
