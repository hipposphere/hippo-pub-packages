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

class EmptyListView extends StatelessWidget {
  final String? label;
  final String? description;
  const EmptyListView({super.key, this.label, this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Gap(16),
        LottieViewer(asset: OtherAssets.emptyListAnimation, width: 200, height: 200, repeat: false),
        Text(
          label ?? 'Keine Ergebnisse',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        Gap(8),
        Text(
          description ?? 'Es wurden keine Ergebnisse gefunden.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        Gap(16),
      ],
    );
  }
}
