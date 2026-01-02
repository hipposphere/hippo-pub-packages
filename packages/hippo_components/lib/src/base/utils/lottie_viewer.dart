/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/widgets.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:lottie/lottie.dart';

class LottieViewer extends StatelessWidget {
  final HippoAsset asset;
  final double? width;
  final double? height;
  final bool? reverse;
  final bool? repeat;
  final Animation<double>? controller;
  const LottieViewer({
    super.key,
    this.width,
    this.height,
    this.reverse,
    this.repeat,
    this.controller,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return LottieBuilder(
      width: width,
      height: height,
      repeat: repeat,
      reverse: reverse,
      controller: controller,
      lottie: AssetLottie(asset.path),
    );
  }
}
