import 'dart:typed_data';

class AndroidContentData {
  final String name;
  final String mimeType;
  final Uint8List bytes;

  AndroidContentData({required this.name, required this.mimeType, required this.bytes});
}
