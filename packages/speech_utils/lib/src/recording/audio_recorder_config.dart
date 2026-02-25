import '../encoding/aac_encoder.dart';

enum AudioEncoder { aacLc, aacHe, aacEld, flac, opus, wav, pcm16bits }

extension AudioEncoderCapabilities on AudioEncoder {
  bool get supportsNativeStartOutput {
    return switch (this) {
      AudioEncoder.wav ||
      AudioEncoder.pcm16bits ||
      AudioEncoder.aacLc ||
      AudioEncoder.aacHe ||
      AudioEncoder.aacEld => true,
      AudioEncoder.flac || AudioEncoder.opus => false,
    };
  }

  bool get supportsNativeStartFile {
    return switch (this) {
      AudioEncoder.wav || AudioEncoder.pcm16bits => true,
      AudioEncoder.aacLc ||
      AudioEncoder.aacHe ||
      AudioEncoder.aacEld ||
      AudioEncoder.flac ||
      AudioEncoder.opus => false,
    };
  }

  bool get supportsVadSegmentationOutput {
    return switch (this) {
      AudioEncoder.wav || AudioEncoder.aacLc || AudioEncoder.aacHe || AudioEncoder.aacEld => true,
      AudioEncoder.pcm16bits || AudioEncoder.flac || AudioEncoder.opus => false,
    };
  }

  bool get isAac {
    return switch (this) {
      AudioEncoder.aacLc || AudioEncoder.aacHe || AudioEncoder.aacEld => true,
      AudioEncoder.flac || AudioEncoder.opus || AudioEncoder.wav || AudioEncoder.pcm16bits => false,
    };
  }

  String get defaultFileExtension {
    return switch (this) {
      AudioEncoder.aacLc || AudioEncoder.aacHe || AudioEncoder.aacEld => 'm4a',
      AudioEncoder.flac => 'flac',
      AudioEncoder.opus => 'opus',
      AudioEncoder.wav => 'wav',
      AudioEncoder.pcm16bits => 'pcm',
    };
  }

  String get defaultMimeType {
    return switch (this) {
      AudioEncoder.aacLc || AudioEncoder.aacHe || AudioEncoder.aacEld => 'audio/aac',
      AudioEncoder.flac => 'audio/flac',
      AudioEncoder.opus => 'audio/opus',
      AudioEncoder.wav => 'audio/wav',
      AudioEncoder.pcm16bits => 'audio/wav',
    };
  }
}

/// Broad signal-processing hint for voice/music capture.
enum AudioCapturePreset { voice, voiceIsolation, raw, music }

/// Cross-platform capture-processing preferences.
///
/// These values are best-effort hints. Native platforms may apply only a
/// subset depending on OS capabilities and active audio route.
///
/// [preset] defines default behavior for optional processing switches.
/// Explicit `enable*` values override preset defaults.
///
/// Preset defaults:
/// - [AudioCapturePreset.voice]: noise suppression, echo cancellation,
///   automatic gain control, and high-pass filter enabled.
/// - [AudioCapturePreset.voiceIsolation]: same defaults as voice plus a
///   stronger voice-isolation request where available.
/// - [AudioCapturePreset.raw]: all optional processing disabled.
/// - [AudioCapturePreset.music]: all optional processing disabled.
final class AudioProcessingConfig {
  const AudioProcessingConfig({
    this.preset = AudioCapturePreset.voice,
    this.enableNoiseSuppression,
    this.enableEchoCancellation,
    this.enableAutomaticGainControl,
    this.enableHighPassFilter,
    this.preferredLatency,
  });

  final AudioCapturePreset preset;

  /// Noise suppression / denoising preference.
  final bool? enableNoiseSuppression;

  /// Acoustic echo cancellation preference.
  final bool? enableEchoCancellation;

  /// Automatic gain control preference.
  final bool? enableAutomaticGainControl;

  /// High-pass filtering preference for low-frequency rumble removal.
  final bool? enableHighPassFilter;

  /// Preferred end-to-end capture latency.
  final Duration? preferredLatency;

  bool get effectiveNoiseSuppression {
    return enableNoiseSuppression ?? _presetNoiseSuppressionDefault(preset);
  }

  bool get effectiveEchoCancellation {
    return enableEchoCancellation ?? _presetEchoCancellationDefault(preset);
  }

  bool get effectiveAutomaticGainControl {
    return enableAutomaticGainControl ?? _presetAutomaticGainControlDefault(preset);
  }

  bool get effectiveHighPassFilter {
    return enableHighPassFilter ?? _presetHighPassFilterDefault(preset);
  }

  void validate() {
    if (preferredLatency != null && preferredLatency! <= Duration.zero) {
      throw ArgumentError.value(
        preferredLatency,
        'preferredLatency',
        'Must be > Duration.zero when provided',
      );
    }
  }
}

bool _presetNoiseSuppressionDefault(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice || AudioCapturePreset.voiceIsolation => true,
    AudioCapturePreset.raw || AudioCapturePreset.music => false,
  };
}

bool _presetEchoCancellationDefault(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice || AudioCapturePreset.voiceIsolation => true,
    AudioCapturePreset.raw || AudioCapturePreset.music => false,
  };
}

bool _presetAutomaticGainControlDefault(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice || AudioCapturePreset.voiceIsolation => true,
    AudioCapturePreset.raw || AudioCapturePreset.music => false,
  };
}

