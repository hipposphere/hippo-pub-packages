/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';
import 'package:hippo_components/hippo_components.dart';

enum BadgeType { primary, secondary, outline, destructive }

class SmallBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  const SmallBadge({super.key, this.type = BadgeType.primary, required this.label});

  @override
  Widget build(BuildContext context) {
    return FBadge(
      variant: switch (type) {
        BadgeType.primary => null,
        BadgeType.secondary => .secondary,
        BadgeType.outline => .outline,
        BadgeType.destructive => .destructive,
      },
      child: Text(label),
    );
  }
}

class NewBadge extends StatelessWidget {
  const NewBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallBadge(label: context.cl.common_new);
  }
}

class UpdateBadge extends StatelessWidget {
  const UpdateBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallBadge(label: context.cl.common_update);
  }
}

class InfoBadge extends StatelessWidget {
  const InfoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallBadge(label: context.cl.common_info);
  }
}
