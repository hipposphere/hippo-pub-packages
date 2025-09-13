/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui_web';
import 'package:web/web.dart' as web;
import '../../../file_store.dart';
import '../common_file_store.dart';
import 'file_writer.dart';

FileStore getCommonFileStore(CommonFileStoreOptions options) {
  return WebFileStore(basePath: options.storePath);
}

class WebFileStore implements FileStore {
  @override
  final String basePath;

  WebFileStore({required this.basePath});

  /// Deletes the file at [path].
  @override
  Future<void> deleteFile(String path) async {
    // The FileSystemDirectoryHandle in the OPFS has a `removeEntry()` method
    // that can throw if the path doesn't exist. You could wrap it in a try/catch.
    final handle = await _getDirectoryHandle();
    try {
      await (handle.removeEntry(_buildPath(path)).toDart);
    } catch (e) {
      // If you want to silently ignore missing files, handle the error here:
      // if (e is DomException && e.name == 'NotFoundError') { /* ignore */ }
      rethrow;
    }
  }

  /// Deletes the folder at [path].
  @override
  Future<void> deleteFolder(String path) async {
    // The FileSystemDirectoryHandle in the OPFS has a `removeEntry()` method
    // that can throw if the path doesn't exist. You could wrap it in a try/catch.
    final handle = await _getDirectoryHandle();
    try {
      await (handle.removeEntry(_buildPath(path)).toDart);
    } catch (e) {
      // If you want to silently ignore missing files, handle the error here:
      // if (e is DomException && e.name == 'NotFoundError') { /* ignore */ }
      rethrow;
    }
  }

  /// Checks if the file at [path] exists.
  @override
  Future<bool> exists(String path) async {
    final directory = await _getDirectoryHandle();
    try {
      // Attempt to get the file handle; if it does not exist, it will throw.
      await (directory.getFileHandle(_buildPath(path)).toDart);
      return true;
    } catch (e) {
      // If the file doesn't exist, browsers typically throw a "NotFoundError".
      // You may want to inspect the error to ensure it’s the correct one.
      return false;
    }
  }

  @override
  Future<bool> existsFolder(String path) async {
    final handle = await _getDirectoryHandle();
    try {
      await (handle.getDirectoryHandle(_buildPath(path)).toDart);
      return true;
    } catch (e) {
      // If you want to silently ignore missing files, handle the error here:
      // if (e is DomException && e.name == 'NotFoundError') { /* ignore */ }
      rethrow;
    }
  }

  /// Reads binary data from the file at [path].
  @override
  Future<Uint8List?> readFileBinary(String path) async {
    try {
      final fileHandle = await _getFileHandle(path);
      final file = await (fileHandle.getFile().toDart);
      // `file.arrayBuffer()` returns a JS ArrayBuffer, convert it to Dart bytes.
      final arrayBuffer = await (file.arrayBuffer().toDart);
      // The easiest conversion is to use `JSTypedArray` or to copy the bytes:
      // If you have an IDL for `File` that returns the raw JS object,
      // you can do something like:
      //
      //   final typedArray = JSUint8Array.from(arrayBuffer);
      //   return typedArray.toDart;
      //
      // If your bindings differ, adapt accordingly.
      //
      // In many setups, you can do:
      return Uint8List.view(arrayBuffer.toDart);
    } catch (e) {
      // Handle "not found" or other errors. Return null if not found is acceptable.
      return null;
    }
  }

  /// Reads text from the file at [path].
  @override
  Future<String?> readFileString(String path) async {
    try {
      final fileHandle = await _getFileHandle(path);
      final file = await (fileHandle.getFile().toDart);
      // `file.text()` returns a JS String, convert it to Dart.
      final text = await (file.text().toDart);
      return text.toDart;
    } catch (e) {
      return null;
    }
  }

  /// Writes [data] (binary) to the file at [path].
  @override
  Future<void> writeFileBinary(String path, Uint8List data) async {
    // Done via a service worker as it is not allowed in the main thread.

    if (browser.isSafari) {
      await FileWriterService().writeFile(path, data);
    } else {
      // Writable is not yet supported in safari.
      final fileHandle = await _getFileHandle(path, createIfMissing: true);
      final writable = await (fileHandle.createWritable().toDart);
      await (writable.write(data.toJS).toDart);
      await (writable.close().toDart);
    }
  }

  /// Writes [data] (text) to the file at [path].
  @override
  Future<void> writeFileString(String path, String data) async {
    if (browser.isSafari) {
      FileWriterService().writeFile(path, utf8.encode(data));
    } else {
      // Writable is not yet supported in safari.
      final fileHandle = await _getFileHandle(path, createIfMissing: true);
      final writable = await (fileHandle.createWritable().toDart);
      await (writable.write(data.toJS).toDart);
      await (writable.close().toDart);
    }
  }

  /// Helper to get a directory handle in the origin private file system (OPFS).
  Future<web.FileSystemDirectoryHandle> _getDirectoryHandle() async {
    // The extension method on navigator.storage is:
    //    navigator.storage.getDirectory()
    // returns a FileSystemDirectoryHandle.
    final directoryHandle = await (web.window.navigator.storage.getDirectory().toDart);
    return directoryHandle;
  }

  /// Helper to get a file handle within [storePath].
  /// Pass [createIfMissing] = true to create the file if it doesn’t exist.
  Future<web.FileSystemFileHandle> _getFileHandle(
    String path, {
    bool createIfMissing = false,
  }) async {
    final directoryHandle = await _getDirectoryHandle();

    // If you want nested directories, you would need to recursively
    // call `getDirectoryHandle(subDirName, create:true)`. If [storePath]
    // includes subdirectories, you’d handle that here. For now, we assume
    // [storePath] is just a simple top-level name.
    //
    // Alternatively, if your storePath is just a prefix for the filename,
    // you can do it with `_buildPath(path)` in the file handle call:
    return _getNestedFileHandle(directoryHandle, path.split('/'));
  }

  Future<web.FileSystemFileHandle> _getNestedFileHandle(
    web.FileSystemDirectoryHandle root,
    List<String> pathSegments,
  ) async {
    web.FileSystemDirectoryHandle currentDir = root;

    // Traverse through subdirectories
    for (int i = 0; i < pathSegments.length - 1; i++) {
      currentDir = await currentDir
          .getDirectoryHandle(pathSegments[i], web.FileSystemGetDirectoryOptions(create: true))
          .toDart;
    }

    // The last segment is the file name
    return await currentDir
        .getFileHandle(pathSegments.last, web.FileSystemGetFileOptions(create: true))
        .toDart;
  }

  /// Builds a path by prefixing the [storePath] if desired.
  String _buildPath(String path) {
    return '$basePath/$path';
  }
}
