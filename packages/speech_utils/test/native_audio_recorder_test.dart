import 'dart:typed_data';

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
  });
}
