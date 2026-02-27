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

/// Platform scope used to resolve runtime processing toggles.
enum AudioProcessingPlatform { apple, windows, generic }

/// Apple-specific processing overrides nested under [AudioProcessingConfig].
///
/// By default, Apple capture applies preset defaults when no explicit override
/// is provided.
final class AppleAudioProcessingConfig {
  const AppleAudioProcessingConfig({
    this.usePresetDefaults = true,
    this.enableNoiseSuppression,
    this.enableEchoCancellation,
    this.enableAutomaticGainControl,
    this.enableHighPassFilter,
  });

  /// Whether preset defaults should be used when no explicit toggle is provided.
  final bool usePresetDefaults;
  final bool? enableNoiseSuppression;
  final bool? enableEchoCancellation;
  final bool? enableAutomaticGainControl;
  final bool? enableHighPassFilter;
}

/// Windows-specific processing overrides nested under [AudioProcessingConfig].
///
/// By default, Windows capture uses preset defaults when no explicit toggle is set.
final class WindowsAudioProcessingConfig {
  const WindowsAudioProcessingConfig({
    this.usePresetDefaults = true,
    this.enableNoiseSuppression,
    this.enableEchoCancellation,
    this.enableAutomaticGainControl,
    this.enableHighPassFilter,
  });

  /// Whether preset defaults should be used when no explicit toggle is provided.
  final bool usePresetDefaults;
  final bool? enableNoiseSuppression;
  final bool? enableEchoCancellation;
  final bool? enableAutomaticGainControl;
  final bool? enableHighPassFilter;
}

/// Cross-platform capture-processing preferences.
///
/// These values are best-effort hints. Native platforms may apply only a
/// subset depending on OS capabilities and active audio route.
///
/// [preset] defines default behavior for optional processing switches, while
/// per-platform overrides are configured via [apple] and [windows].
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
    this.preferredLatency,
    this.apple = const AppleAudioProcessingConfig(),
    this.windows = const WindowsAudioProcessingConfig(),
  });

  final AudioCapturePreset preset;

  /// Preferred end-to-end capture latency.
  final Duration? preferredLatency;

  /// Apple-specific processing overrides.
  final AppleAudioProcessingConfig apple;

  /// Windows-specific processing overrides.
  final WindowsAudioProcessingConfig windows;

  /// Resolves noise suppression after applying platform-specific overrides.
  bool resolveNoiseSuppressionForPlatform(AudioProcessingPlatform platform) {
    return _resolveProcessingToggleForPlatform(
      platform: platform,
      appleOverride: apple.enableNoiseSuppression,
      windowsOverride: windows.enableNoiseSuppression,
      applePresetDefault: _applePresetNoiseSuppressionDefault(preset),
      windowsPresetDefault: _windowsPresetNoiseSuppressionDefault(preset),
      genericPresetDefault: _presetNoiseSuppressionDefault(preset),
      appleUsePresetDefaults: apple.usePresetDefaults,
      windowsUsePresetDefaults: windows.usePresetDefaults,
    );
  }

  /// Resolves echo cancellation after applying platform-specific overrides.
  bool resolveEchoCancellationForPlatform(AudioProcessingPlatform platform) {
    return _resolveProcessingToggleForPlatform(
      platform: platform,
      appleOverride: apple.enableEchoCancellation,
      windowsOverride: windows.enableEchoCancellation,
      applePresetDefault: _applePresetEchoCancellationDefault(preset),
      windowsPresetDefault: _windowsPresetEchoCancellationDefault(preset),
      genericPresetDefault: _presetEchoCancellationDefault(preset),
      appleUsePresetDefaults: apple.usePresetDefaults,
      windowsUsePresetDefaults: windows.usePresetDefaults,
    );
  }

  /// Resolves AGC after applying platform-specific overrides.
  bool resolveAutomaticGainControlForPlatform(AudioProcessingPlatform platform) {
    return _resolveProcessingToggleForPlatform(
      platform: platform,
      appleOverride: apple.enableAutomaticGainControl,
      windowsOverride: windows.enableAutomaticGainControl,
      applePresetDefault: _applePresetAutomaticGainControlDefault(preset),
      windowsPresetDefault: _windowsPresetAutomaticGainControlDefault(preset),
      genericPresetDefault: _presetAutomaticGainControlDefault(preset),
      appleUsePresetDefaults: apple.usePresetDefaults,
      windowsUsePresetDefaults: windows.usePresetDefaults,
    );
  }

  /// Resolves high-pass filtering after applying platform-specific overrides.
  bool resolveHighPassFilterForPlatform(AudioProcessingPlatform platform) {
    return _resolveProcessingToggleForPlatform(
      platform: platform,
      appleOverride: apple.enableHighPassFilter,
      windowsOverride: windows.enableHighPassFilter,
      applePresetDefault: _applePresetHighPassFilterDefault(preset),
      windowsPresetDefault: _windowsPresetHighPassFilterDefault(preset),
      genericPresetDefault: _presetHighPassFilterDefault(preset),
      appleUsePresetDefaults: apple.usePresetDefaults,
      windowsUsePresetDefaults: windows.usePresetDefaults,
    );
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

bool _applePresetNoiseSuppressionDefault(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice || AudioCapturePreset.voiceIsolation => true,
    AudioCapturePreset.raw || AudioCapturePreset.music => false,
  };
}

