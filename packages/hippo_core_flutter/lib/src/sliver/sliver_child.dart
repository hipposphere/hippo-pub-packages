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

import '../common/limited_container.dart';

class SliverChild extends StatelessWidget {
  final EdgeInsets padding;
  final double maxWidth;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;

  const SliverChild({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: LimitedContainerPadded(
        padding: padding,
        maxWidth: maxWidth,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            const SizedBox(width: double.infinity),
            child,
          ],
        ),
      ),
    );
  }
}
