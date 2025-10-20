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
import 'package:path/path.dart';

abstract class FileStore {
  String get basePath;
  Future<bool> exists(String path);

  Future<bool> existsFolder(String path);

  Future<String?> readFileString(String path);

  Future<Uint8List?> readFileBinary(String path);

  Future<void> writeFileString(String path, String data);

  Future<void> writeFileBinary(String path, Uint8List data);

  Future<void> deleteFile(String path);

  Future<void> deleteFolder(String path);

  Future<void> createFolderRecursively(String path);

  String getAbsolutePath(String path) {
    return join(basePath, path);
  }
}
