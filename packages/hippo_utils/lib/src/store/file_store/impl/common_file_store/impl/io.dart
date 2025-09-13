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
import 'dart:io' as io;
import '../../../file_store.dart';
import '../common_file_store.dart';

FileStore getCommonFileStore(CommonFileStoreOptions options) {
  return IOFileStore(basePath: options.storePath);
}

class IOFileStore implements FileStore {
  @override
  final String basePath;

  IOFileStore({required this.basePath})
    : assert(basePath.isNotEmpty),
      assert(basePath.endsWith('/') == false);

  @override
  Future<void> deleteFile(String path) {
    return _buildFile(path).delete();
  }

  @override
  Future<void> deleteFolder(String path) {
    return _buildDirectory(path).delete(recursive: true);
  }

  @override
  Future<bool> exists(String path) {
    return _buildFile(path).exists();
  }

  @override
  Future<Uint8List?> readFileBinary(String path) {
    return _buildFile(path).readAsBytes();
  }

  @override
  Future<String?> readFileString(String path) {
    return _buildFile(path).readAsString();
  }

  @override
  Future<void> writeFileBinary(String path, Uint8List data) async {
    final file = _buildFile(path);
    await file.create(recursive: true);
    await file.writeAsBytes(data);
  }

  @override
  Future<void> writeFileString(String path, String data) async {
    final file = _buildFile(path);
    await file.create(recursive: true);
    await file.writeAsString(data);
  }

  io.File _buildFile(String path) {
    return io.File(_buildPath(path));
  }

  io.Directory _buildDirectory(String path) {
    return io.Directory(_buildPath(path));
  }

  String _buildPath(String path) {
    return '$basePath/$path';
  }

  @override
  Future<bool> existsFolder(String path) {
    return _buildDirectory(path).exists();
  }
}
