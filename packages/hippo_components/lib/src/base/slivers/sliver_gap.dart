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

class SliverGap extends StatelessWidget {
  final double gap;
  const SliverGap(this.gap, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Gap(gap));
  }
}
