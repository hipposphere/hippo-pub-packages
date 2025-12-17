import 'package:flutter/material.dart';
import 'package:hippo_utils/hippo_utils.dart';
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

          final valuesList = subList.map((e) {
            double value = e.current;
            if (value < 0) {
              value = (value + 50) / 50;
            }
            value = value.clamp(0.0, 1.0);
            if (value < 0.1) value = 0.1;
            return value;
          }).toList();

          return CustomPaint(
            painter: AmplitudeHistoryPainter(
              values: valuesList,
              length: amplitudesLength,
              color: cellColor,
              inactiveColor: inactiveColor,
              cellWidth: cellWidth,
              cellRadius: cellRadius,
              gap: gap,
            ),
            size: Size.infinite,
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

  AmplitudeHistoryPainter({
    required this.length,
    required this.values,
    required this.color,
    required this.inactiveColor,
    required this.cellWidth,
    required this.cellRadius,
    required this.gap,
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
        normalized = 0.1; // Inactive cells have min height
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
        oldDelegate.gap != gap;
  }
}
