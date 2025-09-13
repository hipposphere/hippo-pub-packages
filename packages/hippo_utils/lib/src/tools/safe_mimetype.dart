/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:mime/mime.dart';

String lookupSafeMimeType(String path) {
  final mimeType = lookupMimeType(path);
  if (mimeType == null) {
    // ignore: avoid_print
    print('Mime type not found for path: $path');
    return 'application/octet-stream';
  }
  return mimeType;
}
