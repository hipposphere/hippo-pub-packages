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
          return const AudioMetadata(
            duration: Duration(microseconds: 1234567),
            sampleRateHz: 48000,
            channelCount: 2,
            bitrateBps: 192000,
            containerFormat: 'wav',
            codec: 'pcm',
            codecProfile: 'PCM16',
          );
        },
      );

      final metadata = await reader.readAudioMetadata(inputPath: 'input.wav');
      expect(metadata.duration, const Duration(microseconds: 1234567));
      expect(metadata.sampleRateHz, 48000);
      expect(metadata.channelCount, 2);
      expect(metadata.bitrateBps, 192000);
      expect(metadata.containerFormat, 'wav');
      expect(metadata.codec, 'pcm');
      expect(metadata.codecProfile, 'PCM16');
      expect(await reader.isAvailable(), isTrue);
    });

    test('readAudioDuration returns metadata duration', () async {
      final reader = NativeAudioMetadataReader(
        platform: NativeAudioMetadataPlatform.android,
        androidReadFn: (_) => const AudioMetadata(duration: Duration(microseconds: 42000)),
        androidAvailabilityFn: () => true,
      );

      final duration = await reader.readAudioDuration(inputPath: 'clip.m4a');
      expect(duration, const Duration(microseconds: 42000));
    });

    test('maps non-positive optional fields to null', () async {
      final reader = NativeAudioMetadataReader(
        platform: NativeAudioMetadataPlatform.iOS,
        iosReadFn: (_) => const AudioMetadata(
          duration: Duration(microseconds: 1000),
          bitrateBps: -1,
          containerFormat: '  ',
          codec: '',
        ),
        iosAvailabilityFn: () => true,
      );

      final metadata = await reader.readAudioMetadata(inputPath: 'clip.m4a');
      expect(metadata.sampleRateHz, isNull);
      expect(metadata.channelCount, isNull);
      expect(metadata.bitrateBps, isNull);
      expect(metadata.containerFormat, isNull);
      expect(metadata.codec, isNull);
      expect(metadata.codecProfile, isNull);
    });

    test('throws AudioMetadataException on native error', () {
      final reader = NativeAudioMetadataReader(
        platform: NativeAudioMetadataPlatform.windows,
        windowsReadFn: (_) => throw AudioMetadataException(
          'Native audio metadata read failed',
          errorCode: -12,
          details: 'native failure',
        ),
        windowsAvailabilityFn: () => true,
      );

      expect(
        () => reader.readAudioMetadata(inputPath: 'broken.m4a'),
        throwsA(isA<AudioMetadataException>()),
      );
    });

    test('throws NativeAudioMetadataUnsupportedPlatformException on unsupported platform', () async {
      final reader = NativeAudioMetadataReader(platform: NativeAudioMetadataPlatform.unsupported);

      expect(await reader.isAvailable(), isFalse);
      expect(
        () => reader.readAudioMetadata(inputPath: 'clip.m4a'),
        throwsA(isA<NativeAudioMetadataUnsupportedPlatformException>()),
      );
    });

    test('throws ArgumentError for empty path', () {
      final reader = NativeAudioMetadataReader(
        platform: NativeAudioMetadataPlatform.macOS,
        macosReadFn: (_) => const AudioMetadata(duration: Duration(microseconds: 10)),
        macosAvailabilityFn: () => true,
      );

      expect(() => reader.readAudioMetadata(inputPath: '  '), throwsA(isA<ArgumentError>()));
    });
  });
}
