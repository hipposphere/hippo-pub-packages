/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';
import 'package:hippo_components/src/base/themes/colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  final double dotSize;
  final double activeDotWidth;
  final double spacing;
  final Duration animationDuration;
  final Color? activeColor;
  final Color? inactiveColor;

  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
    this.dotSize = 8,
    this.activeDotWidth = 22,
    this.spacing = 8,
    this.animationDuration = const Duration(milliseconds: 200),
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final safeActiveIndex = activeIndex.clamp(0, count - 1).toInt();
    final resolvedActiveColor = activeColor ?? HippoColors.primary;
    final resolvedInactiveColor = inactiveColor ?? resolvedActiveColor.withValues(alpha: 0.25);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = safeActiveIndex == index;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: AnimatedContainer(
            key: ValueKey('onboarding_indicator_dot_$index'),
            duration: animationDuration,
            height: dotSize,
            width: isActive ? activeDotWidth : dotSize,
            decoration: BoxDecoration(
              color: isActive ? resolvedActiveColor : resolvedInactiveColor,
              borderRadius: BorderRadius.circular(dotSize),
            ),
          ),
        );
      }),
    );
  }
}
