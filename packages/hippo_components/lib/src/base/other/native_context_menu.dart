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

import 'native_context_menu_model.dart';
import 'native_context_menu_web.dart'
    if (dart.library.io) 'native_context_menu_native.dart'
    as platform;

export 'native_context_menu_model.dart';

/// Wraps [child] with a platform context menu.
///
/// Native builds use `nativeapi` menus. Web builds use Flutter's menu widgets
/// and disable the browser context menu while the app is running.
class NativeContextMenu extends StatelessWidget {
  final Widget child;
  final MenuProvider menuProvider;
  final HitTestBehavior hitTestBehavior;
  final bool enabled;

  const NativeContextMenu({
    super.key,
    required this.child,
    required this.menuProvider,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return platform.PlatformNativeContextMenu(
      menuProvider: menuProvider,
      hitTestBehavior: hitTestBehavior,
      child: child,
    );
  }
}
