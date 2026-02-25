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

    test('voice preset defaults to voice-oriented processing flags', () {
      const processing = AudioProcessingConfig(preset: AudioCapturePreset.voice);

      expect(processing.effectiveNoiseSuppression, isTrue);
      expect(processing.effectiveEchoCancellation, isTrue);
      expect(processing.effectiveAutomaticGainControl, isTrue);
      expect(processing.effectiveHighPassFilter, isTrue);
    });

    test('voice-isolation preset keeps voice defaults enabled', () {
      const processing = AudioProcessingConfig(preset: AudioCapturePreset.voiceIsolation);

      expect(processing.effectiveNoiseSuppression, isTrue);
      expect(processing.effectiveEchoCancellation, isTrue);
      expect(processing.effectiveAutomaticGainControl, isTrue);
      expect(processing.effectiveHighPassFilter, isTrue);
    });

    test('raw and music presets default to no optional processing', () {
      const raw = AudioProcessingConfig(preset: AudioCapturePreset.raw);
      const music = AudioProcessingConfig(preset: AudioCapturePreset.music);

      expect(raw.effectiveNoiseSuppression, isFalse);
      expect(raw.effectiveEchoCancellation, isFalse);
      expect(raw.effectiveAutomaticGainControl, isFalse);
      expect(raw.effectiveHighPassFilter, isFalse);

      expect(music.effectiveNoiseSuppression, isFalse);
      expect(music.effectiveEchoCancellation, isFalse);
      expect(music.effectiveAutomaticGainControl, isFalse);
      expect(music.effectiveHighPassFilter, isFalse);
    });

    test('explicit processing flags override preset defaults', () {
      const processing = AudioProcessingConfig(
        preset: AudioCapturePreset.voice,
        enableNoiseSuppression: false,
        enableEchoCancellation: false,
        enableAutomaticGainControl: false,
        enableHighPassFilter: false,
      );

      expect(processing.effectiveNoiseSuppression, isFalse);
      expect(processing.effectiveEchoCancellation, isFalse);
      expect(processing.effectiveAutomaticGainControl, isFalse);
      expect(processing.effectiveHighPassFilter, isFalse);
    });

    test('explicit true flags can opt in on raw preset', () {
      const processing = AudioProcessingConfig(
        preset: AudioCapturePreset.raw,
        enableNoiseSuppression: true,
        enableEchoCancellation: true,
        enableAutomaticGainControl: true,
        enableHighPassFilter: true,
      );

      expect(processing.effectiveNoiseSuppression, isTrue);
      expect(processing.effectiveEchoCancellation, isTrue);
      expect(processing.effectiveAutomaticGainControl, isTrue);
      expect(processing.effectiveHighPassFilter, isTrue);
    });
  });
}
