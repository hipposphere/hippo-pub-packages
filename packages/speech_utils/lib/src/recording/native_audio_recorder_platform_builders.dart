part of 'native_audio_recorder.dart';

abstract base class _NativeRecorderRuntimeConfigBuilder {
  const _NativeRecorderRuntimeConfigBuilder();

  _NativeRecorderRuntimeConfig build(AudioRecorderConfig config);
}

final class _IosNativeRecorderRuntimeConfigBuilder extends _NativeRecorderRuntimeConfigBuilder {
  const _IosNativeRecorderRuntimeConfigBuilder();

  @override
  _NativeRecorderRuntimeConfig build(AudioRecorderConfig config) {
    final processing = config.processing;
    final ios = config.iosConfig;
    final preferredLatency = processing.preferredLatency;
    final preferredIoDuration = ios?.preferredIoBufferDuration ?? preferredLatency;

    final iosSessionMode = ios?.sessionMode ?? _defaultIosSessionModeForPreset(processing.preset);

    return _NativeRecorderRuntimeConfig(
      processingFlags: _buildProcessingFlagsForPlatform(
        config: config,
        platform: AudioProcessingPlatform.ios,
      ),
      iosSessionModeCode: _encodeIosSessionMode(iosSessionMode),
      iosCategoryOptionsFlags: _buildIosCategoryOptionsFlags(ios),
      preferredLatencySeconds: _durationSecondsOrZero(preferredLatency),
      iosPreferredIoBufferDurationSeconds: _durationSecondsOrZero(preferredIoDuration),
      iosPreferredInputGain: ios?.preferredInputGain ?? -1.0,
      fileBitrateBps: _resolveAppleFileBitrateBps(config),
      fileEncoderCode: _encodeFileEncoder(config.encoding.encoder),
      macosProcessingQueueDurationSeconds: 0.0,
      windowsPreferredPeriodFrames: 0,
      windowsFlags: 0,
      windowsCaptureCategoryCode: _encodeWindowsCaptureCategory(null),
      windowsUseCommunicationsDevice: 0,
      windowsVoiceProcessingModeCode: _encodeWindowsVoiceProcessingMode(null),
    );
  }
}

final class _MacosNativeRecorderRuntimeConfigBuilder extends _NativeRecorderRuntimeConfigBuilder {
  const _MacosNativeRecorderRuntimeConfigBuilder();

  @override
  _NativeRecorderRuntimeConfig build(AudioRecorderConfig config) {
    final processing = config.processing;
    final macos = config.macosConfig;
    final preferredLatency = processing.preferredLatency;
    final macosQueueDuration = macos?.processingQueueDuration ?? preferredLatency;

    return _NativeRecorderRuntimeConfig(
      processingFlags: _buildProcessingFlagsForPlatform(
        config: config,
        platform: AudioProcessingPlatform.macos,
      ),
      iosSessionModeCode: 0,
      iosCategoryOptionsFlags: 0,
      preferredLatencySeconds: _durationSecondsOrZero(preferredLatency),
      iosPreferredIoBufferDurationSeconds: 0.0,
      iosPreferredInputGain: -1.0,
      fileBitrateBps: _resolveAppleFileBitrateBps(config),
      fileEncoderCode: _encodeFileEncoder(config.encoding.encoder),
      macosProcessingQueueDurationSeconds: _durationSecondsOrZero(macosQueueDuration),
      windowsPreferredPeriodFrames: 0,
      windowsFlags: 0,
      windowsCaptureCategoryCode: _encodeWindowsCaptureCategory(null),
      windowsUseCommunicationsDevice: 0,
      windowsVoiceProcessingModeCode: _encodeWindowsVoiceProcessingMode(null),
    );
  }
}

