import 'package:flutter/material.dart';
import 'package:hippo_utils/hippo_utils.dart';

class HippoGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double borderOpacity;
  final double gradientStartOpacity;
  final double gradientEndOpacity;
  final VoidCallback? onTap;

  const HippoGradientCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = 16,
    this.borderOpacity = 0.1,
    this.gradientStartOpacity = 0.3,
    this.gradientEndOpacity = 0.1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHoveredSubject = DataSubject<bool>.seeded(false);
    final isPressedSubject = DataSubject<bool>.seeded(false);

    return CombinedDataSubjectBuilder<bool, bool>(
      subject1: isHoveredSubject,
      subject2: isPressedSubject,
      builder: (context, isHovered, isPressed) {
        final child = Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer.withValues(
                  alpha: isPressed
                      ? gradientStartOpacity * 1.5
                      : isHovered
                      ? gradientStartOpacity * 1.3
                      : gradientStartOpacity,
                ),
                colorScheme.primaryContainer.withValues(
                  alpha: isPressed
                      ? gradientEndOpacity * 1.5
                      : isHovered
                      ? gradientEndOpacity * 1.3
                      : gradientEndOpacity,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: colorScheme.primary.withValues(
                alpha: isPressed
                    ? borderOpacity * 3
                    : isHovered
                    ? borderOpacity * 2
                    : borderOpacity,
              ),
              width: isPressed
                  ? 2
                  : isHovered
                  ? 1.5
                  : 1,
            ),
          ),
          child: this.child,
        );

        if (onTap != null) {
          return MouseRegion(
            onEnter: (_) => isHoveredSubject.add(true),
            onExit: (_) => isHoveredSubject.add(false),
            child: GestureDetector(
              onTap: onTap,
              onTapDown: (_) => isPressedSubject.add(true),
              onTapUp: (_) => isPressedSubject.add(false),
              onTapCancel: () => isPressedSubject.add(false),
              child: AnimatedContainer(
                duration: Duration(milliseconds: isPressed ? 100 : 200),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()
                  // ignore: deprecated_member_use
                  ..scale(
                    isPressed
                        ? 0.98
                        : isHovered
                        ? 1.02
                        : 1.0,
                  ),
                child: child,
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
