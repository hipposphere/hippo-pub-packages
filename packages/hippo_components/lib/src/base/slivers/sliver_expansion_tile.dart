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
import 'package:hippo_components/hippo_components.dart';

class SliverExpansionTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final List<Widget>? slivers;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final Widget? trailing;
  final TileControlAffinity controlAffinity;
  const SliverExpansionTile({
    super.key,
    this.title,
    this.subtitle,
    this.slivers,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.trailing,
    this.controlAffinity = TileControlAffinity.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SliverExpansion(
      mainSliverBuilder: (context, expanded, onTap) {
        return SliverChild(
          child: Tile(
            leading: controlAffinity == TileControlAffinity.leading
                ? Icon(expanded ? Icons.expand_less : Icons.expand_more)
                : null,
            title: title,
            subtitle: subtitle,
            isFirst: true,
            isLast: true,
            onTap: onTap,
            trailing: controlAffinity == TileControlAffinity.trailing
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (trailing != null)
                        Padding(padding: EdgeInsets.only(right: 8), child: trailing!),
                      Icon(expanded ? Icons.expand_less : Icons.expand_more),
                    ],
                  )
                : trailing,
          ),
        );
      },
      expandedSliversBuilder: slivers == null
          ? null
          : (context) {
              return slivers!;
            },
    );
  }
}
