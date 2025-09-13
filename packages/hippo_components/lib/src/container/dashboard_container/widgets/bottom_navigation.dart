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
import 'package:hippo_utils/hippo_utils.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = DashboardContainerBloc.of(context);

    final bottomPadding = (MediaQuery.paddingOf(context).bottom * 2 / 3);
    return CupertinoBlurContainer(
      height: 56 + bottomPadding,
      child: DataSubjectBuilder(
        subject: bloc.selectedValue,
        builder: (context, selectedValue) {
          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: FocusTraversalGroup(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Gap(4),
                  for (final route in bloc.mobileRoutes)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 2.0,
                          right: 2.0,
                          top: 2.0,
                          bottom: 2.0,
                        ),
                        child: SimpleTappable(
                          onTap: () {
                            bloc.selectRoute(route.value);
                          },
                          child: _Item(route: route, selected: selectedValue == route.value),
                        ),
                      ),
                    ),
                  Gap(4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final DashboardRoute route;
  final bool selected;
  const _Item({required this.route, required this.selected});

  @override
  Widget build(BuildContext context) {
    final label = route.label(context);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.all(2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? route.selectedIcon : route.icon,
              size: 24,
              color: selected ? HippoColors.primary : null,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? HippoColors.primary : null,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
