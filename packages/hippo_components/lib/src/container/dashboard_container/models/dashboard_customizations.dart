import 'package:flutter/widgets.dart';

typedef AnimatedDashboardItemBuilder =
    Widget Function(BuildContext context, AnimationController controller);

/// Dashboard customizations
/// Side navigation logo and bottom widgets, expands from 80 to 250 pixels
class DashboardCustomizations {
  final AnimatedDashboardItemBuilder? logoBuilder;
  final AnimatedDashboardItemBuilder? searchBuilder;
  final AnimatedDashboardItemBuilder? bottomBuilder;
  final AnimatedDashboardItemBuilder? desktopRoutesListBottomBuilder;
  final WidgetBuilder? mobileTopBuilder;

  const DashboardCustomizations({
    this.logoBuilder,
    this.searchBuilder,
    this.bottomBuilder,
    this.desktopRoutesListBottomBuilder,
    this.mobileTopBuilder,
  });
}
