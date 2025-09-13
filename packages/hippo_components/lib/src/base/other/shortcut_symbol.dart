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
import 'package:hippo_components/hippo_components.dart';

class ShortcutSymbol extends StatelessWidget {
  final String text;
  final Color? color;
  const ShortcutSymbol({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return OptionalTooltip(
      message: 'Tastenkürzel: $text',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(width: 0.5, color: color ?? Theme.of(context).dividerColor),
        ),
        height: 16,
        width: 16,
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: color),
          ),
        ),
      ),
    );
  }
}

class ShortcutSymbolIcon extends StatelessWidget {
  final IconData iconData;
  const ShortcutSymbolIcon({super.key, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return OptionalTooltip(
      message: 'Tastenkürzel',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(width: 0.5, color: Theme.of(context).dividerColor),
        ),
        height: 16,
        width: 16,
        child: Center(child: Icon(iconData, size: 12)),
      ),
    );
  }
}
