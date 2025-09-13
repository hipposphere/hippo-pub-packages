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

class PagePinnedBarSliver extends StatelessWidget {
  final double height;
  final Widget child;
  const PagePinnedBarSliver({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      primary: false,
      backgroundColor: Colors.transparent,
      toolbarHeight: height,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(border: kDefaultNavBarBorder),
        child: CupertinoBlurContainer(height: height, child: child),
      ),
    );
  }
}
