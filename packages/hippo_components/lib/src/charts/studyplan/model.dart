import 'package:flutter/material.dart';

class StudyDay {
  final int day;
  final List<DayStudyElement> elements;
  final Color? labelColor;
  final String? indexLabel;
  final Widget? tooltip;
  final Function(BuildContext context)? onTap;
  final String? groupName;
  final Color? groupColor;

  StudyDay({
    required this.day,
    required this.elements,
    this.labelColor,
    this.indexLabel,
    this.tooltip,
    this.onTap,
    this.groupName,
    this.groupColor,
  });
}

class TooltipHitInfo<T1, T2, T3, T4> {
  final T1 item1;
  final T2 item2;
  final T3 item3;
  final T4 item4;
  TooltipHitInfo(this.item1, this.item2, this.item3, this.item4);
}

class DayStudyElement {
  final double height;
  final Color color;
  final String? label;
  final Widget? tooltip;
  final Function(BuildContext context)? onTap;

  DayStudyElement({
    required this.height,
    required this.color,
    required this.tooltip,
    this.label,
    this.onTap,
  });
}
