import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class ModalTappable extends StatelessWidget {
  final String? tooltip;
  final VoidCallback? onTap;
  final Widget child;
  const ModalTappable({super.key, this.tooltip, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      tooltip: tooltip,
      margin: const EdgeInsets.all(16.0),
      onTap: onTap,
      child: child,
    );
  }
}
