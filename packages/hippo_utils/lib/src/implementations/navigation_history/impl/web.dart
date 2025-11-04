/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

void addWebHistoryElementImplementation(String title, String tag) {
  Future.delayed(
    Duration.zero,
    () => web.window.history.replaceState(null, title, getBaseUri().resolve(tag).toString()),
  );
}

String? getCurrentWindowLocation() {
  return web.window.location.href;
}

Uri getBaseUri() {
  final baseElement = web.document.querySelector('base');
  if (baseElement != null) {
    final href = baseElement.getAttribute('href');
    if (href != null && href.isNotEmpty) {
      return Uri.base.resolve(href);
    }
  }
  return Uri.base;
}

void forceRefreshPage() {
  web.window.location.reload();
}
