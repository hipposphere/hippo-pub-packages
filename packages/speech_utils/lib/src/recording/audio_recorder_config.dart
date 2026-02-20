/// Configuration for native microphone recording.
final class AudioRecorderConfig {
  const AudioRecorderConfig({
    this.sampleRateHz = 16000,
    this.channelCount = 1,
    this.framesPerChunk = 1024,
    this.inputDeviceId,
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
  }
}
