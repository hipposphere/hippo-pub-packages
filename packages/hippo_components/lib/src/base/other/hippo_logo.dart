import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hippo_components/hippo_components.dart';

class HippoLogo extends StatelessWidget {
  final double radius;
  const HippoLogo({super.key, this.radius = 32});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(backgroundImage: LogoAssets.logo.toAssetImage(), radius: radius);
  }
}

class HippoLogoMark extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? color;
  const HippoLogoMark({super.key, this.height = 32, this.width, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: SvgPicture.asset(
        LogoAssets.logoMark.path,
        height: height,
        width: width,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      ),
    );
  }
}

class HippoBranding extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? color;
  const HippoBranding({super.key, this.height = 32, this.width, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: SvgPicture.asset(
        LogoAssets.branding.path,
        height: height,
        width: width,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      ),
    );
  }
}
