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
      variant: switch (style) {
        AlertStyle.primary => .primary,
        AlertStyle.destructive => .destructive,
      },
    );
  }
}
