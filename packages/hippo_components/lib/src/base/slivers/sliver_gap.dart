import 'package:flutter/widgets.dart';
import 'package:hippo_components/hippo_components.dart';

class SliverGap extends StatelessWidget {
  final double gap;
  const SliverGap(this.gap, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Gap(gap));
  }
}
