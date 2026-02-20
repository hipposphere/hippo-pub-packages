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

/// Encoding output options used by recorder-driven workflows.
final class AudioEncodingConfig {
  const AudioEncodingConfig({this.encoder = AudioEncoder.wav, this.bitrateBps, this.aacEncoder});

  final AudioEncoder encoder;
  final int? bitrateBps;
  final AacEncoder? aacEncoder;

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
    encoding.validate();
  }
}

/// Snapshot amplitude values produced by recorder pipelines.
final class Amplitude {
  const Amplitude({required this.current, this.max = 0});

  final double current;
  final double max;
}
