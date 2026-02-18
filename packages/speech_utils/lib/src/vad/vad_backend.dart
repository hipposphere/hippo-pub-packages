import 'dart:typed_data';

/// Determines whether a given PCM16 frame contains speech.
abstract class VadBackend {
  const VadBackend();

  bool isSpeechFrame(
    Int16List interleavedPcm16Samples, {
    required int startSampleOffset,
    required int sampleCount,
    required int sampleRateHz,
    required int channelCount,
  });

  void dispose() {}
}
