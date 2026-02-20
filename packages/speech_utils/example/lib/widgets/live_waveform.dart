import 'dart:math' as math;

import 'package:flutter/material.dart';

class LiveWaveformPanel extends StatelessWidget {
  const LiveWaveformPanel({
    super.key,
    required this.samples,
    required this.isActive,
    required this.speechDetected,
    this.height = 120,
  });

  final List<double> samples;
  final bool isActive;
  final bool speechDetected;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final waveformColor = speechDetected
        ? colorScheme.primary
        : colorScheme.secondary;

    return SizedBox(
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
            waveformColor: waveformColor,
            baselineColor: colorScheme.outlineVariant,
            gridColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
            isActive: isActive,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _LiveWaveformPainter extends CustomPainter {
  const _LiveWaveformPainter({
    required this.samples,
    required this.waveformColor,
    required this.baselineColor,
    required this.gridColor,
    required this.isActive,
  });

  final List<double> samples;
  final Color waveformColor;
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

    final fillPaint = Paint()
      ..color = waveformColor.withValues(alpha: isActive ? 0.88 : 0.62)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = waveformColor.withValues(alpha: isActive ? 0.35 : 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < normalizedBars.length; i++) {
      final value = normalizedBars[i];
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

  @override
  bool shouldRepaint(covariant _LiveWaveformPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.waveformColor != waveformColor ||
        oldDelegate.baselineColor != baselineColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.isActive != isActive;
  }
}
