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
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

class SimpleAdaptiveCupertinoModal {
  final Color? backgroundColor;
  final Widget? background;
  final Color? closeButtonIconColor;
  final Color? closeButtonBackgroundColor;
  final bool barrierDismissible;
  final Widget Function(BuildContext context, bool isDesktop) builder;

  SimpleAdaptiveCupertinoModal({
    this.backgroundColor,
    this.background,
    this.closeButtonIconColor,
    this.closeButtonBackgroundColor,
    this.barrierDismissible = false,
    required this.builder,
  });

  Future<T?> show<T>(BuildContext context) {
    final modal = AdaptiveCupertinoModal(
      barrierDismissible: barrierDismissible,
      builder: (context, isDesktop) {
        return CupertinoModalContainer(
          leading: CupertinoModalCloseButton(
            iconColor: closeButtonIconColor,
            backgroundColor: closeButtonBackgroundColor,
          ),
          backgroundColor: backgroundColor,
          background: background,
          child: builder(context, isDesktop),
        );
      },
    );
    return modal.show<T>(context);
  }
}

class SimplePageAdaptiveCupertinoModal {
  final Color? backgroundColor;
  final Color? closeButtonIconColor;
  final Color? closeButtonBackgroundColor;
  final bool barrierDismissible;
  final Widget Function(BuildContext context, bool isDesktop) builder;

  SimplePageAdaptiveCupertinoModal({
    this.backgroundColor,
    this.closeButtonIconColor,
    this.closeButtonBackgroundColor,
    this.barrierDismissible = false,
    required this.builder,
  });

  Future<T?> show<T>(BuildContext context) {
    final modal = AdaptiveCupertinoModal(
      barrierDismissible: barrierDismissible,
      builder: (context, isDesktop) {
        return CupertinoModalPageContainer(
          leading: CupertinoModalCloseButton(
            iconColor: closeButtonIconColor,
            backgroundColor: closeButtonBackgroundColor,
          ),
          backgroundColor: backgroundColor,

          child: builder(context, isDesktop),
        );
      },
    );
    return modal.show<T>(context);
  }
}

class AdaptiveCupertinoModal {
  final List<BlocDefiner> blocDefiners;
  final bool barrierDismissible;
  final Widget Function(BuildContext context, bool isDesktop) builder;

  AdaptiveCupertinoModal({
    this.barrierDismissible = true,
    required this.builder,
    this.blocDefiners = const [],
  });

  Future<T?> show<T>(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    if (size.width < 700) {
      return showCupertinoSheet<T>(
        context: context,
        builder: (context) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: Colors.black,
              systemNavigationBarIconBrightness: Brightness.light,
            ),

            child: Material(
              type: MaterialType.transparency,
              child: MultiBlocProvider(blocDefiners: blocDefiners, child: builder(context, false)),
            ),
          );
        },
      );
    }

    return showCupertinoModalPopup(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: MultiBlocProvider(
            blocDefiners: blocDefiners,
            child: LimitedContainerPadded(
              padding: EdgeInsets.all(32),
              maxWidth: 800,
              maxHeight: 750,
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: builder(context, true),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MultiPageAdaptiveCupertinoModal {
  final List<BlocDefiner> blocDefiners;
  final List<Widget> pages;
  final ValueNotifier<int> selectedPageIndex;
  final bool barrierDismissible;

  MultiPageAdaptiveCupertinoModal({
    required this.pages,
    required this.selectedPageIndex,
    this.barrierDismissible = false,
    this.blocDefiners = const [],
  });

  Future<T?> show<T>(BuildContext context) {
    final modal = AdaptiveCupertinoModal(
      blocDefiners: blocDefiners,
      barrierDismissible: barrierDismissible,
      builder: (context, isDesktop) {
        return ValueListenableBuilder(
          valueListenable: selectedPageIndex,
          builder: (context, selectedIndex, _) {
            return pages[selectedIndex];
          },
        );
      },
    );
    return modal.show<T>(context);
  }
}
