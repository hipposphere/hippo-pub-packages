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
    () => web.window.history.replaceState(null, title, '${buildBaseUrl()}$tag'),
  );
}

String? getCurrentWindowLocation() {
  return web.window.location.href;
}

String buildBaseUrl() {
  final uri = Uri.parse(getCurrentWindowLocation()!);
  return uri.origin;
}

void forceRefreshPage() {
  web.window.location.reload();
}