final class _WindowsNativeRecorderRuntimeConfigBuilder
    extends _NativeRecorderRuntimeConfigBuilder {
  const _WindowsNativeRecorderRuntimeConfigBuilder();

  @override
  _NativeRecorderRuntimeConfig build(AudioRecorderConfig config) {
    final processing = config.processing;
    final windows = config.windowsConfig;
    final preferredLatency = processing.preferredLatency;
    final windowsTargetDuration = windows?.targetBufferDuration ?? preferredLatency;
    final windowsPreferredPeriodFrames = windowsTargetDuration == null
        ? 0
        : (((windowsTargetDuration.inMicroseconds * config.sampleRateHz) ~/
                    Duration.microsecondsPerSecond)
                .clamp(0, 0x7fffffff));

    return _NativeRecorderRuntimeConfig(
      processingFlags: _buildProcessingFlagsForPlatform(
        config: config,
        platform: AudioProcessingPlatform.windows,
      ),
      iosSessionModeCode: 0,
      iosCategoryOptionsFlags: 0,
      preferredLatencySeconds: _durationSecondsOrZero(preferredLatency),
      iosPreferredIoBufferDurationSeconds: 0.0,
      iosPreferredInputGain: -1.0,
      fileBitrateBps: 0,
      fileEncoderCode: _fileEncoderAacLc,
      macosProcessingQueueDurationSeconds: 0.0,
      windowsPreferredPeriodFrames: windowsPreferredPeriodFrames,
      windowsFlags: _buildWindowsFlags(windows),
      windowsCaptureCategoryCode: _encodeWindowsCaptureCategory(windows?.captureCategory),
      windowsUseCommunicationsDevice: windows?.useCommunicationsDevice == true ? 1 : 0,
      windowsVoiceProcessingModeCode: _encodeWindowsVoiceProcessingMode(windows?.voiceProcessingMode),
    );
  }

  int _buildWindowsFlags(WindowsAudioRecorderConfig? windows) {
    var windowsFlags = 0;
    if (windows?.useExclusiveMode ?? false) {
      windowsFlags |= _windowsFlagExclusiveMode;
    }
    if (windows?.useRawCapture ?? false) {
      windowsFlags |= _windowsFlagRawCapture;
    }
    return windowsFlags;
  }
}

int _buildIosCategoryOptionsFlags(IosAudioRecorderConfig? iosConfig) {
  var iosCategoryOptionsFlags = 0;
  if (iosConfig?.allowBluetoothInput ?? false) {
    iosCategoryOptionsFlags |= _iosCategoryOptionAllowBluetooth;
  }
  if (iosConfig?.allowBluetoothA2dp ?? false) {
    iosCategoryOptionsFlags |= _iosCategoryOptionAllowBluetoothA2dp;
  }
  if (iosConfig?.defaultToSpeaker ?? false) {
    iosCategoryOptionsFlags |= _iosCategoryOptionDefaultToSpeaker;
  }
  if (iosConfig?.mixWithOthers ?? false) {
    iosCategoryOptionsFlags |= _iosCategoryOptionMixWithOthers;
  }
  if (iosConfig?.duckOthers ?? false) {
    iosCategoryOptionsFlags |= _iosCategoryOptionDuckOthers;
  }
  return iosCategoryOptionsFlags;
}

int _buildProcessingFlagsForPlatform({
  required AudioRecorderConfig config,
  required AudioProcessingPlatform platform,
}) {
  final processing = config.processing;
  var processingFlags = _processingPresetFlags(processing.preset);

  if (platform == AudioProcessingPlatform.windows) {
    if (processing.resolveNoiseSuppressionForPlatform(platform)) {
      processingFlags |= _processingFlagNoiseSuppression;
    }
    if (processing.resolveEchoCancellationForPlatform(platform)) {
      processingFlags |= _processingFlagEchoCancellation;
    }
    if (processing.resolveAutomaticGainControlForPlatform(platform)) {
      processingFlags |= _processingFlagAutomaticGainControl;
    }
    if (processing.resolveHighPassFilterForPlatform(platform)) {
      processingFlags |= _processingFlagHighPassFilter;
    }
  }

  return processingFlags;
}

double _durationSecondsOrZero(Duration? duration) {
  return duration == null ? 0.0 : duration.inMicroseconds / Duration.microsecondsPerSecond;
}

int _resolveAppleFileBitrateBps(AudioRecorderConfig config) {
  return config.encoding.encoder.isAac ? _resolveEncodingBitrateBps(config.encoding) : 0;
}
