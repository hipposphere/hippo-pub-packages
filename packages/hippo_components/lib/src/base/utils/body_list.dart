import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class BodyList extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool isCentered;
  final ScrollController? scrollController;
  const BodyList({
    super.key,
    this.maxWidth = 750,
    required this.child,
    this.isCentered = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final controller = scrollController ?? ScrollController();
    return Scrollbar(
      controller: controller,
      child: LimitedContainerPadded(
        alignment: isCentered ? Alignment.center : Alignment.topCenter,
        maxWidth: maxWidth,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(controller: controller, child: child),
        ),
      ),
    );
  }
}

class BodyListBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final double maxWidth;
  final bool isCentered;
  final ScrollController? scrollController;
  const BodyListBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.maxWidth = 750,
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
            child: ListView.builder(
              controller: controller,
              itemBuilder: (context, index) {
                return itemBuilder(context, index);
              },
              itemCount: itemCount,
            ),
          ),
        ),
      ),
    );
  }
}

class BodyListItems<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T item) itemBuilder;
  final List<T> items;
  final double maxWidth;
  final bool isCentered;
  final ScrollController? scrollController;
  const BodyListItems({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.maxWidth = 750,
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
            child: ListView.builder(
              controller: controller,
              itemBuilder: (context, index) {
                final item = items[index];
                return itemBuilder(context, item);
              },
              itemCount: items.length,
            ),
          ),
        ),
      ),
    );
  }
}
