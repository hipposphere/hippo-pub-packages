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
      style: switch (type) {
        BadgeType.primary => FBadgeStyle.primary(),
        BadgeType.secondary => FBadgeStyle.secondary(),
        BadgeType.outline => FBadgeStyle.outline(),
        BadgeType.destructive => FBadgeStyle.destructive(),
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
