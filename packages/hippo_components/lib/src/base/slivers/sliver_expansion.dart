import 'package:flutter/widgets.dart';

class SliverExpansion extends StatelessWidget {
  final Widget Function(BuildContext context, bool isExpanded, VoidCallback onTap)
  mainSliverBuilder;
  final List<Widget> Function(BuildContext context)? expandedSliversBuilder;

  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const SliverExpansion({
    super.key,
    required this.mainSliverBuilder,
    required this.expandedSliversBuilder,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final expansionState = ValueNotifier<bool>(initiallyExpanded);
    return ValueListenableBuilder(
      valueListenable: expansionState,
      builder: (context, expanded, _) {
        return SliverMainAxisGroup(
          slivers: [
            mainSliverBuilder(context, expanded, () {
              expansionState.value = !expansionState.value;
              if (onExpansionChanged != null) {
                onExpansionChanged!(expansionState.value);
              }
            }),
            if (expanded && expandedSliversBuilder != null) ...expandedSliversBuilder!(context),
          ],
        );
      },
    );
  }
}
