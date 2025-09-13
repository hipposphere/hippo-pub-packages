/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:ui';
import 'package:flutter/cupertino.dart';

class CupertinoBlur extends StatelessWidget {
  final Widget child;
  final double sigma;
  final TileMode tileMode;
  const CupertinoBlur({
    super.key,
    this.sigma = 10,
    this.tileMode = TileMode.clamp,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: tileMode),
      child: child,
    );
  }
}

class CupertinoBlurContainer extends StatelessWidget {
  final double? height, width;
  final Widget child;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  const CupertinoBlurContainer({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.color,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: borderRadius,
      child: CupertinoBlur(
        child: Container(
          height: height,
          width: width,
          color: color ?? CupertinoTheme.of(context).barBackgroundColor,
          child: child,
        ),
      ),
    );
  }
}

class GlassyBlurContainer extends StatelessWidget {
  final double? height, width;
  final Widget child;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final double alpha;
  const GlassyBlurContainer({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.color,
    this.borderRadius = BorderRadius.zero,
    this.alpha = 0.7,
  });
  @override
  Widget build(BuildContext context) {
    return CupertinoBlurContainer(
      height: height,
      width: width,
      borderRadius: borderRadius,
      color: CupertinoTheme.of(context).barBackgroundColor.withValues(alpha: alpha),
      child: child,
    );
  }
}
