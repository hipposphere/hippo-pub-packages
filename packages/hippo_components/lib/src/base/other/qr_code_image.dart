import 'package:flutter/material.dart';
import 'package:hippo_components/src/base/utils/components_context.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeImage extends StatelessWidget {
  final String data;
  final double? size;
  const QrCodeImage({super.key, required this.data, this.size});

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      size: size,
      eyeStyle: QrEyeStyle(
        color: context.onBrightness(light: Colors.black, dark: Colors.white),
        eyeShape: QrEyeShape.square,
      ),
      dataModuleStyle: QrDataModuleStyle(
        color: context.onBrightness(light: Colors.black, dark: Colors.white),
        dataModuleShape: QrDataModuleShape.circle,
      ),
    );
  }
}
