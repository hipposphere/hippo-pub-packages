/*
// ---------------------------------------------------------------------------
// Copyright (c) 2025 HippoSphere UG (haftungsbeschränkt). All rights reserved.
// Use, copying, modification, or distribution of this software is prohibited 
// without express written permission from Hipposphere UG.
//
// SPDX-License-Identifier: LicenseRef-Hipposphere-Proprietary
// ---------------------------------------------------------------------------
*/
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

class ListViewController<T> {
  final DataSubject<List<T>> subject;
  PageController pageController;
  ScrollController sideScrollController;
  final DataSubject<int> selectedIndexSubject;

  ListViewController({
    required this.subject,
    required this.pageController,
    required this.sideScrollController,
    required this.selectedIndexSubject,
  });

  void goBack() {
    final index = selectedIndexSubject.value;
    if (index > 0) {
      selectedIndexSubject.add(index - 1);
      if (pageController.positions.isNotEmpty) {
        pageController.animateToPage(
          index - 1,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeIn,
        );
      } else {
        pageController = PageController(initialPage: index - 1);
      }
    }
  }

  void goForward() {
    final index = selectedIndexSubject.value;
    if (index < subject.value.length - 1) {
      selectedIndexSubject.add(index + 1);
      if (pageController.positions.isNotEmpty) {
        pageController.animateToPage(
          index + 1,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeIn,
        );
      } else {
        pageController = PageController(initialPage: index + 1);
      }
    }
  }

  void selectIndex(int index, {bool updatePageController = true}) {
    selectedIndexSubject.add(index);
    if (updatePageController) {
      if (pageController.positions.isNotEmpty) {
        pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 250),
          curve: Curves.easeIn,
        );
      } else {
        pageController = PageController(initialPage: index);
      }
    }
  }

  int getIndex(T item) {
    final index = subject.value.indexOf(item);
    return index;
  }

  void updateItem(int index, T item) {
    final items = subject.value;
    items[index] = item;
    subject.add(items);
  }

  void addItem(T item) {
    final items = subject.value;
    items.add(item);
    subject.add(items);
  }

  void removeItem(T item) {
    final items = subject.value;
    items.remove(item);
    subject.add(items);

    if (selectedIndexSubject.value >= items.length) {
      selectIndex(items.length - 1);
    }
  }

  T get currentSelected {
    final index = selectedIndexSubject.value;
    return subject.value[index];
  }

  bool get canGoBack {
    return selectedIndexSubject.value > 0;
  }

  bool get canGoForward {
    return selectedIndexSubject.value < subject.value.length - 1;
  }

  bool handleKeyBackward() {
    if (!canGoBack) return false;
    goBack();
    return true;
  }

  bool handleKeyForward() {
    if (!canGoForward) return false;
    goForward();
    return true;
  }

  void scrollDownPx(double pixels) {
    if (sideScrollController.hasClients) {
      final maxOffset = sideScrollController.position.maxScrollExtent;
      sideScrollController.animateTo(
        min(sideScrollController.offset + pixels, maxOffset),
        duration: Duration(milliseconds: 250),
        curve: Curves.easeIn,
      );
    }
  }
}

class ListViewBuilder<T> extends StatelessWidget {
  final ListViewController<T> controller;
  final Widget Function(BuildContext context, List<T> items, int selectedIndex) builder;
  const ListViewBuilder({super.key, required this.controller, required this.builder});

  @override
  Widget build(BuildContext context) {
    return CombinedDataValueBuilder(
      value1: controller.subject,
      value2: controller.selectedIndexSubject,
      builder: (context, list, index) {
        return builder(context, list, index);
      },
    );
  }
}

class ListViewPageBuilder<T> extends StatelessWidget {
  final ListViewController<T> controller;
  final Widget Function(BuildContext context, List<T> items, PageController pageController) builder;
  const ListViewPageBuilder({super.key, required this.controller, required this.builder});

  @override
  Widget build(BuildContext context) {
    return DataSubjectBuilder(
      subject: controller.subject,
      builder: (context, list) {
        return builder(context, list, controller.pageController);
      },
    );
  }
}

class ListViewControlFlowBuilder<T> extends StatelessWidget {
  final ListViewController<T> controller;
  final Widget Function(BuildContext context, bool canGoBack, bool canGoForward, T? currentSelected)
  builder;
  const ListViewControlFlowBuilder({super.key, required this.controller, required this.builder});

  @override
  Widget build(BuildContext context) {
    return CombinedDataValueBuilder(
      value1: controller.subject,
      value2: controller.selectedIndexSubject,
      builder: (context, list, index) {
        if (list.isEmpty) {
          return builder(context, false, false, null);
        }
        final canGoBack = index > 0;
        final canGoForward = index < list.length - 1;
        return builder(context, canGoBack, canGoForward, list[index]);
      },
    );
  }
}
