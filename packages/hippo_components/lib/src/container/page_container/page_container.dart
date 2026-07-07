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
              padding: EdgeInsets.only(top: _safeTopPadding(context)),
              child: body,
            );
          },
        ),
      ),
    );
  }
}

double _safeTopPadding(BuildContext context) {
  final topPadding = MediaQuery.paddingOf(context).top;
  return topPadding < 0 ? 0 : topPadding;
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

class TabbedPageContainer extends StatefulWidget {
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
    this.backAction = const PageHeaderBackAction(),
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
  State<TabbedPageContainer> createState() => _TabbedPageContainerState();
}

class _TabbedPageContainerState extends State<TabbedPageContainer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = _createTabController(widget.initialTabIndex);
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void didUpdateWidget(covariant TabbedPageContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      final nextIndex = _tabController.index.clamp(0, _lastValidTabIndex);
      _tabController
        ..removeListener(_handleTabChanged)
        ..dispose();
      _tabController = _createTabController(nextIndex)..addListener(_handleTabChanged);
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    super.dispose();
  }

  TabController _createTabController(int initialIndex) {
    return TabController(
      length: widget.tabs.length,
      initialIndex: initialIndex.clamp(0, _lastValidTabIndex),
      vsync: this,
    );
  }

  int get _lastValidTabIndex => widget.tabs.isEmpty ? 0 : widget.tabs.length - 1;

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) {
      widget.onTabChanged?.call(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final systemPadding = MediaQuery.paddingOf(context);
    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        child: CupertinoPageScaffold(
          backgroundColor: widget.backgroundColor,
          child: Stack(
            children: [
              Positioned(
                top: 90 + systemPadding.top,
                left: 0,
                right: 0,
                bottom: 0,
                child: TabBarView(
                  controller: _tabController,
                  clipBehavior: Clip.none,
                  children: widget.tabViews,
                ),
              ),
              Column(
                children: [
                  PageHeaderDragRegion(
                    onPanStart: widget.onHeaderPanStart,
                    child: PageHeader(
                      title: widget.title,
                      backAction: widget.backAction,
                      actions: widget.actions,
                      transitionBetweenRoutes: widget.transitionBetweenRoutes,
                      border: null,
                    ),
                  ),
                  CupertinoBlurContainer(
                    child: TabBar(
                      controller: _tabController,
                      tabs: widget.tabs,
                      isScrollable: true,
                      tabAlignment: TabAlignment.startOffset,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
