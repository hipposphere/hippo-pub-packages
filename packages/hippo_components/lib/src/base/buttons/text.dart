/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';

class TextTappable extends StatelessWidget {
  final Widget? prefix, suffix;
  final String label;
  final VoidCallback? onTap;
  final EdgeInsets margin;
  final TextStyle? style;
  final bool enabled;
  final bool coloredHover;
  final bool textAlwaysUnderlined;
  const TextTappable({
    super.key,
    this.prefix,
    this.suffix,
    this.margin = const EdgeInsets.all(8),
    this.style,
    this.enabled = true,
    this.coloredHover = true,
    this.textAlwaysUnderlined = false,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cupertinoTextStyle = CupertinoTheme.of(context).textTheme.textStyle;

    final textStyle = style ?? cupertinoTextStyle;
    return IconTheme(
      data: IconThemeData(
        color: textStyle.color ?? cupertinoTextStyle.color,
        size: textStyle.fontSize ?? cupertinoTextStyle.fontSize,
      ),
      child: Tappable(
        onTap: onTap,
        margin: margin,
        coloredHover: coloredHover,
        builder: (context, isHovered, isFocused) => RichText(
          text: TextSpan(
            children: [
              if (prefix != null) WidgetSpan(child: prefix!),
              TextSpan(text: label),
              if (suffix != null) WidgetSpan(child: suffix!),
            ],
            style: cupertinoTextStyle.merge(
              textStyle.copyWith(
                decoration: textAlwaysUnderlined || isHovered
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LinkTappable extends StatelessWidget {
  final Widget? prefix, suffix;
  final String label;
  final String href;
  final EdgeInsets margin;
  final LinkTarget target;
  final TextStyle? style;
  final bool coloredHover;
  final bool textAlwaysUnderlined;
  const LinkTappable({
    super.key,
    this.prefix,
    this.suffix,
    this.margin = const EdgeInsets.all(8),
    this.target = LinkTarget.blank,
    this.style,
    this.coloredHover = true,
    this.textAlwaysUnderlined = false,
    required this.label,
    required this.href,
  });

  const LinkTappable.raw({
    super.key,
    this.prefix,
    this.suffix,
    this.margin = const EdgeInsets.only(),
    this.target = LinkTarget.blank,
    this.style,
    this.coloredHover = false,
    this.textAlwaysUnderlined = false,
    required this.label,
    required this.href,
  });

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: Uri.parse(href),
      target: target,
      builder: (context, followLink) => TextTappable(
        prefix: prefix,
        suffix: suffix,
        label: label,
        margin: margin,
        style:
            style ??
            TextStyle(
              color: CupertinoColors.activeBlue,
              decorationColor: CupertinoColors.activeBlue,
            ),
        coloredHover: coloredHover,
        textAlwaysUnderlined: textAlwaysUnderlined,
        onTap: () {
          followLink!();
        },
      ),
    );
  }
}

class TappableTextSpan extends TextSpan {
  TappableTextSpan({super.style, required super.text, required VoidCallback onTap})
    : super(
        recognizer: TapGestureRecognizer()..onTap = onTap,
        mouseCursor: SystemMouseCursors.click,
      );
}

class LinkTappableTextSpan extends TappableTextSpan {
  LinkTappableTextSpan({super.style, required super.text, required String href})
    : super(
        onTap: () {
          launchUrl(Uri.parse(href));
        },
      );
}
