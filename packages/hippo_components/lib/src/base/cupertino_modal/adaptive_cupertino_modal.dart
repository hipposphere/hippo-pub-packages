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
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

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
      builder: (context, isDesktop, scrollController) {
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
      builder: (context, isDesktop, scrollController) {
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
  final Widget Function(BuildContext context, bool isDesktop, ScrollController? scrollController)
  builder;

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
        scrollableBuilder: (context, scrollController) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: Colors.black,
              systemNavigationBarIconBrightness: Brightness.light,
            ),

            child: Material(
              type: MaterialType.transparency,
              child: MultiBlocProvider(
                blocDefiners: blocDefiners,
                child: builder(context, false, scrollController),
              ),
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
              child: _DesktopCupertinoModalFrame(
                borderRadius: BorderRadius.circular(16),
                child: builder(context, true, null),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DesktopCupertinoModalFrame extends StatelessWidget {
  final BorderRadius borderRadius;
  final Widget child;

  const _DesktopCupertinoModalFrame({required this.borderRadius, required this.child});

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness ?? Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.65 : 0.20),
            blurRadius: isDark ? 36 : 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: child,
        ),
      ),
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
      builder: (context, isDesktop, scrollController) {
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
