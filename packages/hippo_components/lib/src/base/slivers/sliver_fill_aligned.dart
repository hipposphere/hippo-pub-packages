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
import 'package:hippo_components/hippo_components.dart';

class SliverFillAlignedChild extends StatelessWidget {
  final Widget child;
  final Alignment alignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;
  const SliverFillAlignedChild({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: LimitedContainerPadded(
        alignment: alignment,
        padding: padding,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: double.infinity),
            child,
          ],
        ),
      ),
    );
  }
}

class SliverFillAlignedColumn extends StatelessWidget {
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;
  final Alignment alignment;
  const SliverFillAlignedColumn({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.alignment = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      fillOverscroll: false,
      child: LimitedContainerPadded(
        alignment: alignment,
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            SizedBox(width: double.infinity),
            ...children,
          ],
        ),
      ),
    );
  }
}
