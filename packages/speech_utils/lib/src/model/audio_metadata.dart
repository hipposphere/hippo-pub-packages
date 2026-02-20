final class AudioMetadata {
  const AudioMetadata({
    required this.duration,
    this.sampleRateHz,
    this.channelCount,
    this.bitrateBps,
    this.containerFormat,
    this.codec,
    this.codecProfile,
  });

  final Duration duration;
  final int? sampleRateHz;
  final int? channelCount;
  final int? bitrateBps;
  final String? containerFormat;
  final String? codec;
  final String? codecProfile;
}
