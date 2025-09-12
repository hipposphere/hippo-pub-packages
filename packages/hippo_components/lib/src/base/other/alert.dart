import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

enum AlertStyle { primary, destructive }

class Alert extends StatelessWidget {
  final String title;
  final String? subtitle;
  final AlertStyle style;
  const Alert({super.key, required this.title, this.subtitle, this.style = AlertStyle.primary});

  @override
  Widget build(BuildContext context) {
    return FAlert(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      style: switch (style) {
        AlertStyle.primary => FAlertStyle.primary(),
        AlertStyle.destructive => FAlertStyle.destructive(),
      },
    );
  }
}
