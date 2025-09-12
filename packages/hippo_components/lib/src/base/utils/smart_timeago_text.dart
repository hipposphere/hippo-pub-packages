import 'package:flutter/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

class SmartTimeagoText extends StatelessWidget {
  final DateTime dateTime;
  final TextStyle? style;
  const SmartTimeagoText({super.key, this.style, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final text = dateTime.difference(DateTime.now()).inDays > 3
        ? dateTime.toString()
        : timeago.format(dateTime, allowFromNow: false);
    return Text(text, style: style ?? TextStyle(fontSize: 14));
  }
}
