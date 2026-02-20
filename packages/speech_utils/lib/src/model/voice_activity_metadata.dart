final class VoiceActivityMetadata {
  const VoiceActivityMetadata({
    this.speechFrameCount,
    this.analyzedFrameCount,
    this.speechProbability,
  });

  final int? speechFrameCount;
  final int? analyzedFrameCount;
  final double? speechProbability;
}
