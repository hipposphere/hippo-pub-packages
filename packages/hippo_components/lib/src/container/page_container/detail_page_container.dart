/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class DetailPageContainer extends StatelessWidget {
  final String title;
  final Widget leading;
  final Widget? appBarBottom;
  final Widget child;
  final List<Widget> actions;
  final Color? backgroundColor;
  final PageHeaderBackAction backAction;
  const DetailPageContainer({
    super.key,
    required this.title,
    required this.leading,
    required this.child,
    this.appBarBottom,
    this.backgroundColor,
    this.actions = const [],
    this.backAction = const PageHeaderBackAction(),
  });

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: title,
      actions: actions,
      backAction: backAction,
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          if (appBarBottom != null) appBarBottom!,
          Expanded(
            child: Row(
              children: [
                leading,
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
