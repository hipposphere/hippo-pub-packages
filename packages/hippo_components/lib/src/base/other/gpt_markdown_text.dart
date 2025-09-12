import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class GptMarkdownText extends StatelessWidget {
  final String text;
  final double textScaleFactor;
  final bool selectable;
  const GptMarkdownText(
    this.text, {
    super.key,
    this.textScaleFactor = 1.2,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (selectable) {
      return SelectableRegion(
        selectionControls: materialTextSelectionControls,
        child: GptMarkdown(text, textScaler: TextScaler.linear(textScaleFactor)),
      );
    }
    return GptMarkdown(text, textScaler: TextScaler.linear(textScaleFactor));
  }
}
