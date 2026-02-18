/// Configuration for splitting PCM16 streams on silence.
final class PauseSplitOptions {
  const PauseSplitOptions({
    required this.sampleRateHz,
    this.channelCount = 1,
    this.frameDuration = const Duration(milliseconds: 20),
    this.minSpeechDuration = const Duration(milliseconds: 200),
    this.minSilenceDuration = const Duration(milliseconds: 700),
    this.preSpeechPadding = const Duration(milliseconds: 80),
    this.postSpeechPadding = const Duration(milliseconds: 120),
  });

  final int sampleRateHz;
  final int channelCount;
  final Duration frameDuration;
  final Duration minSpeechDuration;
  final Duration minSilenceDuration;
  final Duration preSpeechPadding;
  final Duration postSpeechPadding;

  void validate() {
    if (sampleRateHz <= 0) {
      throw ArgumentError.value(sampleRateHz, 'sampleRateHz', 'Must be > 0');
    }
    if (channelCount <= 0) {
      throw ArgumentError.value(channelCount, 'channelCount', 'Must be > 0');
    }
    if (frameDuration <= Duration.zero) {
      throw ArgumentError.value(frameDuration, 'frameDuration', 'Must be > 0');
    }
    if (minSpeechDuration < Duration.zero) {
      throw ArgumentError.value(minSpeechDuration, 'minSpeechDuration', 'Must be >= 0');
    }
    if (minSilenceDuration < Duration.zero) {
      throw ArgumentError.value(minSilenceDuration, 'minSilenceDuration', 'Must be >= 0');
    }
    if (preSpeechPadding < Duration.zero) {
      throw ArgumentError.value(preSpeechPadding, 'preSpeechPadding', 'Must be >= 0');
    }
    if (postSpeechPadding < Duration.zero) {
      throw ArgumentError.value(postSpeechPadding, 'postSpeechPadding', 'Must be >= 0');
    }
  }

  int get frameSampleCountPerChannel {
    final micros = frameDuration.inMicroseconds;
    final samples = (sampleRateHz * micros / Duration.microsecondsPerSecond).round();
    return samples <= 0 ? 1 : samples;
  }

  int get frameSampleCount => frameSampleCountPerChannel * channelCount;

  int framesFor(Duration duration) {
    if (duration <= Duration.zero) {
      return 0;
    }
    return (duration.inMicroseconds / frameDuration.inMicroseconds).ceil();
  }
}
