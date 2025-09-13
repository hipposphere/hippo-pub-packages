/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import '../models/web_functions_abstraction.dart';

class WebFunctionsImpl implements WebFunctionsAbstraction {
  @override
  Future<void> reload() {
    throw UnimplementedError();
  }

  @override
  Future<void> clearCacheStorageAndReload() {
    throw UnimplementedError();
  }

  @override
  void setPathUrlStrategy() {}
}
