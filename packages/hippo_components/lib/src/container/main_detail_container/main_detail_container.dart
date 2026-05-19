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
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_utils/hippo_utils.dart';

class MainDetailContainerController<T> {
  final selectedItemSubject = DataSubject<T?>.seeded(null);
  final isDetailPageOpenedAsRoute = DataSubject.seeded(false);
}

class MainDetailContainer<T> extends StatefulWidget {
  final String title;
  final Widget Function(BuildContext context, ValueChanged<T> onSelect) mainBuilder;
  final String Function(BuildContext context, T item) detailTitleBuilder;
  final Widget Function(BuildContext context, T item) detailBodyBuilder;

  final MainDetailContainerController<T> controller;

  final double breakpoint;

  factory MainDetailContainer({
    required String title,
    required Widget Function(BuildContext context, ValueChanged<T> onSelect) mainBuilder,
    required String Function(BuildContext context, T item) detailTitleBuilder,
    required Widget Function(BuildContext context, T item) detailBodyBuilder,
  }) {
    return MainDetailContainer._(
      controller: MainDetailContainerController<T>(),
      title: title,
      mainBuilder: mainBuilder,
      detailTitleBuilder: detailTitleBuilder,
      detailBodyBuilder: detailBodyBuilder,
    );
  }

  const MainDetailContainer._({
    super.key,
    required this.controller,
    required this.title,
    required this.mainBuilder,
    required this.detailTitleBuilder,
    required this.detailBodyBuilder,
    this.breakpoint = 750,
  });

  @override
  State<MainDetailContainer<T>> createState() => _MainDetailContainerState<T>();
}

class _MainDetailContainerState<T> extends State<MainDetailContainer<T>> {
  MainDetailContainerController<T> get controller => widget.controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool isWideScreen = MediaQuery.of(context).size.width > widget.breakpoint;
      final selectedItem = controller.selectedItemSubject.value;
      final isDetailPageOpenedAsRoute = controller.isDetailPageOpenedAsRoute.value;

      // Automatically pop the detail route if screen becomes wide enough.
      if (isWideScreen && isDetailPageOpenedAsRoute) {
        Navigator.of(context).pop();
      }

      // Automatically push the detail page if switching to mobile view with an item selected.
      if (!isWideScreen && selectedItem != null && !isDetailPageOpenedAsRoute) {
        _openDetailPage<T>(
          context: context,
          controller: controller,
          item: selectedItem,
          detailTitleBuilder: widget.detailTitleBuilder,
          detailBodyBuilder: widget.detailBodyBuilder,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: widget.title,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWideScreen = constraints.maxWidth > widget.breakpoint;

          if (isWideScreen) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: widget.mainBuilder(context, (item) {
                    controller.selectedItemSubject.add(item);
                  }),
                ),
                Expanded(
                  flex: 2,
                  child: DataSubjectBuilder(
                    subject: controller.selectedItemSubject,
                    builder: (context, selectedItem) {
                      if (selectedItem == null) {
                        return Center(child: Text(context.cl.main_detail_select_item));
                      }
                      return widget.detailBodyBuilder(context, selectedItem);
                    },
                  ),
                ),
              ],
            );
          } else {
            return widget.mainBuilder(context, (item) {
              controller.selectedItemSubject.add(item);
              _openDetailPage(
                context: context,
                controller: controller,
                item: item,
                detailTitleBuilder: widget.detailTitleBuilder,
                detailBodyBuilder: widget.detailBodyBuilder,
              );
            });
          }
        },
      ),
    );
  }
}

Future<void> _openDetailPage<T>({
  required BuildContext context,
  required MainDetailContainerController<T> controller,
  required T item,
  required String Function(BuildContext context, T item) detailTitleBuilder,
  required Widget Function(BuildContext context, T item) detailBodyBuilder,
}) async {
  controller.isDetailPageOpenedAsRoute.add(true);
  await Routing.openPage(
    context,
    DetailPage<T>(
      item: item,
      detailTitleBuilder: detailTitleBuilder,
      detailBodyBuilder: detailBodyBuilder,
    ),
  );
  controller.isDetailPageOpenedAsRoute.add(false);
}

class DetailPage<T> extends StatelessWidget {
  final T item;
  final String Function(BuildContext context, T item) detailTitleBuilder;
  final Widget Function(BuildContext context, T item) detailBodyBuilder;

  const DetailPage({
    super.key,
    required this.item,
    required this.detailTitleBuilder,
    required this.detailBodyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: detailTitleBuilder(context, item),
      body: detailBodyBuilder(context, item),
    );
  }
}
