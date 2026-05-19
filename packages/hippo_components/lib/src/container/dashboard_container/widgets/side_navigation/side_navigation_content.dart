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
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

class SideNavigationContent extends StatelessWidget {
  final AnimationController animationController;
  final AnimatedDashboardItemBuilder? desktopRoutesListBottomBuilder;
  const SideNavigationContent({
    super.key,
    required this.animationController,
    this.desktopRoutesListBottomBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = DashboardContainerBloc.of(context);
    final desktopRoutes = bloc.desktopRoutes;
    final additionalDesktopRoutes = bloc.additionalDesktopRoutes;
    final animationValue = animationController.value;

    return DataSubjectBuilder(
      subject: bloc.selectedValue,
      builder: (context, selectedValue) {
        return CustomScrollView(
          controller: bloc.desktopSideScrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _RoutesColumn(
                bloc: bloc,
                routes: desktopRoutes,
                selectedValue: selectedValue,
                animationValue: animationValue,
              ),
            ),
            SliverGap(16),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RoutesColumn(
                      bloc: bloc,
                      routes: additionalDesktopRoutes,
                      selectedValue: selectedValue,
                      animationValue: animationValue,
                    ),
                    if (desktopRoutesListBottomBuilder != null)
                      desktopRoutesListBottomBuilder!(context, animationController),
                    Gap(16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RoutesColumn<T> extends StatelessWidget {
  final DashboardContainerBloc bloc;
  final List<GenericDashboardRoute<T>> routes;
  final T selectedValue;
  final double animationValue;
  const _RoutesColumn({
    required this.bloc,
    required this.routes,
    required this.selectedValue,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final route in routes)
          SideNavigationItem(
            route: route,
            isSelected: switch (route) {
              DashboardRoute() => selectedValue == route.value,
              CustomDashboardRoute() => false,
            },
            onTap: () {
              switch (route) {
                case DashboardRoute<T>():
                  bloc.selectRoute(route.value);
                  break;
                case CustomDashboardRoute():
                  route.onTap != null ? route.onTap!(context) : () {};
                  break;
              }
            },
            animationValue: animationValue,
          ),
      ],
    );
  }
}
