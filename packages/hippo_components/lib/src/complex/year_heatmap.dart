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
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hippo_components/src/base/utils/components_context.dart';

class YearHeatmap extends StatefulWidget {
  /// The map of day -> count.
  final Map<Date, int> values;

  /// The maximum value for any day (used for color interpolation).
  final int maxValue;

  final Date startDate;
  final Date endDate;

  /// Color used for cells that have nonzero contributions at the lowest intensity.
  final Color minColor;

  /// Color used for cells at maximum intensity.
  final Color maxColor;

  /// The size of each square cell in the heatmap.
  final double cellSize;

  /// Spacing between columns (weeks).
  final double spacingBetweenWeeks;

  /// Spacing between day rows within a column.
  final double spacingBetweenDays;

  const YearHeatmap({
    super.key,
    required this.values,
    required this.maxValue,
    required this.startDate,
    required this.endDate,
    this.minColor = const Color(0xff9be9a8), // GitHub-ish green
    this.maxColor = const Color(0xff196127), // GitHub-ish darker green
    this.cellSize = 16.0,
    this.spacingBetweenWeeks = 4.0,
    this.spacingBetweenDays = 4.0,
  });

  @override
  State<YearHeatmap> createState() => _YearHeatmapState();
}

class _YearHeatmapState extends State<YearHeatmap> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Jump or animate to the end to show latest date.
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

        // If you prefer a smooth scroll instead:
        // _scrollController.animateTo(
        //   _scrollController.position.maxScrollExtent,
        //   duration: const Duration(milliseconds: 300),
        //   curve: Curves.easeOut,
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.startDate.isBefore(widget.endDate));

    final emptyColor = context.onBrightness(light: Colors.grey[200]!, dark: Colors.grey[800]!);

    // 1) Collect every day from startDate..endDate
    final allDays = <Date>[];
    var day = widget.startDate;
    while (day.isBefore(widget.endDate) || day.isSameDay(widget.endDate)) {
      allDays.add(day);
      day = day.addDays(1);
    }

    // 2) Group days into columns (each column has up to 7 days)
    final columns = <List<Date>>[];
    final offsetToMonday = (widget.startDate.weekDay - 1) % 7;
    var currentColumn = <Date>[];

    // Fill with "filler" days if startDate isn't Monday
    for (int i = 0; i < offsetToMonday; i++) {
      currentColumn.add(widget.startDate.subtractDays(offsetToMonday - i));
    }

    for (final d in allDays) {
      currentColumn.add(d);
      if (currentColumn.length == 7) {
        columns.add(currentColumn);
        currentColumn = [];
      }
    }
    if (currentColumn.isNotEmpty) {
      columns.add(currentColumn);
    }

    // 3) Build month segments for the top header row.
    //    We want each segment to span all columns that belong to that month.
    final segments = _buildMonthSegments(columns);

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3A) The row of month labels
          Row(
            children: segments.map((seg) {
              if (seg.spanWidth < 70) {
                return SizedBox(width: seg.spanWidth);
              }
              return SizedBox(
                width: seg.spanWidth,
                child: Text(
                  seg.monthLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 6),

          // 3B) The row of columns (heatmap squares)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < columns.length; i++) ...[
                Column(children: [for (final date in columns[i]) _buildDayCell(date, emptyColor)]),
                // Spacing between columns
                if (i < columns.length - 1) SizedBox(width: widget.spacingBetweenWeeks),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single day cell (a square).
  Widget _buildDayCell(Date date, Color emptyColor) {
    final dayValue = widget.values[date] ?? 0;

    if (dayValue == 0) {
      return _Cell(
        margin: EdgeInsets.only(bottom: widget.spacingBetweenDays),
        cellSize: widget.cellSize,
        color: emptyColor,
      );
    }

    final factor = (dayValue / widget.maxValue).clamp(0.0, 1.0);
    final dayColor = Color.lerp(widget.minColor, widget.maxColor, factor)!;

    return _Cell(
      margin: EdgeInsets.only(bottom: widget.spacingBetweenDays),
      cellSize: widget.cellSize,
      color: dayColor,
    );
  }

  /// Given all columns (each with up to 7 days), figure out how many columns
  /// belong to each month. Then build a list of [MonthSegment], each representing
  /// a chunk of columns for that month, plus a "month label".
  List<MonthSegment> _buildMonthSegments(List<List<Date>> columns) {
    final segments = <MonthSegment>[];

    // The month of the current segment
    int? currentMonth;
    int segmentStartIndex = 0;

    for (int i = 0; i < columns.length; i++) {
      // Find a "real" date in the column to determine the column's month
      final firstRealDate = columns[i].firstWhere(
        (d) => !d.isBefore(widget.startDate),
        orElse: () => columns[i].first,
      );
      final colMonth = firstRealDate.month;

      // If we are starting or we've hit a new month, finalize the previous segment
      // and start a new one
      if (currentMonth == null) {
        // first column => start a new segment
        currentMonth = colMonth;
        segmentStartIndex = i;
      } else if (colMonth != currentMonth) {
        // finalize the old segment
        segments.add(_buildSegment(currentMonth, segmentStartIndex, i - 1, columns.length));
        // start a new segment
        currentMonth = colMonth;
        segmentStartIndex = i;
      }
    }

    // After the loop, finalize the last segment
    if (currentMonth != null) {
      segments.add(
        _buildSegment(currentMonth, segmentStartIndex, columns.length - 1, columns.length),
      );
    }

    return segments;
  }

  /// Constructs a single [MonthSegment] from [startColIndex..endColIndex]
  MonthSegment _buildSegment(int month, int startColIndex, int endColIndex, int totalCols) {
    // Number of columns spanned
    final numColumns = (endColIndex - startColIndex + 1);
    // The total width of those columns is:
    // = (numColumns * cellSize) + (numColumns - 1) * spacingBetweenWeeks
    // We do (numColumns - 1) because there's no spacing after the last column
    // in that chunk from within the chunk.
    final double columnsWidth =
        (numColumns * widget.cellSize) + (numColumns - 1) * widget.spacingBetweenWeeks;

    final monthLabel = _monthAbbrev(month);

    return MonthSegment(
      monthLabel: monthLabel,
      spanWidth: columnsWidth,
      startIndex: startColIndex,
      endIndex: endColIndex,
    );
  }

  String _monthAbbrev(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }
}

/// Simple helper class for each "month chunk" in the top header row.
class MonthSegment {
  final String monthLabel;
  final double spanWidth;
  final int startIndex;
  final int endIndex;

  MonthSegment({
    required this.monthLabel,
    required this.spanWidth,
    required this.startIndex,
    required this.endIndex,
  });
}

class _Cell extends StatelessWidget {
  final Color color;
  final EdgeInsets margin;
  final double cellSize;

  const _Cell({required this.color, required this.margin, required this.cellSize});

  @override
  Widget build(BuildContext context) {
    return Container(margin: margin, width: cellSize, height: cellSize, color: color);
  }
}
