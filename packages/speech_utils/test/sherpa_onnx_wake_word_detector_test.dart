import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart' show TestWidgetsFlutterBinding;
import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SherpaOnnxWakeWordDetectorConfig', () {
    test('accepts a valid keyword buffer configuration', () {
      const config = SherpaOnnxWakeWordDetectorConfig(
        tokensPath: 'tokens.txt',
        encoderPath: 'encoder.onnx',
        decoderPath: 'decoder.onnx',
        joinerPath: 'joiner.onnx',
        keywordsBuffer: '▁HE Y ▁D IC TO :1.5 #0.35 @hey_dicto\n',
      );

      expect(config.validate, returnsNormally);
      expect(config.maxActivePaths, 16);
    });

    test('requires keyword source', () {
      const config = SherpaOnnxWakeWordDetectorConfig(
        tokensPath: 'tokens.txt',
        encoderPath: 'encoder.onnx',
        decoderPath: 'decoder.onnx',
        joinerPath: 'joiner.onnx',
      );

      expect(config.validate, throwsArgumentError);
    });
  });

  group('SherpaOnnxWakeWordDetector', () {
    test('creates from an unknown product-name keyword with the bundled model', () async {
      final detector = await SherpaOnnxWakeWordDetector.create(
        keywords: const <String>['hey dicto'],
      );

      detector.dispose();
    });

    test('detects a keyword in sherpa reference audio', () async {
      final detector = await SherpaOnnxWakeWordDetector.create(
        keywords: const <String>['light up'],
      );
      addTearDown(detector.dispose);

      final events = _detectInWav(
        detector,
        File('test/fixtures/sherpa_kws_light_up.wav').readAsBytesSync(),
        keyword: 'light up',
        sensitivity: 0.5,
      );

      expect(events.map((event) => event.keyword), contains('light up'));
    });

    test('rejects an empty plain-text keyword list', () async {
      await expectLater(
        SherpaOnnxWakeWordDetector.create(keywords: const <String>[]),
        throwsArgumentError,
      );
    });

    test('converts PCM16 chunks and filters configured keyword labels', () {
      final adapter = _FakeSherpaAdapter(detections: <String>['@hey_dicto', '@other']);
      final detector = SherpaOnnxWakeWordDetector.custom(adapter: adapter);
      final pcm = Int16List.fromList(<int>[-32768, 0, 32767]);

      final events = detector.addChunk(
        Uint8List.view(pcm.buffer),
        sampleRateHz: 16000,
        channelCount: 1,
        config: const WakeWordDetectionConfig(keywords: <String>['hey dicto']),
      );

      expect(events, hasLength(1));
      expect(events.single.keyword, 'hey dicto');
      expect(adapter.lastSampleRateHz, 16000);
      expect(adapter.lastSensitivity, 0.5);
      expect(adapter.lastSamples, hasLength(3));
      expect(adapter.lastSamples[0], -1.0);
      expect(adapter.lastSamples[1], 0.0);
      expect(adapter.lastSamples[2], closeTo(0.9999, 0.0001));
    });

    test('maps higher sensitivity to a lower threshold and higher boost', () {
      expect(SherpaOnnxWakeWordDetector.keywordThresholdForSensitivity(0), 0.8);
      expect(SherpaOnnxWakeWordDetector.keywordThresholdForSensitivity(0.5), closeTo(0.2375, 1e-9));
      expect(SherpaOnnxWakeWordDetector.keywordThresholdForSensitivity(0.9), closeTo(0.0575, 1e-9));
      expect(SherpaOnnxWakeWordDetector.keywordThresholdForSensitivity(1), 0.05);
      expect(SherpaOnnxWakeWordDetector.keywordScoreForSensitivity(0.5), 1);
      expect(SherpaOnnxWakeWordDetector.keywordScoreForSensitivity(0.9), closeTo(1.76, 1e-9));
      expect(SherpaOnnxWakeWordDetector.keywordScoreForSensitivity(1), 2);
    });

    test('rejects non-mono PCM', () {
      final detector = SherpaOnnxWakeWordDetector.custom(adapter: _FakeSherpaAdapter());

      expect(
        () => detector.addChunk(
          Uint8List(4),
          sampleRateHz: 16000,
          channelCount: 2,
          config: const WakeWordDetectionConfig(keywords: <String>['hey dicto']),
        ),
        throwsArgumentError,
      );
    });

    test('forwards reset and dispose to adapter', () {
      final adapter = _FakeSherpaAdapter();
      final detector = SherpaOnnxWakeWordDetector.custom(adapter: adapter);

      detector.reset();
      detector.dispose();
      detector.dispose();

      expect(adapter.resetCount, 1);
      expect(adapter.disposeCount, 1);
    });
  });
}

List<WakeWordEvent> _detectInWav(
  SherpaOnnxWakeWordDetector detector,
  Uint8List wavBytes, {
  required String keyword,
  required double sensitivity,
}) {
  final pcm = _wavPcmData(wavBytes);
  final events = <WakeWordEvent>[];
  const chunkBytes = 3200;
  for (var offset = 0; offset < pcm.length; offset += chunkBytes) {
    final end = (offset + chunkBytes).clamp(0, pcm.length);
    events.addAll(
      detector.addChunk(
        Uint8List.sublistView(pcm, offset, end),
        sampleRateHz: 16000,
        channelCount: 1,
        config: WakeWordDetectionConfig(keywords: <String>[keyword], sensitivity: sensitivity),
      ),
    );
  }
  for (var i = 0; i < 10; i++) {
    events.addAll(
      detector.addChunk(
        Uint8List(chunkBytes),
        sampleRateHz: 16000,
        channelCount: 1,
        config: WakeWordDetectionConfig(keywords: <String>[keyword], sensitivity: sensitivity),
      ),
    );
  }
  return events;
}

Uint8List _wavPcmData(Uint8List wavBytes) {
  final data = ByteData.sublistView(wavBytes);
  var offset = 12;
  while (offset + 8 <= wavBytes.length) {
    final chunkName = ascii.decode(wavBytes.sublist(offset, offset + 4));
    final chunkLength = data.getUint32(offset + 4, Endian.little);
    final payloadOffset = offset + 8;
    if (chunkName == 'data') {
      return Uint8List.sublistView(wavBytes, payloadOffset, payloadOffset + chunkLength);
    }
    offset = payloadOffset + chunkLength + chunkLength.remainder(2);
  }
  throw const FormatException('WAV data chunk not found');
}

final class _FakeSherpaAdapter implements SherpaOnnxKeywordSpotterAdapter {
  _FakeSherpaAdapter({this.detections = const <String>[]});

  final List<String> detections;
  Float32List lastSamples = Float32List(0);
  int? lastSampleRateHz;
  double? lastSensitivity;
  int resetCount = 0;
  int disposeCount = 0;

  @override
  List<String> acceptSamples(
    Float32List samples, {
    required int sampleRateHz,
    required double sensitivity,
  }) {
    lastSamples = samples;
    lastSampleRateHz = sampleRateHz;
    lastSensitivity = sensitivity;
    return detections;
  }

  @override
  void reset() {
    resetCount++;
  }

  @override
  void dispose() {
    disposeCount++;
  }
}
