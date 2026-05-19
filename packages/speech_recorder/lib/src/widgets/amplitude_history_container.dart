import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:speech_recorder/speech_recorder.dart';

class SpeechRecorderAmplitudeHistoryContainer extends StatelessWidget {
  final SpeechRecorderSession session;
  final int amplitudesLength;
  final double height;
  final double cellWidth;
  final double cellRadius;
  final Color cellColor;
  final Color inactiveColor;
  final double gap;
  final double minLevel;
  final double sensitivity;
  final Duration animationDuration;
  final Curve animationCurve;

  static const double defaultSensitivity = 3.0;

  const SpeechRecorderAmplitudeHistoryContainer({
    super.key,
    required this.session,
    this.amplitudesLength = 300,
    this.height = 20,
    this.cellWidth = 4,
    this.cellRadius = 4,
    this.cellColor = Colors.blue,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.gap = 2,
    this.minLevel = 0.1,
    this.sensitivity = defaultSensitivity,
    this.animationDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DataSubjectBuilder(
        subject: session.amplitudeSubject,
        builder: (context, amplitudeList) {
          final subList = amplitudeList
              .skip(
                amplitudeList.length >= amplitudesLength
                    ? amplitudeList.length - amplitudesLength
                    : 0,
              )
              .toList();

          final normalizedValues = subList
              .map(
                (amplitude) => SpeechAmplitudeUtils.normalizeDbfsForWaveform(
                  amplitude.current,
                  sensitivity: sensitivity,
                ).clamp(minLevel, 1.0),
              )
              .toList(growable: false);

          return _AnimatedAmplitudeHistory(
            values: normalizedValues,
            minLevel: minLevel,
            animationDuration: animationDuration,
            animationCurve: animationCurve,
            painterBuilder: (animatedValues) => AmplitudeHistoryPainter(
              values: animatedValues,
              length: amplitudesLength,
              color: cellColor,
              inactiveColor: inactiveColor,
              cellWidth: cellWidth,
              cellRadius: cellRadius,
              gap: gap,
              minValue: minLevel,
            ),
          );
        },
      ),
    );
  }
}

class AmplitudeHistoryPainter extends CustomPainter {
  // The maximum number of amplitude values to display
  final int length;
  // Values are normalized between 0 and 1
  final List<double> values;
  final Color color;
  final Color inactiveColor;
  final double cellWidth;
  final double cellRadius;
  final double gap;
  final double minValue;

  AmplitudeHistoryPainter({
    required this.length,
    required this.values,
    required this.color,
    required this.inactiveColor,
    required this.cellWidth,
    required this.cellRadius,
    required this.gap,
    required this.minValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.fill;

    // Start drawing from the right
    double x = size.width;

    // Iterate for the total length
    for (int i = 0; i < length; i++) {
      if (x + cellWidth < 0) break; // Stop if we go off screen

      // Index in the values list (from end)
      final valueIndex = values.length - 1 - i;

      double normalized;
      Paint currentPaint;

      if (valueIndex >= 0) {
        normalized = values[valueIndex];
        currentPaint = activePaint;
      } else {
        normalized = minValue;
        currentPaint = inactivePaint;
      }

      final barHeight = size.height * normalized;
      final top = (size.height - barHeight) / 2; // Center vertically

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - cellWidth, top, cellWidth, barHeight),
        Radius.circular(cellRadius),
      );

      canvas.drawRRect(rect, currentPaint);

      x -= (cellWidth + gap);
    }
  }

  @override
  bool shouldRepaint(covariant AmplitudeHistoryPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.length != length ||
        oldDelegate.color != color ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.cellWidth != cellWidth ||
        oldDelegate.cellRadius != cellRadius ||
        oldDelegate.gap != gap ||
        oldDelegate.minValue != minValue;
  }
}

typedef _PainterBuilder = AmplitudeHistoryPainter Function(List<double> values);

class _AnimatedAmplitudeHistory extends StatefulWidget {
  final List<double> values;
  final double minLevel;
  final Duration animationDuration;
  final Curve animationCurve;
  final _PainterBuilder painterBuilder;

  const _AnimatedAmplitudeHistory({
    required this.values,
    required this.minLevel,
    required this.animationDuration,
    required this.animationCurve,
    required this.painterBuilder,
  });

  @override
  State<_AnimatedAmplitudeHistory> createState() =>
      _AnimatedAmplitudeHistoryState();
}

class _AnimatedAmplitudeHistoryState extends State<_AnimatedAmplitudeHistory>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<double> _startValues;
  late List<double> _targetValues;

  @override
  void initState() {
    super.initState();
    _startValues = List<double>.of(widget.values);
    _targetValues = List<double>.of(widget.values);
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedAmplitudeHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.duration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }

    if (_doubleListEquals(widget.values, _targetValues)) {
      return;
    }

    _startValues = _interpolatedValues();
    _targetValues = List<double>.of(widget.values);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final animatedValues = _interpolatedValues();
        return CustomPaint(
          painter: widget.painterBuilder(animatedValues),
          size: Size.infinite,
        );
      },
    );
  }

  List<double> _interpolatedValues() {
    final t = widget.animationCurve.transform(_controller.value);
    final maxLength = math.max(_startValues.length, _targetValues.length);
    if (maxLength == 0) {
      return const [];
    }

    return List.generate(maxLength, (index) {
      final hasFrom = index < _startValues.length;
      final hasTo = index < _targetValues.length;

      if (!hasTo) {
        return widget.minLevel;
      }

      // New samples should not animate up from the inactive baseline
      // to avoid a flashing effect at the right edge.
      if (!hasFrom) {
        return _targetValues[index].clamp(widget.minLevel, 1.0);
      }

      final from = _startValues[index];
      final to = _targetValues[index];
      return lerpDouble(from, to, t)!.clamp(widget.minLevel, 1.0);
    }, growable: false);
  }

  bool _doubleListEquals(List<double> first, List<double> second) {
    if (identical(first, second)) {
      return true;
    }
    if (first.length != second.length) {
      return false;
    }
    for (var i = 0; i < first.length; i++) {
      if (first[i] != second[i]) {
        return false;
      }
    }
    return true;
  }
}
