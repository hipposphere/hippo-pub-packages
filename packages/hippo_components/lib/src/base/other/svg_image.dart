import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hippo_components/hippo_components.dart';

class SvgImage extends StatelessWidget {
  final HippoAsset asset;
  final double? height;
  final double? width;
  final ColorFilter? colorFilter;
  const SvgImage({super.key, required this.asset, this.height, this.width, this.colorFilter});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(asset.path, height: height, width: width, colorFilter: colorFilter);
  }
}
