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
    test('creates from plain English keywords with the bundled model', () async {
      final detector = await SherpaOnnxWakeWordDetector.create(
        keywords: const <String>['hey siri'],
      );

      detector.dispose();
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
      expect(adapter.lastSamples, hasLength(3));
      expect(adapter.lastSamples[0], -1.0);
      expect(adapter.lastSamples[1], 0.0);
      expect(adapter.lastSamples[2], closeTo(0.9999, 0.0001));
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

final class _FakeSherpaAdapter implements SherpaOnnxKeywordSpotterAdapter {
  _FakeSherpaAdapter({this.detections = const <String>[]});

  final List<String> detections;
  Float32List lastSamples = Float32List(0);
  int? lastSampleRateHz;
  int resetCount = 0;
  int disposeCount = 0;

  @override
  List<String> acceptSamples(Float32List samples, {required int sampleRateHz}) {
    lastSamples = samples;
    lastSampleRateHz = sampleRateHz;
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
