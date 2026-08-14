import 'dart:io';

abstract interface class LinuxSystemFileSystem {
  Future<String> readText(String path);
  Future<List<String>> listDirectoryNames(String path);
}

final class IoLinuxSystemFileSystem implements LinuxSystemFileSystem {
  const IoLinuxSystemFileSystem();

  @override
  Future<String> readText(String path) => File(path).readAsString();

  @override
  Future<List<String>> listDirectoryNames(String path) async => Directory(path)
      .list()
      .map((entity) => entity.uri.pathSegments.where((segment) => segment.isNotEmpty).last)
      .toList();
}
