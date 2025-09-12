import 'package:flutter/widgets.dart';
import 'package:hippo_components/hippo_components.dart';

class SliverColumn extends StatelessWidget {
  final EdgeInsets padding;
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final double maxWidth;
  final double spacing;
  const SliverColumn({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = 0,
    this.maxWidth = 800,
  });

  @override
  Widget build(BuildContext context) {
    return SliverChild(
      maxWidth: maxWidth,
      crossAxisAlignment: crossAxisAlignment,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        spacing: spacing,
        children: [
          SizedBox(width: double.infinity),
          ...children,
        ],
      ),
    );
  }
}