bool _presetHighPassFilterDefault(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice || AudioCapturePreset.voiceIsolation => true,
    AudioCapturePreset.raw || AudioCapturePreset.music => false,
  };
}

enum AppleAudioSessionMode { defaultMode, voiceChat, videoChat, measurement, gameChat, spokenAudio }

/// Apple-specific capture preferences (iOS/macOS).
final class AppleAudioRecorderConfig {
  const AppleAudioRecorderConfig({
    this.sessionMode = AppleAudioSessionMode.voiceChat,
    this.allowBluetoothInput = true,
    this.allowBluetoothA2dp = false,
    this.defaultToSpeaker = true,
    this.mixWithOthers = false,
    this.duckOthers = false,
    this.preferredInputGain,
    this.preferredIoBufferDuration,
  });

  final AppleAudioSessionMode sessionMode;
  final bool allowBluetoothInput;
  final bool allowBluetoothA2dp;
  final bool defaultToSpeaker;
  final bool mixWithOthers;
  final bool duckOthers;

  /// iOS-only input gain hint in [0.0, 1.0].
  final double? preferredInputGain;

  /// iOS/macOS I/O buffer duration hint.
  final Duration? preferredIoBufferDuration;

  void validate() {
    final inputGain = preferredInputGain;
    if (inputGain != null && (inputGain < 0.0 || inputGain > 1.0)) {
      throw ArgumentError.value(
        preferredInputGain,
        'preferredInputGain',
        'Must be in range [0.0, 1.0] when provided',
      );
    }
    if (preferredIoBufferDuration != null && preferredIoBufferDuration! <= Duration.zero) {
      throw ArgumentError.value(
        preferredIoBufferDuration,
        'preferredIoBufferDuration',
        'Must be > Duration.zero when provided',
      );
    }
  }
}

enum WindowsCaptureCategory { media, communications, speech }

/// Windows-specific capture preferences.
final class WindowsAudioRecorderConfig {
  const WindowsAudioRecorderConfig({
    this.captureCategory = WindowsCaptureCategory.speech,
    this.useCommunicationsDevice = false,
    this.useExclusiveMode = false,
    this.useRawCapture = false,
    this.targetBufferDuration,
  });

  final WindowsCaptureCategory captureCategory;

  /// Prefer the communications-role input endpoint on Windows.
  final bool useCommunicationsDevice;

  /// Requests exclusive-mode capture where available.
  final bool useExclusiveMode;

  /// Requests minimally processed/raw capture where available.
  final bool useRawCapture;

  /// Preferred backend capture buffer duration.
  final Duration? targetBufferDuration;

  void validate() {
    if (targetBufferDuration != null && targetBufferDuration! <= Duration.zero) {
      throw ArgumentError.value(
        targetBufferDuration,
        'targetBufferDuration',
        'Must be > Duration.zero when provided',
      );
    }
  }
}

/// Encoding output options used by recorder-driven workflows.
final class AudioEncodingConfig {
  const AudioEncodingConfig({this.encoder = AudioEncoder.wav, this.bitrateBps, this.audioEncoder});

  final AudioEncoder encoder;
  final int? bitrateBps;
  final AacEncoder? audioEncoder;

  void validate() {
    if (bitrateBps != null && bitrateBps! <= 0) {
      throw ArgumentError.value(bitrateBps, 'bitrateBps', 'Must be > 0 when provided');
    }
  }
}

/// Configuration for native microphone recording.
final class AudioRecorderConfig {
  const AudioRecorderConfig({
    this.sampleRateHz = 16000,
    this.channelCount = 1,
    this.framesPerChunk = 1024,
    this.inputDeviceId,
    this.processing = const AudioProcessingConfig(),
    this.appleConfig,
    this.windowsConfig,
    this.encoding = const AudioEncodingConfig(),
  });

  final int sampleRateHz;
  final int channelCount;

  /// Preferred callback/read granularity in PCM frames.
  final int framesPerChunk;

  /// Optional platform-specific input device ID.
  ///
  /// Use `NativeAudioRecorder.listInputDevices()` to discover valid IDs.
  /// If omitted, the recorder uses the current default input route.
  final String? inputDeviceId;

  /// Cross-platform processing preferences (best effort).
  final AudioProcessingConfig processing;

  /// Optional Apple-specific recorder preferences.
  final AppleAudioRecorderConfig? appleConfig;

  /// Optional Windows-specific recorder preferences.
  final WindowsAudioRecorderConfig? windowsConfig;

  final AudioEncodingConfig encoding;

  void validate() {
    if (sampleRateHz <= 0) {
      throw ArgumentError.value(sampleRateHz, 'sampleRateHz', 'Must be > 0');
    }
    if (channelCount <= 0) {
      throw ArgumentError.value(channelCount, 'channelCount', 'Must be > 0');
    }
    if (framesPerChunk <= 0) {
      throw ArgumentError.value(framesPerChunk, 'framesPerChunk', 'Must be > 0');
    }
    final trimmedDeviceId = inputDeviceId?.trim();
    if (trimmedDeviceId != null && trimmedDeviceId.isEmpty) {
      throw ArgumentError.value(inputDeviceId, 'inputDeviceId', 'Must not be blank');
    }
    processing.validate();
    appleConfig?.validate();
    windowsConfig?.validate();
    encoding.validate();
  }
}

/// Snapshot amplitude values produced by recorder pipelines.
final class Amplitude {
  const Amplitude({required this.current, this.max = 0});

  final double current;
  final double max;
}
