/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:typed_data';

class AndroidContentData {
  final String name;
  final String mimeType;
  final Uint8List bytes;

  AndroidContentData({required this.name, required this.mimeType, required this.bytes});
}
