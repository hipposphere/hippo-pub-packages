// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hippo_utils/file_picker.dart';
// ignore: unused_import
import 'package:hippo_utils/file_selector.dart';

class GetSingleFileModal {
  Future<PlatformFile?> open(BuildContext context) async {
    if (kIsWeb) {
      final selectedFile = await openFile();
      if (selectedFile == null) return null;
      return PlatformFile(
        name: selectedFile.name,
        size: await selectedFile.length(),
        bytes: await selectedFile.readAsBytes(),
      );
    }
    final pickedFiles =
        (await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
          withData: true,
        ))?.files ??
        [];
    final pickedFile = pickedFiles.firstOrNull;
    return pickedFile;
  }
}

class GetMultipleFilesModal {
  Future<List<PlatformFile>?> open(BuildContext context) async {
    final pickedFiles = (await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
      withData: true,
    ))?.files;
    return pickedFiles;
  }
}
