import 'dart:math' as math;

import 'package:flutter/material.dart';

class LiveWaveformPanel extends StatelessWidget {
  const LiveWaveformPanel({
    super.key,
    required this.samples,
    required this.isActive,
    required this.speechDetected,
    this.sampleSpeechFlags,
    this.height = 120,
  });

  final List<double> samples;
  final bool isActive;
  final bool? speechDetected;
  final List<bool?>? sampleSpeechFlags;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final defaultWaveformColor = colorScheme.primary;
    final nonSpeechWaveformColor = const Color(0xFFD3D3D3);
    final fallbackWaveformColor = speechDetected == false
        ? const Color(0xFFD3D3D3)
        : defaultWaveformColor;

    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surfaceContainerHigh.withValues(alpha: 0.95),
                colorScheme.surfaceContainerLow.withValues(alpha: 0.75),
              ],
            ),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(
                alpha: isActive ? 0.9 : 0.65,
              ),
            ),
          ),
          child: CustomPaint(
            painter: _LiveWaveformPainter(
              samples: samples,
              sampleSpeechFlags: sampleSpeechFlags,
              fallbackWaveformColor: fallbackWaveformColor,
              defaultWaveformColor: defaultWaveformColor,
              nonSpeechWaveformColor: nonSpeechWaveformColor,
              baselineColor: colorScheme.outlineVariant,
              gridColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
              isActive: isActive,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _LiveWaveformPainter extends CustomPainter {
  const _LiveWaveformPainter({
    required this.samples,
    required this.sampleSpeechFlags,
    required this.fallbackWaveformColor,
    required this.defaultWaveformColor,
    required this.nonSpeechWaveformColor,
    required this.baselineColor,
    required this.gridColor,
    required this.isActive,
  });

  final List<double> samples;
  final List<bool?>? sampleSpeechFlags;
  final Color fallbackWaveformColor;
  final Color defaultWaveformColor;
  final Color nonSpeechWaveformColor;
  final Color baselineColor;
  final Color gridColor;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    const gridDivisions = 6;
    for (var i = 1; i < gridDivisions; i++) {
      final x = size.width * i / gridDivisions;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final baselinePaint = Paint()
      ..color = baselineColor.withValues(alpha: isActive ? 0.9 : 0.7)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      baselinePaint,
    );

    final normalizedBars = _normalizeSamples(samples, size);
    if (normalizedBars.isEmpty) {
      return;
    }

    final barWidth = size.width / normalizedBars.length;
    final bodyWidth = (barWidth * 0.72).clamp(1.8, 4.5);
    final maxHalfHeight = size.height * 0.46;
    final barSpeechStates = _buildBarSpeechStates(
      sampleSpeechFlags: sampleSpeechFlags,
      sampleCount: samples.length,
      barCount: normalizedBars.length,
    );

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < normalizedBars.length; i++) {
      final value = normalizedBars[i];
      final barColor = _resolveBarColor(
        hasPerSampleSpeechStates: barSpeechStates != null,
        fallbackWaveformColor: fallbackWaveformColor,
        defaultWaveformColor: defaultWaveformColor,
        nonSpeechWaveformColor: nonSpeechWaveformColor,
        barSpeechState: barSpeechStates?[i],
      );
      fillPaint.color = barColor.withValues(alpha: isActive ? 0.88 : 0.62);
      glowPaint.color = barColor.withValues(alpha: isActive ? 0.35 : 0.2);
      final halfHeight = math.max(1.0, value * maxHalfHeight);
      final centerX = (i + 0.5) * barWidth;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: bodyWidth.toDouble(),
          height: halfHeight * 2,
        ),
        Radius.circular(bodyWidth.toDouble()),
      );
      canvas.drawRRect(rect, fillPaint);
      canvas.drawRRect(rect, glowPaint);
    }
  }

  List<double> _normalizeSamples(List<double> input, Size size) {
    final bars = (size.width / 3).floor().clamp(40, 180);
    if (bars <= 0) {
      return const <double>[];
    }

    final output = List<double>.filled(bars, 0);
    if (input.isEmpty) {
      return output;
    }

    var smoothed = 0.0;
    for (var barIndex = 0; barIndex < bars; barIndex++) {
      final start = (barIndex * input.length / bars).floor();
      final end = ((barIndex + 1) * input.length / bars).ceil().clamp(
        start + 1,
        input.length,
      );

      var peak = 0.0;
      for (var sampleIndex = start; sampleIndex < end; sampleIndex++) {
        peak = math.max(peak, input[sampleIndex].clamp(0.0, 1.0));
      }

      final perceptual = math.pow(peak, 0.58).toDouble().clamp(0.0, 1.0);
      final floor = isActive ? 0.012 : 0.0;
      final adjusted = math.max(floor, perceptual);

      smoothed = barIndex == 0
          ? adjusted
          : (smoothed * 0.68) + (adjusted * 0.32);
      output[barIndex] = smoothed;
    }
    return output;
  }

  List<bool?>? _buildBarSpeechStates({
    required List<bool?>? sampleSpeechFlags,
    required int sampleCount,
    required int barCount,
  }) {
    if (sampleSpeechFlags == null ||
        sampleSpeechFlags.isEmpty ||
        sampleCount <= 0 ||
        barCount <= 0) {
      return null;
    }

    final output = List<bool?>.filled(barCount, null);
    for (var barIndex = 0; barIndex < barCount; barIndex++) {
      final start = (barIndex * sampleCount / barCount).floor();
      final end = ((barIndex + 1) * sampleCount / barCount).ceil().clamp(
        start + 1,
        sampleCount,
      );

      var speechCount = 0;
      var nonSpeechCount = 0;
      for (var sampleIndex = start; sampleIndex < end; sampleIndex++) {
        if (sampleIndex >= sampleSpeechFlags.length) {
          break;
        }
        final state = sampleSpeechFlags[sampleIndex];
        if (state == true) {
          speechCount++;
        } else if (state == false) {
          nonSpeechCount++;
        }
      }

      if (speechCount == 0 && nonSpeechCount == 0) {
        output[barIndex] = null;
      } else {
        output[barIndex] = speechCount >= nonSpeechCount;
      }
    }
    return output;
  }

  Color _resolveBarColor({
    required bool hasPerSampleSpeechStates,
    required Color fallbackWaveformColor,
    required Color defaultWaveformColor,
    required Color nonSpeechWaveformColor,
    required bool? barSpeechState,
  }) {
    if (!hasPerSampleSpeechStates) {
      return fallbackWaveformColor;
    }
    if (barSpeechState == false) {
      return nonSpeechWaveformColor;
    }
    return defaultWaveformColor;
  }

  @override
  bool shouldRepaint(covariant _LiveWaveformPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.sampleSpeechFlags != sampleSpeechFlags ||
        oldDelegate.fallbackWaveformColor != fallbackWaveformColor ||
        oldDelegate.defaultWaveformColor != defaultWaveformColor ||
        oldDelegate.nonSpeechWaveformColor != nonSpeechWaveformColor ||
        oldDelegate.baselineColor != baselineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.isActive != isActive;
  }
}
