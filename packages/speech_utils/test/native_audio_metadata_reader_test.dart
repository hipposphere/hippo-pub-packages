import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NativeAudioMetadataReader', () {
    test('reads metadata via selected platform bridge', () async {
      final reader = NativeAudioMetadataReader(
        platform: NativeAudioMetadataPlatform.windows,
        windowsAvailabilityFn: () => true,
        windowsReadFn: (inputPath) {
          expect(inputPath, 'input.wav');
          return const AudioMetadataNativeResult(
            resultCode: 0,
            durationMicros: 1234567,
            sampleRateHz: 48000,
            channelCount: 2,
            bitrateBps: 192000,
          );
        },
      );

      final metadata = await reader.readAudioMetadata(inputPath: 'input.wav');
      expect(metadata.duration, const Duration(microseconds: 1234567));
      expect(metadata.sampleRateHz, 48000);
      expect(metadata.channelCount, 2);
      expect(metadata.bitrateBps, 192000);
      expect(await reader.isAvailable(), isTrue);
    });

    test('readAudioDuration returns metadata duration', () async {
      final reader = NativeAudioMetadataReader(
        platform: NativeAudioMetadataPlatform.android,
        androidReadFn: (_) => const AudioMetadataNativeResult(resultCode: 0, durationMicros: 42000),
        androidAvailabilityFn: () => true,
      );

      final duration = await reader.readAudioDuration(inputPath: 'clip.m4a');
      expect(duration, const Duration(microseconds: 42000));
    });

    test('maps non-positive optional fields to null', () async {
      final reader = NativeAudioMetadataReader(
        platform: NativeAudioMetadataPlatform.iOS,
        iosReadFn: (_) =>
            const AudioMetadataNativeResult(resultCode: 0, durationMicros: 1000, bitrateBps: -1),
        iosAvailabilityFn: () => true,
      );

      final metadata = await reader.readAudioMetadata(inputPath: 'clip.m4a');
      expect(metadata.sampleRateHz, isNull);
      expect(metadata.channelCount, isNull);
      expect(metadata.bitrateBps, isNull);
    });

    test('throws AudioMetadataException on native error', () {
      final reader = NativeAudioMetadataReader(
        platform: NativeAudioMetadataPlatform.windows,
        windowsReadFn: (_) => const AudioMetadataNativeResult(
          resultCode: -12,
          durationMicros: -1,
          error: 'native failure',
        ),
        windowsAvailabilityFn: () => true,
      );

      expect(
        () => reader.readAudioMetadata(inputPath: 'broken.m4a'),
        throwsA(isA<AudioMetadataException>()),
      );
    });

    test('throws UnsupportedError on unsupported platform', () async {
      final reader = NativeAudioMetadataReader(platform: NativeAudioMetadataPlatform.unsupported);

      expect(await reader.isAvailable(), isFalse);
      expect(
        () => reader.readAudioMetadata(inputPath: 'clip.m4a'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('throws ArgumentError for empty path', () {
      final reader = NativeAudioMetadataReader(
        platform: NativeAudioMetadataPlatform.macOS,
        macosReadFn: (_) => const AudioMetadataNativeResult(resultCode: 0, durationMicros: 10),
        macosAvailabilityFn: () => true,
      );

      expect(() => reader.readAudioMetadata(inputPath: '  '), throwsA(isA<ArgumentError>()));
    });
  });
}
