import 'package:flutter/widgets.dart';
import 'package:hippo_components/hippo_components.dart';

class SliverChild extends StatelessWidget {
  final EdgeInsets padding;
  final double maxWidth;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;
  const SliverChild({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: LimitedContainerPadded(
        padding: padding,
        maxWidth: maxWidth,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            SizedBox(width: double.infinity),
            child,
          ],
        ),
      ),
    );
  }
}
