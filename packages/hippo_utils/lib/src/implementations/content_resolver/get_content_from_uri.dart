/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:hippo_utils/cross_file.dart';
import 'impl/stub.dart' if (dart.library.io) 'impl/io.dart' as impl;
import 'models/android_content_data.dart';

/// Only available on Android.
/// Resolves the content from the given [uri] and returns an [XFile].
Future<AndroidContentData> getContentFromUri(Uri uri) {
  return impl.getContentFromUri(uri);
}
