/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
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
