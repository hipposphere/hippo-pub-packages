/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/cupertino.dart';
import 'package:hippo_components/hippo_components.dart';

class DashboardContent extends StatelessWidget {
  final String? title;
  final WidgetBuilder? titleBuilder;
  // By default null, so there is no back button visible
  final PageHeaderBackAction? backAction;
  final List<Widget> actions;
  final List<Widget> slivers;
  final bool showNavBarBorder;
  const DashboardContent({
    super.key,
    required this.title,
    this.titleBuilder,
    this.backAction,
    this.showNavBarBorder = true,
    this.actions = const [],
    this.slivers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: CustomScrollView(
        clipBehavior: Clip.none,
        slivers: [
          PageHeaderLargeTitleSliver(
            backAction: backAction,
            title: title,
            titleBuilder: titleBuilder,
            actions: actions,
            transitionBetweenRoutes: false,
            border: showNavBarBorder ? kDefaultNavBarBorder : null,
          ),
          ...slivers,
        ],
      ),
    );
  }
}

class DashboardContentTabbed extends StatelessWidget {
  final String title;
  // By default null, so there is no back button visible
  final PageHeaderBackAction? backAction;
  final List<Widget> actions;
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final int initialTabIndex;

  const DashboardContentTabbed({
    super.key,
    required this.title,
    this.backAction,
    this.actions = const [],
    required this.tabs,
    required this.tabViews,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TabbedPageContainer(
      title: title,
      tabs: tabs,
      tabViews: tabViews,
      actions: actions,
      backAction: backAction,
      transitionBetweenRoutes: false,
      initialTabIndex: initialTabIndex,
    );
  }
}
