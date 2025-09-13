/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';
import 'package:hippo_components/src/charts/studyplan/model.dart';
import 'dart:math' as math;

class StudyPlanPainter extends CustomPainter {
  List<StudyDay> data;
  double scale;
  Offset offset;
  int? hoveredDayIndex;
  int? hoveredSegmentIndex;
  double barWidth;
  double spaceBetweenBars;
  double widgetHeight;

  StudyPlanPainter({
    required this.data,
    required this.scale,
    required this.offset,
    required this.barWidth,
    required this.spaceBetweenBars,
    required this.widgetHeight,
    this.hoveredDayIndex,
    this.hoveredSegmentIndex,
  });

  void update({
    List<StudyDay>? data,
    double? scale,
    Offset? offset,
    double? barWidth,
    double? spaceBetweenBars,
    double? widgetHeight,
    int? hoveredDayIndex,
    int? hoveredSegmentIndex,
  }) {
    this.data = data ?? this.data;
    this.scale = scale ?? this.scale;
    this.offset = offset ?? this.offset;
    this.barWidth = barWidth ?? this.barWidth;
    this.spaceBetweenBars = spaceBetweenBars ?? this.spaceBetweenBars;
    this.widgetHeight = widgetHeight ?? this.widgetHeight;
    this.hoveredDayIndex = hoveredDayIndex;
    this.hoveredSegmentIndex = hoveredSegmentIndex;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final textPainter = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    const double labelSpacing = 2;
    final double labelHeight = 18;
    final double availableSpace = widgetHeight - labelHeight - labelSpacing;
    final double maxBarH = availableSpace * 0.95;
    final double labelTop = maxBarH + labelSpacing;

    double maxTotalHeight = 0;
    for (final day in data) {
      double dayTotalHeight = 0;
      for (final el in day.elements) {
        dayTotalHeight += el.height;
      }
      maxTotalHeight = math.max(maxTotalHeight, dayTotalHeight);
    }

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final double scaledBarWidth = barWidth * scale;
    final double scaledSpacing = spaceBetweenBars * scale;

    for (int i = 0; i < data.length; i++) {
      final day = data[i];
      final double x = i * (scaledBarWidth + scaledSpacing);
      double currentY = 0;

      for (int j = 0; j < day.elements.length; j++) {
        final el = day.elements[j];

        final double segmentH = (el.height / maxTotalHeight * maxBarH).clamp(0, maxBarH);

        paint.color = (i == hoveredDayIndex && j == hoveredSegmentIndex)
            ? el.color.withValues(alpha: 0.5)
            : el.color;

        // Draw the filled rectangle
        canvas.drawRect(
          Rect.fromLTWH(x, maxBarH - currentY - segmentH, scaledBarWidth, segmentH),
          paint,
        );

        // Draw the border
        paint.color = Colors.black.withValues(alpha: 0.2);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 0.5;
        canvas.drawRect(
          Rect.fromLTWH(x, maxBarH - currentY - segmentH, scaledBarWidth, segmentH),
          paint,
        );
        paint.style = PaintingStyle.fill;

        currentY += segmentH;
      }

      final path = Path()
        ..moveTo(x, labelTop)
        ..lineTo(x + scaledBarWidth, labelTop)
        ..lineTo(x + scaledBarWidth + 4, labelTop + labelHeight)
        ..lineTo(x + 4, labelTop + labelHeight)
        ..close();

      paint.color = (i == hoveredDayIndex && hoveredSegmentIndex == -1)
          ? (day.labelColor ?? Colors.grey).withValues(alpha: 0.6)
          : (day.labelColor ?? Colors.grey);

      canvas.drawPath(path, paint);

      // draw the rotated index label
      textPainter.text = TextSpan(
        text: day.indexLabel ?? day.day.toString(),
        style: TextStyle(
          fontSize: barWidth * 0.35,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout(minWidth: 0, maxWidth: scaledBarWidth);

      final textX = x + scaledBarWidth / 2 + 1.8;
      final textY = labelTop + labelHeight / 2;

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(-0.12);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StudyPlanPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.hoveredDayIndex != hoveredDayIndex ||
        oldDelegate.hoveredSegmentIndex != hoveredSegmentIndex ||
        oldDelegate.widgetHeight != widgetHeight;
  }
}
