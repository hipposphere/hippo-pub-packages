import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class SliverBodyList extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double? spacing;
  final bool isCentered;
  final ScrollController? scrollController;
  const SliverBodyList({
    super.key,
    this.maxWidth = 750,
    this.spacing,
    required this.child,
    this.isCentered = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final controller = scrollController ?? ScrollController();
    return Scrollbar(
      controller: controller,
      child: Align(
        alignment: isCentered ? Alignment.center : Alignment.topCenter,
        child: LimitedContainerPadded(
          maxWidth: maxWidth,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(controller: controller, child: child),
          ),
        ),
      ),
    );
  }
}

class SliverBodyListBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final double maxWidth;
  final double? spacing;
  final bool isCentered;
  final ScrollController? scrollController;
  const SliverBodyListBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing,
    this.maxWidth = 750,
    this.isCentered = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SuperSliverList.builder(
      itemBuilder: (context, index) {
        return itemBuilder(context, index);
      },
      itemCount: itemCount,
    );
  }
}

class SliverBodyListItems<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double? spacing;
  final List<T> items;
  final bool reverse;

  const SliverBodyListItems({
    super.key,
    this.spacing,
    required this.items,
    required this.itemBuilder,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return SuperSliverList.builder(
      itemBuilder: (context, index) {
        final item = items[reverse ? items.length - 1 - index : index];
        if (spacing != null) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing!),
            child: itemBuilder(context, item),
          );
        }
        return itemBuilder(context, item);
      },
      itemCount: items.length,
    );
  }
}
