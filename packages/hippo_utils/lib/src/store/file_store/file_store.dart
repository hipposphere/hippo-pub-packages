import 'dart:typed_data';

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
}
