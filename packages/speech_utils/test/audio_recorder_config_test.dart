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
          preferredLatency: Duration(milliseconds: 40),
          windows: WindowsAudioProcessingConfig(
            usePresetDefaults: true,
            enableNoiseSuppression: true,
          ),
        ),
        iosConfig: const IosAudioRecorderConfig(
          sessionMode: IosAudioSessionMode.voiceChat,
          allowBluetoothInput: true,
          defaultToSpeaker: true,
          preferredInputGain: 0.8,
          preferredIoBufferDuration: Duration(milliseconds: 10),
        ),
        macosConfig: const MacosAudioRecorderConfig(
          processingQueueDuration: Duration(milliseconds: 50),
        ),
        windowsConfig: const WindowsAudioRecorderConfig(
          captureCategory: WindowsCaptureCategory.communications,
          useCommunicationsDevice: true,
          useExclusiveMode: false,
          useRawCapture: false,
          targetBufferDuration: Duration(milliseconds: 30),
        ),
      );

      expect(config.processing.windows.enableNoiseSuppression, isTrue);
      expect(config.iosConfig, isNotNull);
      expect(config.macosConfig, isNotNull);
      expect(config.windowsConfig, isNotNull);
      expect(() => config.validate(), returnsNormally);
    });

    test('rejects invalid processing latency', () {
      final config = AudioRecorderConfig(
        processing: const AudioProcessingConfig(preferredLatency: Duration.zero),
      );

      expect(() => config.validate(), throwsArgumentError);
    });

    test('rejects invalid iOS input gain', () {
      final config = AudioRecorderConfig(
        iosConfig: const IosAudioRecorderConfig(preferredInputGain: 1.1),
      );

      expect(() => config.validate(), throwsArgumentError);
    });

    test('rejects invalid macOS processing queue duration', () {
      final config = AudioRecorderConfig(
        macosConfig: const MacosAudioRecorderConfig(processingQueueDuration: Duration.zero),
      );

      expect(() => config.validate(), throwsArgumentError);
    });

    test('rejects invalid Windows target buffer duration', () {
      final config = AudioRecorderConfig(
        windowsConfig: const WindowsAudioRecorderConfig(targetBufferDuration: Duration.zero),
      );

      expect(() => config.validate(), throwsArgumentError);
    });

    test('iOS and macOS per-feature processing toggles resolve off for all presets', () {
      const presets = <AudioCapturePreset>[
        AudioCapturePreset.voice,
        AudioCapturePreset.voiceIsolation,
        AudioCapturePreset.raw,
        AudioCapturePreset.music,
      ];

      for (final preset in presets) {
        final processing = AudioProcessingConfig(preset: preset);
        expect(processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.ios), isFalse);
        expect(processing.resolveEchoCancellationForPlatform(AudioProcessingPlatform.ios), isFalse);
        expect(
          processing.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.ios),
          isFalse,
        );
        expect(processing.resolveHighPassFilterForPlatform(AudioProcessingPlatform.ios), isFalse);
        expect(
          processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.macos),
          isFalse,
        );
        expect(
          processing.resolveEchoCancellationForPlatform(AudioProcessingPlatform.macos),
          isFalse,
        );
        expect(
          processing.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.macos),
          isFalse,
        );
        expect(processing.resolveHighPassFilterForPlatform(AudioProcessingPlatform.macos), isFalse);
      }
    });

    test('Windows preset defaults apply for voice and voice-isolation', () {
      const processing = AudioProcessingConfig(preset: AudioCapturePreset.voiceIsolation);

      expect(
        processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.windows),
        isTrue,
      );
      expect(
        processing.resolveEchoCancellationForPlatform(AudioProcessingPlatform.windows),
        isTrue,
      );
      expect(
        processing.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.windows),
        isTrue,
      );
      expect(processing.resolveHighPassFilterForPlatform(AudioProcessingPlatform.windows), isTrue);
    });

    test('Windows overrides can disable voice defaults', () {
      const processing = AudioProcessingConfig(
        preset: AudioCapturePreset.voice,
        windows: WindowsAudioProcessingConfig(
          usePresetDefaults: true,
          enableNoiseSuppression: false,
          enableEchoCancellation: false,
          enableAutomaticGainControl: false,
          enableHighPassFilter: false,
        ),
      );

      expect(
        processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.windows),
        isFalse,
      );
      expect(
        processing.resolveEchoCancellationForPlatform(AudioProcessingPlatform.windows),
        isFalse,
      );
      expect(
        processing.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.windows),
        isFalse,
      );
      expect(processing.resolveHighPassFilterForPlatform(AudioProcessingPlatform.windows), isFalse);
    });

    test('Windows overrides can opt in on raw preset', () {
      const processing = AudioProcessingConfig(
        preset: AudioCapturePreset.raw,
        windows: WindowsAudioProcessingConfig(
          usePresetDefaults: true,
          enableNoiseSuppression: true,
          enableEchoCancellation: true,
          enableAutomaticGainControl: true,
          enableHighPassFilter: true,
        ),
      );

      expect(
        processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.windows),
        isTrue,
      );
      expect(
        processing.resolveEchoCancellationForPlatform(AudioProcessingPlatform.windows),
        isTrue,
      );
      expect(
        processing.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.windows),
        isTrue,
      );
      expect(processing.resolveHighPassFilterForPlatform(AudioProcessingPlatform.windows), isTrue);
    });
  });
}
