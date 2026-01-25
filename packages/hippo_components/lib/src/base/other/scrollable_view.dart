import 'package:flutter/material.dart';
import 'package:hippo_utils/hippo_utils.dart';

/// A scrollable view that uses a [CustomScrollView] to display a list of slivers.
/// It automatically applies a scrollbar on desktop platforms.
///
class ScrollableView extends StatelessWidget {
  final List<Widget> slivers;
  final bool reverse;
  final ScrollController? controller;
  final Axis scrollDirection;
  final double? scrollbarThickness;
  final bool? scrollbarThumbVisibility;
  final bool? scrollbarTrackVisibility;

  const ScrollableView({
    super.key,
    required this.slivers,
    this.controller,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.scrollbarThumbVisibility = true,
    this.scrollbarTrackVisibility = true,
    this.scrollbarThickness,
  });

  @override
  Widget build(BuildContext context) {
    if (isWebOrDesktopPlatform) {
      final scrollController = controller;

      return Scrollbar(
        controller: scrollController,
        thumbVisibility: scrollbarThumbVisibility,
        trackVisibility: scrollbarTrackVisibility,
        thickness: scrollbarThickness,
        child: CustomScrollView(
          slivers: slivers,
          reverse: reverse,
          controller: scrollController,
          scrollDirection: scrollDirection,
          scrollBehavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        ),
      );
    }

    return CustomScrollView(
      slivers: slivers,
      reverse: reverse,
      controller: controller,
      scrollDirection: scrollDirection,
    );
  }
}
