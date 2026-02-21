import 'dart:math' as math;

class SpeechAmplitudeUtils {
  SpeechAmplitudeUtils._();

  /// Lower values produce a more aggressive mapping from low dBFS levels to
  /// visible waveform height.
  static const double defaultSensitivity = 1.35;
  static const double _defaultMinDbfs = -90.0;
  static const double _defaultMaxDbfs = 0.0;
  static const double _defaultDbfsFloor = -90.0;

  /// Converts an RMS amplitude to dBFS.
  static double rmsToDbfs(double rms, {double? silenceDbfs = _defaultDbfsFloor}) {
    if (!rms.isFinite || rms <= 0.0) {
      return silenceDbfs ?? _defaultDbfsFloor;
    }
    final dbfs = 20.0 * math.log(rms) / math.ln10;
    if (!dbfs.isFinite) {
      return silenceDbfs ?? _defaultDbfsFloor;
    }
    return dbfs.clamp(_defaultMinDbfs, _defaultMaxDbfs);
  }

  /// Converts a dBFS value into a normalized waveform value in [0, 1].
  ///
  /// This uses a logarithmic signal scale and a configurable sensitivity
  /// multiplier so low-level signals are more visible.
  static double normalizeDbfsForWaveform(
    double dbfs, {
    double minimumDbfs = _defaultMinDbfs,
    double maximumDbfs = _defaultMaxDbfs,
    double sensitivity = defaultSensitivity,
  }) {
    if (!dbfs.isFinite || maximumDbfs <= minimumDbfs) {
      return 0.0;
    }
    final clampedDbfs = dbfs.clamp(minimumDbfs, maximumDbfs);
    if (clampedDbfs <= minimumDbfs) {
      return 0.0;
    }
    if (clampedDbfs >= maximumDbfs) {
      return 1.0;
    }

    final effectiveSensitivity = sensitivity <= 0 ? 1.0 : sensitivity;
    final raw = math.pow(10.0, clampedDbfs / 20.0);
    final normalized = math.pow(raw, 1.0 / effectiveSensitivity).toDouble();
    return normalized.clamp(0.0, 1.0);
  }
}
