import 'package:flutter/material.dart';

class LimitedContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double? maxHeight;

  const LimitedContainer({super.key, required this.child, this.maxWidth = 800, this.maxHeight});
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight ?? double.infinity),
      child: child,
    );
  }
}

class LimitedContainerPadded extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double? maxHeight;
  final Alignment alignment;
  final EdgeInsets padding;

  const LimitedContainerPadded({
    super.key,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.maxWidth = 800,
    this.maxHeight,
  });
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight ?? double.infinity),
          child: child,
        ),
      ),
    );
  }
}
