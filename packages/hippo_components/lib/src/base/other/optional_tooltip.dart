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

// TODOS: Add optional focus to the tooltip -> Use it in the tappable widget
class OptionalTooltip extends StatelessWidget {
  final String? message;
  final Widget child;
  final Alignment tipAnchor;
  final Alignment childAnchor;
  const OptionalTooltip({
    super.key,
    this.message,
    this.tipAnchor = Alignment.bottomCenter,
    this.childAnchor = Alignment.topCenter,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return child;
    }
    return FTooltip(
      hover: true,
      childAnchor: childAnchor,
      tipAnchor: tipAnchor,
      style: .delta(hoverEnterDuration: Duration(milliseconds: 250)),
      tipBuilder: (context, style) => Text(message!),
      child: child,
    );
  }
}
