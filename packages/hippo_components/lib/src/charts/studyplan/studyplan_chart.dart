import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_components/src/charts/studyplan/model.dart';
import 'dart:math' as math;
import 'package:hippo_components/src/charts/studyplan/studyplan_painter.dart';

class StudyPlanChart extends StatefulWidget {
  final List<StudyDay> data;
  final double height;
  final double barWidth;
  final double spaceBetweenBars;

  const StudyPlanChart({
    super.key,
    required this.data,
    this.height = 100,
    this.barWidth = 18,
    this.spaceBetweenBars = 4,
  });

  @override
  State<StudyPlanChart> createState() => _StudyPlanChartState();
}

class _StudyPlanChartState extends State<StudyPlanChart> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Widget? _tooltip;
  Offset? _tooltipPosition;
  int? _hoveredDayIndex;
  int? _hoveredSegmentIndex;

  final GlobalKey _tooltipKey = GlobalKey();

  double _calculateMinScale() {
    final totalContentWidth = (widget.barWidth + widget.spaceBetweenBars) * widget.data.length;
    final visibleWidth = context.size?.width ?? 0;
    if (visibleWidth == 0) return 0.5;
    return (visibleWidth / totalContentWidth).clamp(0.1, 1.0);
  }

  void _updateTooltip(Widget? tooltip, Offset? position, int? dayIdx, int? segIdx) {
    setState(() {
      _tooltip = tooltip;
      _tooltipPosition = position;
      _hoveredDayIndex = dayIdx;
      _hoveredSegmentIndex = segIdx;
    });
  }

  void _handleTapDown(TapDownDetails details) {
    final dp = details.localPosition;
    final chartX = dp.dx - _offset.dx;
    final chartY = dp.dy - _offset.dy;

    // Calculate the total content width
    final totalContentWidth =
        (widget.barWidth * _scale + widget.spaceBetweenBars * _scale) * widget.data.length;

    // Only process tap if within content bounds
    if (chartX >= 0 && chartX <= totalContentWidth) {
      final hit = _findTooltipWithIndices(Offset(chartX, chartY));
      _updateTooltip(hit?.item1, dp, hit?.item3, hit?.item4);
    } else {
      _updateTooltip(null, null, null, null);
    }
  }

  void _handleTap() {
    if (_hoveredDayIndex != null) {
      final day = widget.data[_hoveredDayIndex!];
      if (_hoveredSegmentIndex != null && _hoveredSegmentIndex! >= 0) {
        day.elements[_hoveredSegmentIndex!].onTap?.call(context);
      } else if (_hoveredSegmentIndex == -1) {
        day.onTap?.call(context);
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final dp = event.localPosition;
    final chartX = dp.dx - _offset.dx;
    final chartY = dp.dy - _offset.dy;

    // Calculate the total content width
    final totalContentWidth =
        (widget.barWidth * _scale + widget.spaceBetweenBars * _scale) * widget.data.length;

    // Only process hover if within content bounds
    if (chartX >= 0 && chartX <= totalContentWidth) {
      final hit = _findTooltipWithIndices(Offset(chartX, chartY));
      _updateTooltip(hit?.item1, dp, hit?.item3, hit?.item4);
    } else {
      _updateTooltip(null, null, null, null);
    }
  }

  void _handleExit(PointerExitEvent event) {
    _updateTooltip(null, null, null, null);
  }

  TooltipHitInfo<Widget, Offset, int, int>? _findTooltipWithIndices(Offset pos) {
    final barW = widget.barWidth * _scale;
    final space = widget.spaceBetweenBars * _scale;
    const labelSp = 2.0;
    const labelH = 18.0;
    final availableH = widget.height - labelH - labelSp;
    final maxBarH = availableH * 0.95;
    final labelTop = maxBarH + labelSp;

    // Calculate the maximum total height across all days
    double maxTotalHeight = 0;
    for (final day in widget.data) {
      double dayTotalHeight = 0;
      for (final el in day.elements) {
        dayTotalHeight += el.height;
      }
      maxTotalHeight = math.max(maxTotalHeight, dayTotalHeight);
    }

    // Calculate which bar we're over based on the scaled position
    final barIndex = (pos.dx / (barW + space)).floor();
    if (barIndex >= 0 && barIndex < widget.data.length) {
      final x0 = barIndex * (barW + space);
      if (pos.dx >= x0 && pos.dx <= x0 + barW) {
        double currY = 0;
        for (int j = 0; j < widget.data[barIndex].elements.length; j++) {
          final el = widget.data[barIndex].elements[j];
          final segH = (el.height / maxTotalHeight * maxBarH).clamp(0.0, maxBarH);
          final top = maxBarH - currY - segH;
          if (pos.dy >= top && pos.dy <= top + segH) {
            return TooltipHitInfo(
              el.tooltip ?? const SizedBox(),
              Offset(x0 + barW / 2, top + segH / 2),
              barIndex,
              j,
            );
          }
          currY += segH;
        }
        if (pos.dy >= labelTop && pos.dy <= labelTop + labelH) {
          return TooltipHitInfo(
            widget.data[barIndex].tooltip ?? const SizedBox(),
            Offset(x0 + barW / 2, labelTop + labelH / 2),
            barIndex,
            -1,
          );
        }
      }
    }
    return null;
  }

  void _clampOffset() {
    // unchanged clamp logic
    final sw = widget.barWidth * _scale;
    final ss = widget.spaceBetweenBars * _scale;
    final totalW = (sw + ss) * widget.data.length;
    final vw = context.size?.width ?? 0;
    final maxX = 0.0;
    final minX = vw >= totalW ? 0.0 : vw - totalW;

    final ch = widget.height - 20;
    final vh = context.size?.height ?? 0;
    final maxY = 0.0;
    final minY = -math.max(0, ch - vh);

    setState(() {
      _offset = Offset(_offset.dx.clamp(minX, maxX), _offset.dy.clamp(minY.toDouble(), maxY));
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final focalPoint = details.focalPoint;
    final prevScale = _scale;
    final minScale = _calculateMinScale();
    final newScale = (_scale * details.scale).clamp(minScale, 3.0);
    if (details.scale == 1.0) {
      setState(() {
        _offset += details.focalPointDelta;
      });
    } else {
      final focalRel = (focalPoint - _offset) / prevScale;
      setState(() {
        _scale = newScale;
        _offset = focalPoint - focalRel * newScale;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _clampOffset());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final chartSize = Size(constraints.maxWidth, widget.height);
        return MouseRegion(
          onHover: _handleHover,
          onExit: _handleExit,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: _handleTapDown,
            onTap: _handleTap,
            onScaleUpdate: _handleScaleUpdate,
            child: SizedBox(
              height: widget.height,
              width: chartSize.width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRect(
                    child: CustomPaint(
                      painter: StudyPlanPainter(
                        data: widget.data,
                        scale: _scale,
                        offset: _offset,
                        hoveredDayIndex: _hoveredDayIndex,
                        hoveredSegmentIndex: _hoveredSegmentIndex,
                        barWidth: widget.barWidth,
                        spaceBetweenBars: widget.spaceBetweenBars,
                        widgetHeight: widget.height,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                  if (_tooltip != null && _tooltipPosition != null)
                    _SmartTooltipPosition(
                      position: _tooltipPosition!,
                      tooltip: _tooltip!,
                      chartSize: chartSize,
                      tooltipKey: _tooltipKey,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SmartTooltipPosition extends StatefulWidget {
  final Offset position;
  final Widget tooltip;
  final Size chartSize;
  final GlobalKey tooltipKey;

  const _SmartTooltipPosition({
    required this.position,
    required this.tooltip,
    required this.chartSize,
    required this.tooltipKey,
  });

  @override
  State<_SmartTooltipPosition> createState() => _SmartTooltipPositionState();
}

class _SmartTooltipPositionState extends State<_SmartTooltipPosition> {
  Offset? _finalPosition;

  @override
  void initState() {
    super.initState();
    _measureAndPosition();
  }

  void _measureAndPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          widget.tooltipKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && mounted) {
        final size = renderBox.size;
        final isBottomHalf = widget.position.dy > widget.chartSize.height / 2;

        // Calculate initial position
        double left = widget.position.dx + 8;
        if (left + size.width > widget.chartSize.width) {
          left = widget.position.dx - size.width - 8;
        }

        double top;
        if (isBottomHalf) {
          top = widget.position.dy - size.height - 8;
        } else {
          top = widget.position.dy + 8;
        }

        // Ensure tooltip stays within bounds
        left = left.clamp(0.0, widget.chartSize.width - size.width);
        top = top.clamp(0.0, widget.chartSize.height - size.height);

        setState(() {
          _finalPosition = Offset(left, top);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finalPosition == null) {
      // Show invisible tooltip at cursor position for measurement
      return Positioned(
        left: widget.position.dx,
        top: widget.position.dy,
        child: Opacity(
          opacity: 0,
          child: Material(
            color: Colors.transparent,
            child: KeyedSubtree(key: widget.tooltipKey, child: widget.tooltip),
          ),
        ),
      );
    }

    return Positioned(
      left: _finalPosition!.dx,
      top: _finalPosition!.dy,
      child: Material(color: Colors.transparent, child: widget.tooltip),
    );
  }
}

List<StudyDay> generateDummyData() {
  final random = math.Random();
  return List.generate(100, (i) {
    int numSegments = random.nextInt(6) + 1; // 1 to 6 segments
    double remainingHeight = 1.0; // Use relative heights (0.0 to 1.0)
    List<DayStudyElement> elements = List.generate(numSegments, (j) {
      double height = remainingHeight * (random.nextDouble() * 0.5);
      height = height.clamp(0.05, 0.3); // Clamp to reasonable relative heights
      remainingHeight -= height;
      return DayStudyElement(
        height: height,
        color: Colors.primaries[(i + j) % Colors.primaries.length],
        tooltip: Text(
          "Day ${i + 1} – Segment ${j + 1}",
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        label: "S${j + 1}",
      );
    });
    return StudyDay(
      day: i + 1,
      elements: elements,
      labelColor: Colors.accents[i % Colors.accents.length],
      indexLabel: "${i + 1}",
      tooltip: Text(
        "Day ${i + 1} – Total segments: $numSegments",
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  });
}
