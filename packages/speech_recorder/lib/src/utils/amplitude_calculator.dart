import 'dart:math' as math;

/// AmplitudeCalculator converts dBFS audio levels to relative amplitude values (0-1)
/// for creating visualizations similar to WhatsApp voice message amplitude displays.
class AmplitudeCalculator {
  /// Minimum dBFS value to consider (values below this will be treated as silent)
  final double minDbfs;

  /// Internal history of amplitude values for smoothing
  final List<double> _amplitudeHistory = [];

  /// Maximum number of historical values to keep for smoothing
  final int maxHistorySize;

  /// Constructor with configurable minimum dBFS threshold and history size
  AmplitudeCalculator({this.minDbfs = -60.0, this.maxHistorySize = 200});

  /// Get the current amplitude history
  List<double> get amplitudeHistory => List.unmodifiable(_amplitudeHistory);

  /// Converts a single dBFS value to a relative amplitude between 0 and 1
  ///
  /// [dbfs] The input dBFS value (typically negative, where 0 is maximum)
  /// Returns a value between 0 (silent) and 1 (maximum amplitude)
  double calculateRelativeAmplitude(double dbfs) {
    // Ensure dBFS value doesn't exceed 0 (maximum possible digital level)
    if (dbfs > 0) {
      dbfs = 0;
    }

    // Return 0 for values below the minimum threshold
    if (dbfs <= minDbfs) {
      return 0;
    }

    // Map the dBFS value from [minDbfs, 0] to [0, 1]
    return (dbfs - minDbfs) / (0 - minDbfs);
  }

  /// Adds a new dBFS value to the history and returns the smoothed amplitude value
  ///
  /// [dbfs] The new dBFS value to add
  /// [applySmoothing] Whether to apply smoothing to the value
  /// [returnNormalizedHistory] Whether to return the full normalized history
  dynamic addValue(
    double dbfs, {
    bool applySmoothing = true,
    bool returnNormalizedHistory = false,
  }) {
    // Convert to relative amplitude
    final amplitude = calculateRelativeAmplitude(dbfs);

    // Add to history
    _amplitudeHistory.add(amplitude);

    // Trim history if needed
    if (_amplitudeHistory.length > maxHistorySize) {
      _amplitudeHistory.removeAt(0);
    }

    // Apply smoothing if requested and enough data exists
    double smoothedValue = amplitude;
    if (applySmoothing && _amplitudeHistory.length >= 3) {
      final lastIndex = _amplitudeHistory.length - 1;
      // Apply less smoothing by giving more weight to the current value (0.6)
      // and less weight to previous values (0.3 and 0.1)
      smoothedValue =
          (_amplitudeHistory[lastIndex] * 0.6) +
          (_amplitudeHistory[lastIndex - 1] * 0.3) +
          (_amplitudeHistory[lastIndex - 2] * 0.1);

      // Replace the last value with the smoothed one
      _amplitudeHistory[lastIndex] = smoothedValue;
    }

    // Return full history or just the latest value
    if (returnNormalizedHistory) {
      return _normalizeValues(List.from(_amplitudeHistory));
    }

    return smoothedValue;
  }

  /// Clears the amplitude history
  void clearHistory() {
    _amplitudeHistory.clear();
  }

  /// Processes a list of dBFS values and returns normalized relative amplitudes
  ///
  /// [dbfsValues] List of dBFS values to process
  /// [applySmoothing] Whether to apply smoothing to the values
  /// [normalizeValues] Whether to normalize values to use the full 0-1 range
  List<double> processAmplitudes(
    List<double> dbfsValues, {
    bool applySmoothing = true,
    bool normalizeValues = true,
  }) {
    if (dbfsValues.isEmpty) return [];

    // Convert all values to relative scale
    List<double> relativeAmplitudes = dbfsValues
        .map((dbfs) => calculateRelativeAmplitude(dbfs))
        .toList();

    // Apply smoothing if requested
    if (applySmoothing && relativeAmplitudes.length > 2) {
      relativeAmplitudes = _smoothValues(relativeAmplitudes);
    }

    // Normalize to ensure we use the full range if requested
    if (normalizeValues && relativeAmplitudes.isNotEmpty) {
      relativeAmplitudes = _normalizeValues(relativeAmplitudes);
    }

    return relativeAmplitudes;
  }

  /// Applies a simple moving average smoothing to the values
  List<double> _smoothValues(List<double> values) {
    List<double> smoothed = List.from(values);

    // Simple moving average with weighted values (less smoothing)
    for (int i = 1; i < values.length - 1; i++) {
      smoothed[i] =
          (values[i] * 0.6) + (values[i - 1] * 0.2) + (values[i + 1] * 0.2);
    }

    return smoothed;
  }

  /// Normalizes values to ensure the maximum value is 1
  List<double> _normalizeValues(List<double> values) {
    double maxValue = values.reduce(math.max);

    // Avoid division by zero if all values are 0
    if (maxValue <= 0) return values;

    // Scale all values proportionally
    return values.map((value) => value / maxValue).toList();
  }
}
