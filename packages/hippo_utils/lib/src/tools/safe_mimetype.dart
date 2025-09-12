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
