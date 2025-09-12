import 'package:content_resolver/content_resolver.dart';

import '../models/android_content_data.dart';

Future<AndroidContentData> getContentFromUri(Uri uri) async {
  // Implement your logic to get the XFile from the Uri
  final content = await ContentResolver.resolveContent(uri.toString());

  return AndroidContentData(
    name: content.fileName!,
    mimeType: content.mimeType ?? 'application/octet-stream',
    bytes: content.data,
  );
}
