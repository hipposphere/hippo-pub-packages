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
import 'package:super_context_menu/super_context_menu.dart';
export 'package:super_context_menu/super_context_menu.dart'
    show MenuProvider, Menu, MenuAction, MenuActionState, MenuImage;

/// A widget that wraps a child widget with a native context menu.
/// The context menu will be shown on Mobile when the user long presses on the child widget.
/// The context menu will be shown on Desktop when the user right clicks on the child widget.
/// The context menu is built using the [menuProvider].
class NativeContextMenu extends StatelessWidget {
  final Widget child;
  final MenuProvider menuProvider;
  const NativeContextMenu({super.key, required this.child, required this.menuProvider});

  @override
  Widget build(BuildContext context) {
    return ContextMenuWidget(menuProvider: menuProvider, child: child);
  }
}
