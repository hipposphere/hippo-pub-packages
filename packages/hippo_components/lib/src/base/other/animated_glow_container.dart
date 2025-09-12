import 'package:flutter/material.dart';
import 'package:glow_container/glow_container.dart';

class AnimatedGlowContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool enabled;
  const AnimatedGlowContainer({
    super.key,
    this.enabled = true,
    this.borderRadius = 8.0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }
    return GlowContainer(
      gradientColors: [Colors.blue, Colors.red],
      showAnimatedBorder: true,
      containerOptions: ContainerOptions(borderRadius: borderRadius),
      child: child,
    );
  }
}
