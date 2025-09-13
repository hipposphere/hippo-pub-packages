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
import 'package:forui/forui.dart';
import 'package:hippo_components/hippo_components.dart';

enum SymbolButtonType { primary, outline, destructive }

class SymbolButton extends StatelessWidget {
  final VoidCallback? onTap, onLongPress;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;
  final SymbolButtonType type;
  final Widget icon;
  const SymbolButton({
    super.key,
    required this.onTap,
    this.onLongPress,
    required this.icon,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.type = SymbolButtonType.outline,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness!;
    return OptionalTooltip(
      message: tooltip,
      child: IconTheme(
        data: switch ((type, brightness)) {
          // Primary
          (SymbolButtonType.primary, Brightness.light) => _whiteIcon,
          (SymbolButtonType.primary, Brightness.dark) => _whiteIcon,
          // Outline
          (SymbolButtonType.outline, Brightness.light) => _blackIcon,
          (SymbolButtonType.outline, Brightness.dark) => _whiteIcon,
          // Destructive
          (SymbolButtonType.destructive, Brightness.light) => _whiteIcon,
          (SymbolButtonType.destructive, Brightness.dark) => _whiteIcon,
        },
        child: FButton.icon(
          onPress: onTap,
          focusNode: focusNode,
          autofocus: autofocus,
          style: switch (type) {
            SymbolButtonType.primary => FButtonStyle.primary(),
            SymbolButtonType.outline => FButtonStyle.outline(),
            SymbolButtonType.destructive => FButtonStyle.destructive(),
          },
          child: icon,
        ),
      ),
    );
  }
}

const _whiteIcon = IconThemeData(color: HippoColors.white);
const _blackIcon = IconThemeData(color: HippoColors.black);
