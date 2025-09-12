import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_components/src/container/dashboard_container/widgets/side_navigation/side_navigation_content.dart';
import 'package:hippo_utils/hippo_utils.dart';

class SideNavigation extends StatefulWidget {
  final DataSubject<bool> sideNavigationExpanded;
  const SideNavigation({super.key, required this.sideNavigationExpanded});

  @override
  State<SideNavigation> createState() => _SideNavigationState();
}

class _SideNavigationState extends State<SideNavigation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool sideNavigationExpanded;

  StreamSubscription? _subscription;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _controller.value = widget.sideNavigationExpanded.value ? 1 : 0;
    _subscription = widget.sideNavigationExpanded.stream.listen((expanded) {
      if (expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final systemPadding = MediaQuery.paddingOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final width = 80 + 170 * _controller.value;

        return Container(
          color: context.onBrightness(
            light: HippoColors.sideBarLight,
            dark: HippoColors.sideBarDark,
          ),
          width: width,
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(top: systemPadding.top),
            child: _Content(controller: _controller),
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  final AnimationController controller;
  const _Content({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bloc = DashboardContainerBloc.of(context);

    final logoBuilder = bloc.customizations?.logoBuilder;
    final bottomBuilder = bloc.customizations?.bottomBuilder;
    final desktopRoutesListBottomBuilder = bloc.customizations?.desktopRoutesListBottomBuilder;
    final searchBuilder = bloc.customizations?.searchBuilder;

    return FocusTraversalGroup(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(16),
          Padding(padding: const EdgeInsets.only(left: 16.0), child: _MenuButton()),
          Gap(24),
          if (logoBuilder != null)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: logoBuilder(context, controller),
            ),
          Gap(12),
          if (searchBuilder != null) searchBuilder(context, controller),
          Gap(12),
          Expanded(
            child: Scrollbar(
              controller: bloc.desktopSideScrollController,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SideNavigationContent(
                  animationController: controller,
                  desktopRoutesListBottomBuilder: desktopRoutesListBottomBuilder,
                ),
              ),
            ),
          ),
          if (bottomBuilder != null) ...[bottomBuilder(context, controller), Gap(16)],
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    final bloc = DashboardContainerBloc.of(context);
    return DataSubjectBuilder(
      subject: bloc.sideNavigationExpanded,
      builder: (context, sideNavigationExpanded) {
        return SimpleTappable(
          onTap: () {
            bloc.changeSideNavigationExpanded(!sideNavigationExpanded);
          },
          tooltipChildAnchor: Alignment.centerRight,
          tooltipTipAnchor: Alignment.centerLeft,
          margin: const EdgeInsets.all(8.0),
          tooltip: sideNavigationExpanded
              ? context.cl.dashboard_menu_collapse
              : context.cl.dashboard_menu_expand,
          child: Icon(CupertinoIcons.bars),
        );
      },
    );
  }
}
