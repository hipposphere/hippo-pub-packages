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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class PlatformPageContainer extends StatelessWidget {
  final Widget? desktopTopBar;
  final String? title;
  final WidgetBuilder? titleBuilder;
  final List<Widget> actions;
  final Widget body;
  final PageHeaderBackAction? backAction;
  final Color? backgroundColor;
  final bool showNavBarBorder;
  const PlatformPageContainer({
    super.key,
    this.desktopTopBar,
    this.actions = const [],
    required this.title,
    this.titleBuilder,
    required this.body,
    this.backgroundColor,
    this.backAction = const PageHeaderBackAction(),
    this.showNavBarBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          if (kIsWeb == false &&
              (defaultTargetPlatform == TargetPlatform.macOS ||
                  defaultTargetPlatform == TargetPlatform.windows ||
                  defaultTargetPlatform == TargetPlatform.linux))
            _DesktopTopBar(
              backgroundColor: backgroundColor,
              child: desktopTopBar ?? SizedBox.shrink(),
            ),
          Expanded(
            child: CupertinoPageScaffold(
              backgroundColor: backgroundColor,
              navigationBar: PageHeader(
                backAction: backAction,
                title: title,
                titleBuilder: titleBuilder,
                actions: actions,
                border: showNavBarBorder ? kDefaultNavBarBorder : null,
                transitionBetweenRoutes: false,
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
          ),
        ],
      ),
    );
  }
}

class _DesktopTopBar extends StatelessWidget {
  final Color? backgroundColor;
  final Widget child;
  const _DesktopTopBar({this.backgroundColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? CupertinoTheme.of(context).scaffoldBackgroundColor,
      height: 30,
      width: double.infinity,
      child: child,
    );
  }
}
