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

class Gap extends StatelessWidget {
  final double gap;

  const Gap(this.gap, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: gap, height: gap);
  }
}
