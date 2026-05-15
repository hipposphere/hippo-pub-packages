/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class LimitedSliverPadded extends StatelessWidget {
  final Widget sliver;
  final double maxWidth;
  final EdgeInsets padding;

  const LimitedSliverPadded({
    super.key,
    required this.sliver,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisPadding = padding.left + padding.right;
        final availableWidth = math.max(0, constraints.crossAxisExtent - crossAxisPadding);
        final extraPadding = math.max(0, (availableWidth - maxWidth) / 2);

        return SliverPadding(
          padding: EdgeInsets.only(
            left: padding.left + extraPadding,
            top: padding.top,
            right: padding.right + extraPadding,
            bottom: padding.bottom,
          ),
          sliver: sliver,
        );
      },
    );
  }
}
