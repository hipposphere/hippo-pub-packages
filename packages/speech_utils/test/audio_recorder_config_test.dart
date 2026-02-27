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
          apple: AppleAudioProcessingConfig(usePresetDefaults: true, enableNoiseSuppression: true),
          windows: WindowsAudioProcessingConfig(
            usePresetDefaults: true,
            enableNoiseSuppression: true,
          ),
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

      expect(config.processing.apple.enableNoiseSuppression, isTrue);
      expect(config.processing.windows.enableNoiseSuppression, isTrue);
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

    test('voice preset defaults to voice-oriented processing flags', () {
      const processing = AudioProcessingConfig(preset: AudioCapturePreset.voice);

      expect(processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.apple), isTrue);
      expect(processing.resolveEchoCancellationForPlatform(AudioProcessingPlatform.apple), isTrue);
      expect(
        processing.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.apple),
        isFalse,
      );
      expect(processing.resolveHighPassFilterForPlatform(AudioProcessingPlatform.apple), isFalse);
    });

    test('voice-isolation preset keeps voice defaults enabled', () {
      const processing = AudioProcessingConfig(preset: AudioCapturePreset.voiceIsolation);

      expect(processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.apple), isTrue);
      expect(processing.resolveEchoCancellationForPlatform(AudioProcessingPlatform.apple), isTrue);
      expect(
        processing.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.apple),
        isFalse,
      );
      expect(processing.resolveHighPassFilterForPlatform(AudioProcessingPlatform.apple), isFalse);
    });

    test('raw and music presets default to no optional processing', () {
      const raw = AudioProcessingConfig(preset: AudioCapturePreset.raw);
      const music = AudioProcessingConfig(preset: AudioCapturePreset.music);

      expect(raw.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.apple), isFalse);
      expect(raw.resolveEchoCancellationForPlatform(AudioProcessingPlatform.apple), isFalse);
      expect(raw.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.apple), isFalse);
      expect(raw.resolveHighPassFilterForPlatform(AudioProcessingPlatform.apple), isFalse);

      expect(music.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.apple), isFalse);
      expect(music.resolveEchoCancellationForPlatform(AudioProcessingPlatform.apple), isFalse);
      expect(music.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.apple), isFalse);
      expect(music.resolveHighPassFilterForPlatform(AudioProcessingPlatform.apple), isFalse);
    });

    test('platform overrides can disable voice defaults', () {
      const processing = AudioProcessingConfig(
        preset: AudioCapturePreset.voice,
        apple: AppleAudioProcessingConfig(
          usePresetDefaults: true,
          enableNoiseSuppression: false,
          enableEchoCancellation: false,
          enableAutomaticGainControl: false,
          enableHighPassFilter: false,
        ),
      );

      expect(processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.apple), isFalse);
      expect(processing.resolveEchoCancellationForPlatform(AudioProcessingPlatform.apple), isFalse);
      expect(
        processing.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.apple),
        isFalse,
      );
      expect(processing.resolveHighPassFilterForPlatform(AudioProcessingPlatform.apple), isFalse);
    });

    test('platform overrides can opt in on raw preset', () {
      const processing = AudioProcessingConfig(
        preset: AudioCapturePreset.raw,
        apple: AppleAudioProcessingConfig(
          usePresetDefaults: true,
          enableNoiseSuppression: true,
          enableEchoCancellation: true,
          enableAutomaticGainControl: true,
          enableHighPassFilter: true,
        ),
      );

      expect(processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.apple), isTrue);
      expect(processing.resolveEchoCancellationForPlatform(AudioProcessingPlatform.apple), isTrue);
      expect(
        processing.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.apple),
        isTrue,
      );
      expect(processing.resolveHighPassFilterForPlatform(AudioProcessingPlatform.apple), isTrue);
    });

    test('platform resolution uses preset defaults for Apple and Windows', () {
      const processing = AudioProcessingConfig(preset: AudioCapturePreset.voiceIsolation);

      expect(processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.apple), isTrue);
      expect(processing.resolveEchoCancellationForPlatform(AudioProcessingPlatform.apple), isTrue);
      expect(
        processing.resolveAutomaticGainControlForPlatform(AudioProcessingPlatform.apple),
        isFalse,
      );
      expect(processing.resolveHighPassFilterForPlatform(AudioProcessingPlatform.apple), isFalse);

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

    test('platform overrides can opt in independently per platform', () {
      const processing = AudioProcessingConfig(
        preset: AudioCapturePreset.raw,
        apple: AppleAudioProcessingConfig(enableNoiseSuppression: true),
      );

      expect(processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.apple), isTrue);
      expect(
        processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.windows),
        isFalse,
      );
    });

    test('platform usePresetDefaults can disable preset application', () {
      const processing = AudioProcessingConfig(
        preset: AudioCapturePreset.voiceIsolation,
        apple: AppleAudioProcessingConfig(usePresetDefaults: false),
      );

      expect(processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.apple), isFalse);
      expect(
        processing.resolveNoiseSuppressionForPlatform(AudioProcessingPlatform.windows),
        isTrue,
      );
    });
  });
}
