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
import 'package:forui/forui.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:url_launcher/link.dart';

enum ButtonType { primary, secondary, outline, destructive }

/// A button that can be used to trigger an action.
class Button extends StatelessWidget {
  final VoidCallback? onTap, onLongPress;
  final Widget? prefix, suffix;
  final String label;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final ButtonType type;
  final Color? backgroundColor;
  const Button({
    super.key,
    required this.onTap,
    this.onLongPress,
    required this.label,
    this.tooltip,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.type = ButtonType.primary,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return OptionalTooltip(
      message: tooltip,
      child: IconTheme(
        data: switch ((type, Theme.of(context).brightness)) {
          (ButtonType.primary, Brightness.light) => _whiteIcon,
          (ButtonType.secondary, Brightness.light) => _blackIcon,
          (ButtonType.outline, Brightness.light) => _blackIcon,
          (ButtonType.destructive, Brightness.light) => _whiteIcon,
          (ButtonType.primary, Brightness.dark) => _whiteIcon,
          (ButtonType.secondary, Brightness.dark) => _whiteIcon,
          (ButtonType.outline, Brightness.dark) => _whiteIcon,
          (ButtonType.destructive, Brightness.dark) => _whiteIcon,
        },
        child: FButton(
          onPress: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          prefix: prefix,
          suffix: suffix,
          focusNode: focusNode,
          autofocus: autofocus,
          variant: switch (type) {
            ButtonType.primary => .primary,
            ButtonType.secondary => .secondary,
            ButtonType.outline => .outline,
            ButtonType.destructive => .destructive,
          },
          child: Text(label),
        ),
      ),
    );
  }
}

class LinkButton extends StatelessWidget {
  final String href;
  final Widget? prefix, suffix;
  final String label;
  final String? tooltip;
  final LinkTarget target;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final ButtonType type;
  const LinkButton({
    super.key,
    required this.href,
    this.target = LinkTarget.blank,
    required this.label,
    this.tooltip,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.type = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return OptionalTooltip(
      message: tooltip,
      child: IconTheme(
        data: switch ((type, Theme.of(context).brightness)) {
          (ButtonType.primary, Brightness.light) => _whiteIcon,
          (ButtonType.secondary, Brightness.light) => _blackIcon,
          (ButtonType.outline, Brightness.light) => _blackIcon,
          (ButtonType.destructive, Brightness.light) => _whiteIcon,
          (ButtonType.primary, Brightness.dark) => _whiteIcon,
          (ButtonType.secondary, Brightness.dark) => _whiteIcon,
          (ButtonType.outline, Brightness.dark) => _whiteIcon,
          (ButtonType.destructive, Brightness.dark) => _whiteIcon,
        },
        child: Link(
          uri: Uri.parse(href),
          target: target,
          builder: (context, followLink) {
            return FButton(
              onPress: followLink,
              prefix: prefix,
              suffix: suffix,
              focusNode: focusNode,
              autofocus: autofocus,
              variant: switch (type) {
                ButtonType.primary => .primary,
                ButtonType.secondary => .secondary,
                ButtonType.outline => .outline,
                ButtonType.destructive => .destructive,
              },
              child: Text(label),
            );
          },
        ),
      ),
    );
  }
}

const _whiteIcon = IconThemeData(color: Colors.white, size: 18.0);
const _blackIcon = IconThemeData(color: Colors.black, size: 18.0);
