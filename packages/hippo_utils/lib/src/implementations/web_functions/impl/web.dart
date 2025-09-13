/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:js_interop';
import 'package:flutter_web_plugins/flutter_web_plugins.dart' as flutter_web_plugins;
import 'package:web/web.dart' as web;
import '../models/web_functions_abstraction.dart';

class WebFunctionsImpl implements WebFunctionsAbstraction {
  @override
  Future<void> reload() async {
    web.window.location.reload();
  }

  @override
  Future<void> clearCacheStorageAndReload() async {
    try {
      final cacheNames = (await (web.window.caches.keys().toDart)).toDart
          .map((e) => e.toDart)
          .toList();

      await Future.wait(cacheNames.map((name) => (web.window.caches.delete(name).toDart)));
    } catch (_) {}

    web.window.location.reload();
  }

  @override
  void setPathUrlStrategy() {
    flutter_web_plugins.usePathUrlStrategy();
  }
}
