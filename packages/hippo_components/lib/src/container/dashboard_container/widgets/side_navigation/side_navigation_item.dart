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
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hippo_components/hippo_components.dart';

class SideNavigationItem extends StatelessWidget {
  final GenericDashboardRoute route;
  final bool isSelected;
  final VoidCallback onTap;

  final double animationValue;
  const SideNavigationItem({
    super.key,
    required this.route,
    required this.isSelected,
    required this.onTap,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return SideNavigationItemTile(
      leading: Icon(
        switch (route) {
          DashboardRoute(selectedIcon: final selectedIcon, icon: final icon) =>
            isSelected ? selectedIcon : icon,
          CustomDashboardRoute() => route.icon,
        },
        color: isSelected ? Colors.blue : null,
        size: 24,
      ),
      collapbsedBadgeHint: route.badge != null,
      badge: route.badge,
      label: route.label(context),
      onTap: onTap,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
      textColor: isSelected ? Colors.blue : null,
      color: isSelected ? HippoColors.primaryLightened : null,
      animationValue: animationValue,
    );
  }
}

class SideNavigationItemTile extends StatelessWidget {
  final Widget leading;
  final String label;
  final bool collapbsedBadgeHint;
  final Widget? badge;
  final VoidCallback? onTap;
  final double animationValue;
  final EdgeInsets margin;
  final FontWeight? fontWeight;
  final Color? color, textColor;
  const SideNavigationItemTile({
    super.key,
    this.badge,
    this.collapbsedBadgeHint = false,
    this.fontWeight,
    this.color,
    this.textColor,
    this.margin = const EdgeInsets.only(left: 16.0, right: 16.0, top: 2.0, bottom: 2.0),
    required this.leading,
    required this.label,
    required this.onTap,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Semantics(
        label: label,
        excludeSemantics: true,
        child: Tappable(
          height: 50,
          tooltip: animationValue > 0.2 ? null : label,
          tooltipTipAnchor: Alignment.centerLeft,
          tooltipChildAnchor: Alignment.centerRight,
          color: color,
          onTap: onTap,
          builder: (context, isHovered, isFocused) => Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Padding(padding: const EdgeInsets.only(left: 2.0, right: 2.0), child: leading),
                    if (collapbsedBadgeHint && animationValue < 0.2)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: animationValue > 0.2
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Gap(4),
                            Flexible(
                              child: AutoSizeText(
                                label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: fontWeight,
                                  color: textColor,
                                  overflow: TextOverflow.fade,
                                  decoration: isHovered ? TextDecoration.underline : null,
                                  decorationColor: textColor,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ),
                if (animationValue == 1.0 && badge != null)
                  Padding(padding: EdgeInsets.only(left: 4), child: badge!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
