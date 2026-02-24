import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  group('AudioRecorderConfig', () {
    test('accepts processing and platform-specific config objects', () {
      final config = AudioRecorderConfig(
        sampleRateHz: 48000,
        channelCount: 2,
        framesPerChunk: 512,
        processing: const AudioProcessingConfig(
          preset: AudioCapturePreset.voiceIsolation,
          enableNoiseSuppression: true,
          enableEchoCancellation: true,
          enableAutomaticGainControl: true,
          preferredLatency: Duration(milliseconds: 40),
        ),
        appleConfig: const AppleAudioRecorderConfig(
          sessionMode: AppleAudioSessionMode.voiceChat,
          allowBluetoothInput: true,
          defaultToSpeaker: true,
          preferredInputGain: 0.8,
          preferredIoBufferDuration: Duration(milliseconds: 10),
        ),
        windowsConfig: const WindowsAudioRecorderConfig(
          captureCategory: WindowsCaptureCategory.communications,
          useCommunicationsDevice: true,
          useExclusiveMode: false,
          useRawCapture: false,
          targetBufferDuration: Duration(milliseconds: 30),
        ),
      );

      expect(config.processing.enableNoiseSuppression, isTrue);
      expect(config.appleConfig, isNotNull);
      expect(config.windowsConfig, isNotNull);
      expect(() => config.validate(), returnsNormally);
    });

    test('rejects invalid processing latency', () {
      final config = AudioRecorderConfig(
        processing: const AudioProcessingConfig(preferredLatency: Duration.zero),
      );

      expect(() => config.validate(), throwsArgumentError);
    });

    test('rejects invalid Apple input gain', () {
      final config = AudioRecorderConfig(
        appleConfig: const AppleAudioRecorderConfig(preferredInputGain: 1.1),
      );

      expect(() => config.validate(), throwsArgumentError);
    });

    test('rejects invalid Windows target buffer duration', () {
      final config = AudioRecorderConfig(
        windowsConfig: const WindowsAudioRecorderConfig(targetBufferDuration: Duration.zero),
      );

      expect(() => config.validate(), throwsArgumentError);
    });
  });
}
