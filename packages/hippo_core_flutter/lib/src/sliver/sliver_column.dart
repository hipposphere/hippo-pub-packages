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

import 'sliver_child.dart';

class SliverColumn extends StatelessWidget {
  final EdgeInsets padding;
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final double maxWidth;
  final double spacing;

  const SliverColumn({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 0,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return SliverChild(
      padding: padding,
      maxWidth: maxWidth,
      crossAxisAlignment: crossAxisAlignment,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        spacing: spacing,
        children: [
          const SizedBox(width: double.infinity),
          ...children,
        ],
      ),
    );
  }
}
