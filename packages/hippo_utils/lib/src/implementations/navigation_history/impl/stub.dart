/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
void addWebHistoryElementImplementation(String title, String tag) {}

String? getCurrentWindowLocation() {
  return null;
}

String buildBaseUrl() {
  final uri = Uri.parse(getCurrentWindowLocation()!);
  return uri.origin;
}

void forceRefreshPage() {}
