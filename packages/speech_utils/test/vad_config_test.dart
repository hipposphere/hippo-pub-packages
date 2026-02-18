import 'package:speech_utils/speech_utils.dart';
import 'package:test/test.dart';

void main() {
  const mono16kOptions = PauseSplitOptions(
    sampleRateHz: 16000,
    channelCount: 1,
    frameDuration: Duration(milliseconds: 16),
  );

  test('energy-only config resolves energy backend', () {
    final resolved = SpeechUtils.resolveVadBackend(
      options: mono16kOptions,
      config: const SpeechVadConfig.energyOnly(),
    );
    addTearDown(resolved.backend.dispose);

    expect(resolved.kind, ResolvedVadKind.energy);
    expect(resolved.label, 'Energy VAD');
    expect(resolved.fallbackFromTen, isFalse);
  });

  test('prefer-ten falls back to energy for incompatible sample rate', () {
    final resolved = SpeechUtils.resolveVadBackend(
      options: const PauseSplitOptions(sampleRateHz: 8000, channelCount: 1),
      config: const SpeechVadConfig.preferTen(),
    );
    addTearDown(resolved.backend.dispose);

    expect(resolved.kind, ResolvedVadKind.energy);
    expect(resolved.label, 'Energy VAD (TEN unavailable)');
    expect(resolved.fallbackFromTen, isTrue);
  });

  test('ten-only throws when options are incompatible with TEN', () {
    expect(
      () => SpeechUtils.resolveVadBackend(
        options: const PauseSplitOptions(sampleRateHz: 8000, channelCount: 1),
        config: const SpeechVadConfig.tenOnly(),
      ),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('invalid TEN threshold throws argument error', () {
    expect(
      () => SpeechUtils.resolveVadBackend(
        options: mono16kOptions,
        config: const SpeechVadConfig.preferTen(ten: TenVadConfig(threshold: 1.5)),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
