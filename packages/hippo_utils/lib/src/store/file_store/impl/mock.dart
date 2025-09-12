import 'dart:convert';
import 'dart:typed_data';

import 'package:hippo_utils/src/store/store.dart';

class MockFileStore implements FileStore {
  @override
  final String basePath;
  final Map<String, Uint8List> dataMap;

  MockFileStore({required this.basePath, Map<String, Uint8List>? initialDataMap})
    : dataMap = initialDataMap ?? {};

  @override
  Future<void> deleteFile(String path) async {
    dataMap.remove(path);
  }

  @override
  Future<bool> exists(String path) async {
    return dataMap.containsKey(path);
  }

  @override
  Future<Uint8List?> readFileBinary(String path) async {
    return dataMap[path];
  }

  @override
  Future<String?> readFileString(String path) async {
    final data = dataMap[path];
    if (data == null) {
      return null;
    }
    return utf8.decode(data);
  }

  @override
  Future<void> writeFileBinary(String path, Uint8List data) async {
    dataMap[path] = data;
  }

  @override
  Future<void> writeFileString(String path, String data) async {
    dataMap[path] = utf8.encode(data);
  }

  @override
  Future<void> deleteFolder(String path) {
    // In a mock implementation, we can just clear all entries that start with the path
    dataMap.removeWhere((key, _) => key.startsWith(path));
    return Future.value();
  }

  @override
  Future<bool> existsFolder(String path) {
    // In a mock implementation, we can assume a folder exists if any file starts with the path
    return Future.value(dataMap.keys.any((key) => key.startsWith(path)));
  }
}
