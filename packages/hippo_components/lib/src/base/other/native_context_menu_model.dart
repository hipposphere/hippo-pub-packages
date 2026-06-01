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
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef MenuProvider = FutureOr<Menu?> Function(MenuRequest request);

class MenuRequest {
  /// Menu location in global Flutter coordinates.
  final Offset location;

  const MenuRequest({required this.location});
}

abstract class MenuImage {
  const MenuImage();

  const factory MenuImage.asset(String assetName) = AssetMenuImage;

  const factory MenuImage.file(String path) = FileMenuImage;

  const factory MenuImage.base64(String data) = Base64MenuImage;

  const factory MenuImage.icon(IconData icon) = IconMenuImage;

  const factory MenuImage.system(String systemImageName) = SystemMenuImage;

  factory MenuImage.withImage(
    FutureOr<ui.Image?>? Function(IconThemeData theme, int devicePixelRatio) imageProvider,
  ) = ImageProviderMenuImage;

  Widget? asWidget(IconThemeData theme) => null;

  FutureOr<ui.Image?> asImage(IconThemeData theme, double devicePixelRatio) => null;
}

class AssetMenuImage extends MenuImage {
  final String assetName;

  const AssetMenuImage(this.assetName);

  @override
  Widget asWidget(IconThemeData theme) {
    final size = theme.size;
    return Image.asset(assetName, width: size, height: size);
  }
}

class FileMenuImage extends MenuImage {
  final String path;

  const FileMenuImage(this.path);
}

class Base64MenuImage extends MenuImage {
  final String data;

  const Base64MenuImage(this.data);

  @override
  Widget asWidget(IconThemeData theme) {
    final size = theme.size;
    return Image.memory(_decodeBase64Image(data), width: size, height: size);
  }
}

class IconMenuImage extends MenuImage {
  final IconData icon;

  const IconMenuImage(this.icon);

  @override
  Widget asWidget(IconThemeData theme) {
    return Icon(icon, size: theme.size, color: theme.color);
  }
}

class SystemMenuImage extends MenuImage {
  final String systemImageName;

  const SystemMenuImage(this.systemImageName);
}

class ImageProviderMenuImage extends MenuImage {
  final FutureOr<ui.Image?>? Function(IconThemeData theme, int devicePixelRatio) imageProvider;

  ImageProviderMenuImage(this.imageProvider);

  @override
  FutureOr<ui.Image?> asImage(IconThemeData theme, double devicePixelRatio) {
    return imageProvider(theme, devicePixelRatio.round());
  }
}

Uint8List _decodeBase64Image(String data) {
  final payload = data.contains(',') ? data.substring(data.indexOf(',') + 1) : data;
  return base64Decode(payload);
}

class MenuElement {
  final String? title;
  final String? subtitle;
  final MenuImage? image;
  final int uniqueId;

  MenuElement({this.title, this.subtitle, this.image}) : uniqueId = _nextId++;

  MenuElement? find({required int uniqueId}) {
    return this.uniqueId == uniqueId ? this : null;
  }
}

class MenuSeparator extends MenuElement {
  MenuSeparator({super.title});
}

class Menu extends MenuElement {
  final List<MenuElement> children;

  Menu({super.title, super.subtitle, super.image, required this.children});

  @override
  MenuElement? find({required int uniqueId}) {
    final result = super.find(uniqueId: uniqueId);
    if (result != null) {
      return result;
    }

    for (final child in children) {
      final childResult = child.find(uniqueId: uniqueId);
      if (childResult != null) {
        return childResult;
      }
    }

    return null;
  }
}

class MenuActionAttributes {
  final bool disabled;
  final bool destructive;

  const MenuActionAttributes({this.disabled = false, this.destructive = false});
}

enum MenuActionState { none, checkOn, checkOff, checkMixed, radioOn, radioOff }

class MenuAction extends MenuElement {
  final VoidCallback callback;
  final MenuActionAttributes attributes;
  final MenuActionState state;
  final SingleActivator? activator;

  MenuAction({
    super.title,
    super.subtitle,
    super.image,
    required this.callback,
    this.attributes = const MenuActionAttributes(),
    this.state = MenuActionState.none,
    this.activator,
  });
}

int _nextId = 1;
