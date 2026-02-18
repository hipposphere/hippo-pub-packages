import 'dart:math' as math;
import 'dart:typed_data';

import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  const options = PauseSplitOptions(
    sampleRateHz: 16000,
    channelCount: 1,
    frameDuration: Duration(milliseconds: 20),
    minSpeechDuration: Duration(milliseconds: 100),
    minSilenceDuration: Duration(milliseconds: 500),
    preSpeechPadding: Duration.zero,
    postSpeechPadding: Duration.zero,
  );

  test('splits live PCM stream into snippets', () async {
    final samples = _concatInt16([
      _sineWave(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 500)),
      _silence(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 900)),
      _sineWave(sampleRateHz: options.sampleRateHz, duration: const Duration(milliseconds: 400)),
    ]);
    final bytes = Uint8List.view(samples.buffer);

    final stream = _chunkedStream(bytes, <int>[111, 77, 205, 513, 89, 44, 333]);
    final snippets = await SpeechUtils.splitPcm16StreamOnSilence(
      pcm16leStream: stream,
      options: options,
      vadConfig: const SpeechVadConfig.energyOnly(),
    ).toList();

    expect(snippets, hasLength(2));
    expect(snippets[0].duration.inMilliseconds, inInclusiveRange(440, 560));
    expect(snippets[1].duration.inMilliseconds, inInclusiveRange(340, 460));
  });

  test('flush emits final active segment without trailing silence', () async {
    final samples = _sineWave(
      sampleRateHz: options.sampleRateHz,
      duration: const Duration(milliseconds: 450),
    );
    final bytes = Uint8List.view(samples.buffer);

    final snippets = await SpeechUtils.splitPcm16StreamOnSilence(
      pcm16leStream: _chunkedStream(bytes, <int>[95, 43, 128]),
      options: options,
      vadConfig: const SpeechVadConfig.energyOnly(),
    ).toList();

    expect(snippets, hasLength(1));
    expect(snippets.single.duration.inMilliseconds, inInclusiveRange(380, 500));
  });

  test('handles stream chunks with unaligned byte offsets', () async {
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

    final snippets = await SpeechUtils.splitPcm16StreamOnSilence(
      pcm16leStream: _chunkedStream(unalignedBytes, <int>[111, 77, 205, 513, 89, 44, 333]),
      options: options,
      vadConfig: const SpeechVadConfig.energyOnly(),
    ).toList();

    expect(snippets, hasLength(2));
    expect(snippets[0].duration.inMilliseconds, inInclusiveRange(440, 560));
    expect(snippets[1].duration.inMilliseconds, inInclusiveRange(340, 460));
  });
}

Stream<Uint8List> _chunkedStream(Uint8List bytes, List<int> chunkSizes) async* {
  var offset = 0;
  var chunkIndex = 0;
  while (offset < bytes.lengthInBytes) {
    final configured = chunkSizes[chunkIndex % chunkSizes.length];
    final chunkSize = math.min(configured, bytes.lengthInBytes - offset);
    yield Uint8List.sublistView(bytes, offset, offset + chunkSize);
    offset += chunkSize;
    chunkIndex++;
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
