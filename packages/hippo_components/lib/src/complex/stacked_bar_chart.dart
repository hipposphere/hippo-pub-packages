// Bar chart example
import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

class StackedBarChart extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate;

  const StackedBarChart({super.key, required this.seriesList, this.animate = true});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      defaultInteractions: false,
      defaultRenderer: charts.BarRendererConfig<DateTime>(
        groupingType: charts.BarGroupingType.stacked,
      ),
      behaviors: [charts.SelectNearest(), charts.DomainHighlighter()],
    );
  }
}
