/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:flutter/material.dart';

class Routing {
  static Future<T?> openPage<T>(
    BuildContext context,
    Widget widget, {
    String? name,
    bool fullscreenDialog = false,
  }) {
    return Navigator.of(context, rootNavigator: true).push<T>(
      MaterialPageRoute(
        builder: (context) => widget,
        settings: RouteSettings(name: name),
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  static Future<void> openReplacementPage(
    BuildContext context,
    Widget widget, {
    String? name,
  }) async {
    await Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (context) => widget,
        settings: RouteSettings(name: name),
      ),
    );
  }

  static Future<bool> launchUrl(String url, {bool self = false}) {
    return url_launcher.launchUrl(Uri.parse(url), webOnlyWindowName: self ? '_self' : null);
  }
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required super.builder,
    required RouteSettings super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
