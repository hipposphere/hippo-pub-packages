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
import 'package:sliver_tools/sliver_tools.dart' as sliver_tools;

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
    return SliverPadding(
      padding: padding,
      sliver: sliver_tools.SliverCrossAxisConstrained(
        maxCrossAxisExtent: maxWidth,
        alignment: 0, // 0 = center
        child: sliver,
      ),
    );
  }
}
