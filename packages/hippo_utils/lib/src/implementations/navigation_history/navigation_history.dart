/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'impl/stub.dart' if (dart.library.js_interop) 'impl/web.dart' as impl;

void addWebNavigationHistory(String title, String tag) {
  impl.addWebHistoryElementImplementation(title, tag);
}

Uri getBaseUri() {
  return impl.getBaseUri();
}

String? getCurrentWindowLocation() {
  return impl.getCurrentWindowLocation();
}
