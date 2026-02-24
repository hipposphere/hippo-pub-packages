import '../models/pause_split_options.dart';
import 'energy_vad_backend.dart';
import 'ten_vad_ffi_backend.dart';
import 'vad_backend.dart';

/// Backend selection strategy for speech VAD.
enum SpeechVadMode {
  /// Try TEN VAD first and fall back to Energy VAD when unavailable.
  preferTen,

  /// Require TEN VAD and throw when unavailable.
  tenOnly,

  /// Always use Energy VAD.
  energyOnly,
}

/// TEN VAD runtime options.
final class TenVadConfig {
  const TenVadConfig({this.threshold = 0.45});

  final double threshold;

  void validate() {
    if (threshold < 0 || threshold > 1) {
      throw ArgumentError.value(threshold, 'threshold', 'Must be in [0, 1]');
    }
  }
}

/// Energy VAD runtime options.
final class EnergyVadConfig {
  const EnergyVadConfig({
    this.primaryRmsThreshold = 0.015,
    this.secondaryRmsThreshold = 0.010,
    this.minZeroCrossingRate = 0.08,
  });

  final double primaryRmsThreshold;
  final double secondaryRmsThreshold;
  final double minZeroCrossingRate;

  void validate() {
    if (primaryRmsThreshold < 0) {
      throw ArgumentError.value(primaryRmsThreshold, 'primaryRmsThreshold', 'Must be >= 0');
    }
    if (secondaryRmsThreshold < 0) {
      throw ArgumentError.value(secondaryRmsThreshold, 'secondaryRmsThreshold', 'Must be >= 0');
    }
    if (minZeroCrossingRate < 0 || minZeroCrossingRate > 1) {
      throw ArgumentError.value(minZeroCrossingRate, 'minZeroCrossingRate', 'Must be in [0, 1]');
    }
  }
}

/// Unified VAD configuration for [SpeechUtils] APIs.
final class SpeechVadConfig {
  const SpeechVadConfig({
    this.mode = SpeechVadMode.preferTen,
    this.ten = const TenVadConfig(),
    this.energy = const EnergyVadConfig(),
  });

  const SpeechVadConfig.preferTen({
    this.ten = const TenVadConfig(),
    this.energy = const EnergyVadConfig(),
  }) : mode = SpeechVadMode.preferTen;

  const SpeechVadConfig.tenOnly({
    this.ten = const TenVadConfig(),
    this.energy = const EnergyVadConfig(),
  }) : mode = SpeechVadMode.tenOnly;

  const SpeechVadConfig.energyOnly({
    this.ten = const TenVadConfig(),
    this.energy = const EnergyVadConfig(),
  }) : mode = SpeechVadMode.energyOnly;

  final SpeechVadMode mode;
  final TenVadConfig ten;
  final EnergyVadConfig energy;
}

/// Resolved backend kind.
enum ResolvedVadKind { ten, energy }

/// Resolved VAD backend plus metadata describing the selection outcome.
final class ResolvedVadBackend {
  const ResolvedVadBackend({
    required this.backend,
    required this.kind,
    required this.label,
    this.fallbackFromTen = false,
  });

  final VadBackend backend;
  final ResolvedVadKind kind;
  final String label;
  final bool fallbackFromTen;

  bool get isTen => kind == ResolvedVadKind.ten;
}

/// Resolves the effective VAD backend based on [options] and [config].
ResolvedVadBackend resolveSpeechVadBackend({
  required PauseSplitOptions options,
  SpeechVadConfig config = const SpeechVadConfig(),
}) {
  options.validate();
  config.ten.validate();
  config.energy.validate();

  if (config.mode != SpeechVadMode.energyOnly) {
    final tenUnavailableReason = _tenUnavailableReason(options);
    if (tenUnavailableReason == null) {
      final tenBackend = TenVadFfiBackend.tryCreate(
        hopSize: options.frameSampleCountPerChannel,
        threshold: config.ten.threshold,
      );
      if (tenBackend != null) {
        final version = TenVadFfiBackend.versionOrNull() ?? 'unknown';
        return ResolvedVadBackend(
          backend: tenBackend,
          kind: ResolvedVadKind.ten,
          label: 'TEN VAD ($version)',
        );
      }
    } else if (config.mode == SpeechVadMode.tenOnly) {
      throw UnsupportedError(tenUnavailableReason);
    }

    if (config.mode == SpeechVadMode.tenOnly) {
      throw UnsupportedError(
        'TEN VAD requested but could not be initialized. '
        'Ensure native TEN assets are bundled for this target.',
      );
    }
  }

  final energyBackend = EnergyVadBackend(
    primaryRmsThreshold: config.energy.primaryRmsThreshold,
    secondaryRmsThreshold: config.energy.secondaryRmsThreshold,
    minZeroCrossingRate: config.energy.minZeroCrossingRate,
  );
  final fallbackFromTen = config.mode == SpeechVadMode.preferTen;
  return ResolvedVadBackend(
    backend: energyBackend,
    kind: ResolvedVadKind.energy,
    label: fallbackFromTen ? 'Energy VAD (TEN unavailable)' : 'Energy VAD',
    fallbackFromTen: fallbackFromTen,
  );
}

String? _tenUnavailableReason(PauseSplitOptions options) {
  if (options.sampleRateHz != 16000) {
    return 'TEN VAD requires sampleRateHz=16000. '
        'Received ${options.sampleRateHz}.';
  }
  if (options.channelCount != 1) {
    return 'TEN VAD requires mono PCM (channelCount=1). '
        'Received ${options.channelCount}.';
  }
  if (!TenVadFfiBackend.supportsCurrentPlatform) {
    return 'TEN VAD is not bundled for this runtime platform.';
  }
  return null;
}
