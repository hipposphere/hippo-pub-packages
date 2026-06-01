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
import 'package:flutter/widgets.dart' hide Image;
import 'package:nativeapi/nativeapi.dart' as nativeapi;

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
  final List<_NativeMenuBundle> _openMenus = [];
  PointerDeviceKind? _lastPointerKind;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: widget.hitTestBehavior,
      onPointerDown: (event) {
        _lastPointerKind = event.kind;
        if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
          unawaited(_openMenu(event.position));
        }
      },
      child: GestureDetector(
        behavior: widget.hitTestBehavior,
        onLongPressStart: (details) {
          if (_lastPointerKind == PointerDeviceKind.mouse) {
            return;
          }
          unawaited(_openMenu(details.globalPosition));
        },
        child: widget.child,
      ),
    );
  }

  Future<void> _openMenu(Offset location) async {
    try {
      final menu = await Future<Menu?>.value(widget.menuProvider(MenuRequest(location: location)));
      if (!mounted || menu == null || menu.children.isEmpty) {
        return;
      }

      final bundle = _buildNativeMenu(menu);
      _openMenus.add(bundle);
      bundle.menu.on<nativeapi.MenuClosedEvent>((_) => _disposeBundle(bundle));

      final activeWindow = nativeapi.WindowManager.instance.getCurrent();
      final strategy = activeWindow == null
          ? nativeapi.PositioningStrategy.absolute(location)
          : nativeapi.PositioningStrategy.relativeToWindow(activeWindow, location);
      final opened = bundle.menu.open(strategy, nativeapi.Placement.bottomStart);
      if (!opened) {
        _disposeBundle(bundle);
      }
    } catch (error, stackTrace) {
      _reportContextMenuError(error, stackTrace);
    }
  }

  _NativeMenuBundle _buildNativeMenu(Menu source) {
    final bundle = _NativeMenuBundle(nativeapi.Menu());
    var radioGroup = source.uniqueId;

    for (final element in source.children) {
      if (element is MenuSeparator) {
        bundle.menu.addSeparator();
      } else if (element is MenuAction) {
        final item = _buildNativeMenuItem(element, radioGroup, bundle);
        bundle.items.add(item);
        bundle.menu.addItem(item);
      } else if (element is Menu) {
        final submenu = _buildNativeMenu(element);
        final item = nativeapi.MenuItem(element.title ?? '', nativeapi.MenuItemType.submenu);
        item.submenu = submenu.menu;
        final icon = _buildNativeImage(element.image);
        if (icon != null) {
          bundle.images.add(icon);
          item.icon = icon;
        }
        bundle.children.add(submenu);
        bundle.items.add(item);
        bundle.menu.addItem(item);
        radioGroup++;
      }
    }

    return bundle;
  }

  nativeapi.MenuItem _buildNativeMenuItem(
    MenuAction action,
    int radioGroup,
    _NativeMenuBundle bundle,
  ) {
    final item = nativeapi.MenuItem(action.title ?? '', _nativeItemType(action.state));
    item.enabled = !action.attributes.disabled;

    switch (action.state) {
      case MenuActionState.none:
        break;
      case MenuActionState.checkOn:
        item.state = nativeapi.MenuItemState.checked;
      case MenuActionState.checkOff:
        item.state = nativeapi.MenuItemState.unchecked;
      case MenuActionState.checkMixed:
        item.state = nativeapi.MenuItemState.mixed;
      case MenuActionState.radioOn:
        item.radioGroup = radioGroup;
        item.state = nativeapi.MenuItemState.checked;
      case MenuActionState.radioOff:
        item.radioGroup = radioGroup;
        item.state = nativeapi.MenuItemState.unchecked;
    }

    final icon = _buildNativeImage(action.image);
    if (icon != null) {
      bundle.images.add(icon);
      item.icon = icon;
    }

    item.on<nativeapi.MenuItemClickedEvent>((_) {
      try {
        action.callback();
      } catch (error, stackTrace) {
        _reportContextMenuError(error, stackTrace);
      }
    });

    return item;
  }

  nativeapi.MenuItemType _nativeItemType(MenuActionState state) {
    return switch (state) {
      MenuActionState.none => nativeapi.MenuItemType.normal,
      MenuActionState.checkOn ||
      MenuActionState.checkOff ||
      MenuActionState.checkMixed => nativeapi.MenuItemType.checkbox,
      MenuActionState.radioOn || MenuActionState.radioOff => nativeapi.MenuItemType.radio,
    };
  }

  nativeapi.Image? _buildNativeImage(MenuImage? image) {
    return switch (image) {
      null => null,
      AssetMenuImage(:final assetName) => nativeapi.Image.fromAsset(assetName),
      FileMenuImage(:final path) => nativeapi.Image.fromFile(path),
      Base64MenuImage(:final data) => nativeapi.Image.fromBase64(data),
      SystemMenuImage() || IconMenuImage() || ImageProviderMenuImage() => null,
      _ => null,
    };
  }

  void _disposeBundle(_NativeMenuBundle bundle) {
    if (!_openMenus.remove(bundle)) {
      return;
    }
    bundle.dispose();
  }

  void _reportContextMenuError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'hippo_components',
        context: ErrorDescription('while opening a native context menu'),
      ),
    );
  }

  @override
  void dispose() {
    for (final bundle in List<_NativeMenuBundle>.of(_openMenus)) {
      bundle.dispose();
    }
    _openMenus.clear();
    super.dispose();
  }
}

class _NativeMenuBundle {
  final nativeapi.Menu menu;
  final List<nativeapi.MenuItem> items = [];
  final List<nativeapi.Image> images = [];
  final List<_NativeMenuBundle> children = [];

  _NativeMenuBundle(this.menu);

  void dispose() {
    menu.dispose();
    for (final child in children) {
      child.dispose();
    }
    for (final item in items) {
      item.dispose();
    }
    for (final image in images) {
      image.dispose();
    }
  }
}
