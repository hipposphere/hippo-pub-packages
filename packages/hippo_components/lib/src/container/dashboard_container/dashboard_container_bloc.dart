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
import 'package:hippo_components/src/container/dashboard_container/models/dashboard_route.dart';
import 'package:hippo_utils/hippo_utils.dart';

import 'models/dashboard_customizations.dart';

class DashboardContainerBloc<T> extends BlocBase {
  final List<DashboardRoute<T>> mobileRoutes;
  final List<GenericDashboardRoute<T>> desktopRoutes;
  final List<GenericDashboardRoute<T>> additionalDesktopRoutes;
  final DataSubject<T?> selectedValue;
  final DashboardCustomizations? customizations;

  final DataSubject<bool> sideNavigationExpanded;

  final desktopSideScrollController = ScrollController();
  final void Function(T newValue) onSelectedRoute;

  DashboardContainerBloc({
    this.customizations,
    required this.sideNavigationExpanded,
    required this.mobileRoutes,
    required this.desktopRoutes,
    this.additionalDesktopRoutes = const [],
    required this.selectedValue,
    required this.onSelectedRoute,
  });

  void selectRoute(dynamic route) {
    onSelectedRoute(route as T);
  }

  void changeSideNavigationExpanded(bool expanded) {
    sideNavigationExpanded.add(expanded);
  }

  @override
  void dispose() {}

  static DashboardContainerBloc of(BuildContext context) {
    return BlocProvider.of<DashboardContainerBloc>(context);
  }
}
