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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownText extends StatelessWidget {
  final String text;
  final double textScaleFactor;
  final bool selectable;
  const MarkdownText(this.text, {super.key, this.textScaleFactor = 1.2, this.selectable = false});

  @override
  Widget build(BuildContext context) {
    if (selectable) {
      return SelectableRegion(
        selectionControls: materialTextSelectionControls,
        child: MarkdownBody(
          data: text,
          styleSheet: MarkdownStyleSheet(textScaler: TextScaler.linear(textScaleFactor)),
          selectable: false,
          onTapLink: _onTapLink,
        ),
      );
    }
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet(textScaler: TextScaler.linear(textScaleFactor)),
      selectable: false,
      onTapLink: _onTapLink,
    );
  }

  void _onTapLink(String text, String? href, String title) {
    if (href != null && href.isNotEmpty) {
      // Handle link tap, e.g., open in browser
      launchUrl(Uri.parse(href));
    }
  }
}
