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
import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class PageContainer extends StatelessWidget {
  final String? title;
  final WidgetBuilder? titleBuilder;
  final List<Widget> actions;
  final Widget body;
  final PageHeaderBackAction? backAction;
  final Color? backgroundColor;
  final bool showNavBarBorder;
  final GestureDragStartCallback? onHeaderPanStart;
  const PageContainer({
    super.key,
    this.actions = const [],
    required this.title,
    this.titleBuilder,
    required this.body,
    this.backgroundColor,
    this.backAction = const PageHeaderBackAction(),
    this.showNavBarBorder = true,
    this.onHeaderPanStart,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar: PageHeaderDragRegion(
          onPanStart: onHeaderPanStart,
          child: PageHeader(
            backAction: backAction,
            title: title,
            titleBuilder: titleBuilder,
            actions: actions,
            border: showNavBarBorder ? kDefaultNavBarBorder : null,
            transitionBetweenRoutes: false,
          ),
        ),
        child: Builder(
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
              child: body,
            );
          },
        ),
      ),
    );
  }
}

class PageContainerLargeTitle extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final PageHeaderBackAction? backAction;
  final List<Widget> slivers;
  final bool transitionBetweenRoutes;
  const PageContainerLargeTitle({
    super.key,
    this.actions = const [],
    required this.title,
    required this.slivers,
    this.backAction = const PageHeaderBackAction(),
    this.transitionBetweenRoutes = true,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          PageHeaderLargeTitleSliver(
            title: title,
            actions: actions,
            backAction: backAction,
            transitionBetweenRoutes: transitionBetweenRoutes,
          ),
          ...slivers,
        ],
      ),
    );
  }
}

class TabbedPageContainer extends StatelessWidget {
  final String title;
  final PageHeaderBackAction? backAction;
  final List<Widget> actions;
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final bool transitionBetweenRoutes;
  final int initialTabIndex;
  final Function(int index)? onTabChanged;
  final Color? backgroundColor;
  final GestureDragStartCallback? onHeaderPanStart;
  const TabbedPageContainer({
    super.key,
    this.actions = const [],
    this.backAction,
    required this.title,
    required this.tabs,
    required this.tabViews,
    this.transitionBetweenRoutes = true,
    this.initialTabIndex = 0,
    this.onTabChanged,
    this.backgroundColor,
    this.onHeaderPanStart,
  });

  @override
  Widget build(BuildContext context) {
    final systemPadding = MediaQuery.paddingOf(context);
    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        child: CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          child: DefaultTabController(
            initialIndex: initialTabIndex,
            length: tabs.length,
            child: Builder(
              builder: (context) {
                if (onTabChanged != null) {
                  final controller = DefaultTabController.of(context);
                  controller.addListener(() {
                    if (controller.indexIsChanging) {
                      onTabChanged!(controller.index);
                    }
                  });
                }
                return Stack(
                  children: [
                    Positioned(
                      top: 90 + systemPadding.top,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: TabBarView(clipBehavior: Clip.none, children: tabViews),
                    ),
                    Column(
                      children: [
                        PageHeaderDragRegion(
                          onPanStart: onHeaderPanStart,
                          child: PageHeader(
                            title: title,
                            backAction: backAction,
                            actions: actions,
                            transitionBetweenRoutes: transitionBetweenRoutes,
                            border: null,
                          ),
                        ),
                        CupertinoBlurContainer(
                          child: TabBar(
                            tabs: tabs,
                            isScrollable: true,
                            tabAlignment: TabAlignment.startOffset,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
