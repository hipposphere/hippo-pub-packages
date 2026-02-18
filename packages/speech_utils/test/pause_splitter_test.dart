import 'dart:math' as math;
import 'dart:typed_data';

import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  group('SpeechUtils.splitPcm16OnSilence', () {
    const options = PauseSplitOptions(
      sampleRateHz: 16000,
      channelCount: 1,
      frameDuration: Duration(milliseconds: 20),
      minSpeechDuration: Duration(milliseconds: 100),
      minSilenceDuration: Duration(milliseconds: 500),
      preSpeechPadding: Duration.zero,
      postSpeechPadding: Duration.zero,
    );

    test('splits snippets when silence exceeds threshold', () {
      final samples = _concatInt16([
        _sineWave(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 500)),
        _silence(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 900)),
        _sineWave(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 400)),
      ]);
      final bytes = Uint8List.view(samples.buffer);

      final snippets = SpeechUtils.splitPcm16OnSilence(
        pcm16leBytes: bytes,
        options: options,
        vadConfig: const SpeechVadConfig.energyOnly(),
      );

      expect(snippets, hasLength(2));
      expect(snippets[0].duration.inMilliseconds, inInclusiveRange(440, 560));
      expect(snippets[1].duration.inMilliseconds, inInclusiveRange(340, 460));
    });

    test('returns zero-copy snippet views', () {
      final samples = _concatInt16([
        _sineWave(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 400)),
      ]);
      final bytes = Uint8List.view(samples.buffer);

      final snippets = SpeechUtils.splitPcm16OnSilence(
        pcm16leBytes: bytes,
        options: options.copyWith(minSilenceDuration: const Duration(milliseconds: 100)),
        vadConfig: const SpeechVadConfig.energyOnly(),
      );

      expect(snippets, hasLength(1));
      final snippetBytes = snippets.first.asBytesView();
      final originalFirstSample = samples[0];
      samples[0] = 0;
      expect(snippetBytes[0], equals(0));
      expect(snippetBytes[1], equals(0));
      samples[0] = originalFirstSample;
    });

    test('drops speech segments shorter than minSpeechDuration', () {
      final samples = _concatInt16([
        _sineWave(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 40)),
        _silence(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 900)),
      ]);
      final bytes = Uint8List.view(samples.buffer);

      final snippets = SpeechUtils.splitPcm16OnSilence(
        pcm16leBytes: bytes,
        options: options,
        vadConfig: const SpeechVadConfig.energyOnly(),
      );

      expect(snippets, isEmpty);
    });

    test('handles unaligned source byte offsets', () {
      final samples = _concatInt16([
        _sineWave(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 500)),
        _silence(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 900)),
        _sineWave(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 400)),
      ]);
      final alignedBytes = Uint8List.view(samples.buffer);
      final padded = Uint8List(alignedBytes.lengthInBytes + 1);
      padded.setRange(1, padded.lengthInBytes, alignedBytes);
      final unalignedBytes = Uint8List.sublistView(padded, 1);
      expect(unalignedBytes.offsetInBytes.isOdd, isTrue);

      final snippets = SpeechUtils.splitPcm16OnSilence(
        pcm16leBytes: unalignedBytes,
        options: options,
        vadConfig: const SpeechVadConfig.energyOnly(),
      );

      expect(snippets, hasLength(2));
      expect(snippets[0].duration.inMilliseconds, inInclusiveRange(440, 560));
      expect(snippets[1].duration.inMilliseconds, inInclusiveRange(340, 460));
    });
  });
}

extension on PauseSplitOptions {
  PauseSplitOptions copyWith({
    int? sampleRateHz,
    int? channelCount,
    Duration? frameDuration,
    Duration? minSpeechDuration,
    Duration? minSilenceDuration,
    Duration? preSpeechPadding,
    Duration? postSpeechPadding,
  }) {
    return PauseSplitOptions(
      sampleRateHz: sampleRateHz ?? this.sampleRateHz,
      channelCount: channelCount ?? this.channelCount,
      frameDuration: frameDuration ?? this.frameDuration,
      minSpeechDuration: minSpeechDuration ?? this.minSpeechDuration,
      minSilenceDuration: minSilenceDuration ?? this.minSilenceDuration,
      preSpeechPadding: preSpeechPadding ?? this.preSpeechPadding,
      postSpeechPadding: postSpeechPadding ?? this.postSpeechPadding,
    );
  }
}

Int16List _sineWave({
  required int sampleRateHz,
  required Duration duration,
  double amplitude = 0.65,
  double frequencyHz = 220.0,
}) {
  final sampleCount = (sampleRateHz * duration.inMicroseconds / Duration.microsecondsPerSecond)
      .round();
  final output = Int16List(sampleCount);

  for (var i = 0; i < sampleCount; i++) {
    final sample = math.sin((2 * math.pi * frequencyHz * i) / sampleRateHz);
    output[i] = (sample * amplitude * 32767.0).round();
  }
  return output;
}

Int16List _silence({required int sampleRateHz, required Duration duration}) {
  final sampleCount = (sampleRateHz * duration.inMicroseconds / Duration.microsecondsPerSecond)
      .round();
  return Int16List(sampleCount);
}

Int16List _concatInt16(List<Int16List> segments) {
  final totalLength = segments.fold<int>(0, (sum, segment) => sum + segment.length);
  final output = Int16List(totalLength);
  var offset = 0;
  for (final segment in segments) {
    output.setRange(offset, offset + segment.length, segment);
    offset += segment.length;
  }
  return output;
}
