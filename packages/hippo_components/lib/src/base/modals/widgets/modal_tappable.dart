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

class ModalTappable extends StatelessWidget {
  final String? tooltip;
  final VoidCallback? onTap;
  final Widget child;
  const ModalTappable({super.key, this.tooltip, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      tooltip: tooltip,
      margin: const EdgeInsets.all(16.0),
      onTap: onTap,
      child: child,
    );
  }
}
