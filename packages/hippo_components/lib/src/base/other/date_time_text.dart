import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeText extends StatelessWidget {
  final DateTime dateTime;
  final String format;
  final TextStyle? style;
  final TextAlign? textAlign;

  const DateTimeText({
    super.key,
    required this.dateTime,
    required this.format,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final text = DateFormat(format).format(dateTime);
    return Text(text, style: style, textAlign: textAlign);
  }
}

String buildDateTimeText(DateTime dateTime, String format) {
  return DateFormat(format).format(dateTime);
}
