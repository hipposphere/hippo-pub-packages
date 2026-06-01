/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'native_context_menu_model.dart';

class PlatformNativeContextMenu extends StatefulWidget {
  final Widget child;
  final MenuProvider menuProvider;
  final HitTestBehavior hitTestBehavior;

  const PlatformNativeContextMenu({
    super.key,
    required this.child,
    required this.menuProvider,
    required this.hitTestBehavior,
  });

  @override
  State<PlatformNativeContextMenu> createState() => _PlatformNativeContextMenuState();
}

class _PlatformNativeContextMenuState extends State<PlatformNativeContextMenu> {
  final MenuController _controller = MenuController();
  Menu? _menu;
  PointerDeviceKind? _lastPointerKind;

  @override
  void initState() {
    super.initState();
    if (BrowserContextMenu.enabled) {
      unawaited(BrowserContextMenu.disableContextMenu());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _controller,
      consumeOutsideTap: true,
      useRootOverlay: true,
      menuChildren: _buildMenuChildren(_menu?.children ?? const []),
      child: Listener(
        behavior: widget.hitTestBehavior,
        onPointerDown: (event) => _lastPointerKind = event.kind,
        child: GestureDetector(
          behavior: widget.hitTestBehavior,
          onSecondaryTapDown: (details) {
            unawaited(_openMenu(details.localPosition, details.globalPosition));
          },
          onLongPressStart: (details) {
            if (_lastPointerKind == PointerDeviceKind.mouse) {
              return;
            }
            unawaited(_openMenu(details.localPosition, details.globalPosition));
          },
          child: widget.child,
        ),
      ),
    );
  }

  Future<void> _openMenu(Offset localPosition, Offset globalPosition) async {
    try {
      final menu = await Future<Menu?>.value(
        widget.menuProvider(MenuRequest(location: globalPosition)),
      );
      if (!mounted || menu == null || menu.children.isEmpty) {
        return;
      }

      setState(() => _menu = menu);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.open(position: localPosition);
        }
      });
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'hippo_components',
          context: ErrorDescription('while opening a web context menu'),
        ),
      );
    }
  }

  List<Widget> _buildMenuChildren(List<MenuElement> elements) {
    return [
      for (final element in elements)
        if (element is MenuSeparator)
          const Divider(height: 1)
        else if (element is MenuAction)
          _buildAction(element)
        else if (element is Menu)
          SubmenuButton(
            leadingIcon: _imageWidget(element.image),
            menuChildren: _buildMenuChildren(element.children),
            child: Text(element.title ?? ''),
          ),
    ];
  }

  Widget _buildAction(MenuAction action) {
    return MenuItemButton(
      onPressed: action.attributes.disabled ? null : action.callback,
      leadingIcon: _stateIcon(action.state) ?? _imageWidget(action.image),
      shortcut: action.activator,
      style: action.attributes.destructive
          ? MenuItemButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error)
          : null,
      child: Text(action.title ?? ''),
    );
  }

  Widget? _stateIcon(MenuActionState state) {
    return switch (state) {
      MenuActionState.none || MenuActionState.checkOff || MenuActionState.radioOff => null,
      MenuActionState.checkOn => const Icon(Icons.check),
      MenuActionState.checkMixed => const Icon(Icons.remove),
      MenuActionState.radioOn => const Icon(Icons.radio_button_checked),
    };
  }

  Widget? _imageWidget(MenuImage? image) {
    final widget = image?.asWidget(const IconThemeData(size: 18));
    if (widget == null) {
      return null;
    }

    return SizedBox.square(dimension: 18, child: FittedBox(child: widget));
  }
}
