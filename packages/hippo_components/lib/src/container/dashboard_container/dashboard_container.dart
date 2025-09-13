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

import 'widgets/bottom_navigation.dart';
import 'widgets/side_navigation.dart';

/// A Wrapper for the MediHippo Dashboard.
/// Requires to be wrapped with a [DashboardContainerBloc].
class DashboardContainer extends StatelessWidget {
  final Function(BuildContext context, bool isDesktop) builder;
  const DashboardContainer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      builder: (context, isDesktop) {
        if (isDesktop) {
          return DesktopDashboard(child: builder(context, true));
        } else {
          return MobileDashboard(child: builder(context, false));
        }
      },
    );
  }
}

class MobileDashboard extends StatelessWidget {
  final Widget child;
  const MobileDashboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bloc = DashboardContainerBloc.of(context);
    final topBuilder = bloc.customizations?.mobileTopBuilder;
    return Column(
      verticalDirection: VerticalDirection.up,
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
            body: topBuilder != null
                ? MediaQuery.removePadding(context: context, removeTop: true, child: child)
                : child,
            bottomNavigationBar: BottomNavigation(),
          ),
        ),
        if (topBuilder != null) topBuilder(context),
      ],
    );
  }
}

class DesktopDashboard extends StatelessWidget {
  final Widget child;
  const DesktopDashboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bloc = DashboardContainerBloc.of(context);
    return Scaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          SideNavigation(sideNavigationExpanded: bloc.sideNavigationExpanded),
          VerticalDivider(width: 0.5),
          Expanded(child: child),
        ],
      ),
    );
  }
}
