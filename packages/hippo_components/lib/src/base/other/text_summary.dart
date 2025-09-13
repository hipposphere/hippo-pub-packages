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

class TextSummary extends StatelessWidget {
  final String label;
  final String text;
  const TextSummary({super.key, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      onTap: () {
        TextSummaryModal(label: label, text: text).open(context);
      },
      scaleDown: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SizedBox(width: double.infinity),
            Padding(
              padding: const EdgeInsets.only(right: 48.0),
              child: Text(text, style: TextStyle(), overflow: TextOverflow.fade, maxLines: 3),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Icon(Icons.arrow_forward_ios, color: Theme.of(context).dividerColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class TextSummaryModal {
  final String label;
  final String text;

  TextSummaryModal({required this.label, required this.text});

  InfoModal buildModal() {
    return InfoModal(
      title: label,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(text, style: TextStyle()),
      ),
    );
  }

  Future<void> open(BuildContext context) async {
    final modal = buildModal();
    await modal.open(context);
  }
}