bool _applePresetEchoCancellationDefault(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice || AudioCapturePreset.voiceIsolation => true,
    AudioCapturePreset.raw || AudioCapturePreset.music => false,
  };
}

bool _applePresetAutomaticGainControlDefault(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice || AudioCapturePreset.voiceIsolation => false,
    AudioCapturePreset.raw || AudioCapturePreset.music => false,
  };
}

bool _applePresetHighPassFilterDefault(AudioCapturePreset preset) {
  return switch (preset) {
    AudioCapturePreset.voice || AudioCapturePreset.voiceIsolation => false,
    AudioCapturePreset.raw || AudioCapturePreset.music => false,
  };
}

bool _windowsPresetNoiseSuppressionDefault(AudioCapturePreset preset) {
  return _presetNoiseSuppressionDefault(preset);
}

bool _windowsPresetEchoCancellationDefault(AudioCapturePreset preset) {
  return _presetEchoCancellationDefault(preset);
}

bool _windowsPresetAutomaticGainControlDefault(AudioCapturePreset preset) {
  return _presetAutomaticGainControlDefault(preset);
}

bool _windowsPresetHighPassFilterDefault(AudioCapturePreset preset) {
  return _presetHighPassFilterDefault(preset);
}

bool _resolveProcessingToggleForPlatform({
  required AudioProcessingPlatform platform,
  required bool? appleOverride,
  required bool? windowsOverride,
  required bool applePresetDefault,
  required bool windowsPresetDefault,
  required bool genericPresetDefault,
  required bool appleUsePresetDefaults,
  required bool windowsUsePresetDefaults,
}) {
  switch (platform) {
    case AudioProcessingPlatform.apple:
      if (appleOverride != null) {
        return appleOverride;
      }
      return appleUsePresetDefaults ? applePresetDefault : false;
    case AudioProcessingPlatform.windows:
      if (windowsOverride != null) {
        return windowsOverride;
      }
      return windowsUsePresetDefaults ? windowsPresetDefault : false;
    case AudioProcessingPlatform.generic:
      return genericPresetDefault;
  }
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

/// Windows-specific voice-processing backend preference.
enum WindowsVoiceProcessingMode { auto, system, software, off }

/// Windows-specific capture preferences.
final class WindowsAudioRecorderConfig {
  const WindowsAudioRecorderConfig({
    this.captureCategory = WindowsCaptureCategory.speech,
    this.useCommunicationsDevice = false,
    this.useExclusiveMode = false,
    this.useRawCapture = false,
    this.voiceProcessingMode = WindowsVoiceProcessingMode.auto,
    this.targetBufferDuration,
  });

  final WindowsCaptureCategory captureCategory;

  /// Prefer the communications-role input endpoint on Windows.
  final bool useCommunicationsDevice;

  /// Requests exclusive-mode capture where available.
  final bool useExclusiveMode;

  /// Requests minimally processed/raw capture where available.
  final bool useRawCapture;

  /// Selects Windows voice-processing backend strategy.
  ///
  /// - [WindowsVoiceProcessingMode.auto]: prefer OS deep noise suppression and
  ///   fallback to built-in software processing.
  /// - [WindowsVoiceProcessingMode.system]: require OS deep noise suppression.
  /// - [WindowsVoiceProcessingMode.software]: always use built-in software
  ///   processing.
  /// - [WindowsVoiceProcessingMode.off]: disable voice processing.
  final WindowsVoiceProcessingMode voiceProcessingMode;

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
