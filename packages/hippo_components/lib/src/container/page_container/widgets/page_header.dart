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

class PageHeaderBackAction {
  // Visible in iOS/Cupertino
  final String? previousPageTitle;
  // If onPressed is null, the back button will pop the current route
  final void Function(BuildContext context)? onPressed;

  const PageHeaderBackAction({this.previousPageTitle, this.onPressed});
}

class PageHeader extends CupertinoNavigationBar {
  // By default a back button, which pops the current route
  final PageHeaderBackAction? backAction;
  final String? title;
  final WidgetBuilder? titleBuilder;
  // Back Action needs to be set to null to use a custom leading widget
  final Widget? customLeading;
  final Widget? customTrailing;
  final List<Widget> actions;

  PageHeader({
    super.key,
    super.border,
    super.backgroundColor,
    this.backAction = const PageHeaderBackAction(),
    this.customLeading,
    this.customTrailing,
    super.transitionBetweenRoutes,
    super.padding,
    required this.title,
    this.titleBuilder,
    this.actions = const [],
  }) : super(
         leading:
             customLeading ??
             (backAction != null ? _BackActionButton(backAction: backAction) : SizedBox()),
         middle: title != null
             ? Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)
             : (titleBuilder != null ? Builder(builder: titleBuilder) : null),
         trailing: customTrailing ?? Row(mainAxisSize: MainAxisSize.min, children: actions),
         automaticBackgroundVisibility: false,
       );
}

class PageHeaderDragRegion extends StatelessWidget implements ObstructingPreferredSizeWidget {
  final PageHeader child;
  final GestureDragStartCallback? onPanStart;
  final bool windowsOnly;

  const PageHeaderDragRegion({
    super.key,
    required this.child,
    this.onPanStart,
    this.windowsOnly = true,
  });

  @override
  Size get preferredSize => child.preferredSize;

  @override
  bool shouldFullyObstruct(BuildContext context) => child.shouldFullyObstruct(context);

  @override
  Widget build(BuildContext context) {
    final handler = (windowsOnly && defaultTargetPlatform != TargetPlatform.windows)
        ? null
        : onPanStart;
    if (handler == null) {
      return child;
    }
    return GestureDetector(behavior: .opaque, onPanStart: handler, child: child);
  }
}

class _BackActionButton extends StatelessWidget {
  final PageHeaderBackAction backAction;
  const _BackActionButton({required this.backAction});

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBarBackButton(
      previousPageTitle: backAction.previousPageTitle,
      onPressed: () {
        if (backAction.onPressed != null) {
          backAction.onPressed!(context);
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}

const Color _kDefaultNavBarBorderColor = Color(0x4D000000);

const Border kDefaultNavBarBorder = Border(
  bottom: BorderSide(
    color: _kDefaultNavBarBorderColor,
    width: 0.0, // 0.0 means one physical pixel
  ),
);

class PageHeaderLargeTitleSliver extends StatelessWidget {
  final String? title;
  final WidgetBuilder? titleBuilder;
  // By default a back button, which pops the current route
  final PageHeaderBackAction? backAction;
  final List<Widget> actions;
  final bool transitionBetweenRoutes;
  final Border? border;
  const PageHeaderLargeTitleSliver({
    super.key,
    required this.title,
    this.titleBuilder,
    this.backAction = const PageHeaderBackAction(),
    this.actions = const [],
    this.transitionBetweenRoutes = true,
    this.border = kDefaultNavBarBorder,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverNavigationBar(
      leading: backAction != null ? _BackActionButton(backAction: backAction!) : null,
      largeTitle: title != null
          ? Text(title!)
          : (titleBuilder != null ? titleBuilder!(context) : null),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: actions),
      border: border,
      transitionBetweenRoutes: transitionBetweenRoutes,
      automaticBackgroundVisibility: true,
    );
  }
}

class PageHeaderTappableAction extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? activeColor;
  final bool enabled;
  const PageHeaderTappableAction({
    super.key,
    required this.child,
    this.onTap,
    this.activeColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      onTap: enabled ? onTap : null,
      margin: EdgeInsets.all(4),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            color: (onTap != null && enabled)
                ? (activeColor ?? CupertinoColors.activeBlue)
                : CupertinoColors.inactiveGray,
            size: 24,
          ),
          child: DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: (onTap != null && enabled)
                  ? (activeColor ?? CupertinoColors.activeBlue)
                  : CupertinoColors.inactiveGray,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PageHeaderTextAction extends StatelessWidget {
  final Widget? icon;
  final String label;
  final Color? activeColor;
  final VoidCallback? onTap;
  final bool enabled;
  const PageHeaderTextAction({
    super.key,
    required this.label,
    this.activeColor,
    this.onTap,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PageHeaderTappableAction(
      onTap: onTap,
      enabled: enabled,
      activeColor: activeColor,
      child: Row(
        crossAxisAlignment: .center,
        mainAxisSize: .min,
        children: [
          if (icon != null) ...[icon!, Gap(4)],
          Text(label),
        ],
      ),
    );
  }
}

class PageHeaderSymbolAction extends StatelessWidget {
  final IconData iconData;
  final String? tooltip;
  final Color? activeColor;
  final VoidCallback? onTap;
  final bool enabled;
  const PageHeaderSymbolAction({
    super.key,
    required this.onTap,
    required this.iconData,
    this.tooltip,
    this.activeColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      onTap: enabled ? onTap : null,
      tooltip: tooltip,
      margin: EdgeInsets.all(4),
      child: Icon(
        iconData,
        color: (onTap != null && enabled)
            ? (activeColor ?? CupertinoColors.activeBlue)
            : CupertinoColors.inactiveGray,
        size: 24,
      ),
    );
  }
}

class RefreshPageHeaderSymbol extends StatelessWidget {
  final VoidCallback? onTap;
  final bool enabled;
  final bool showLoading;
  final Duration? toastLoadingDuration;
  const RefreshPageHeaderSymbol({
    super.key,
    required this.onTap,
    this.showLoading = false,
    this.enabled = true,
    this.toastLoadingDuration,
  });

  @override
  Widget build(BuildContext context) {
    return PageHeaderSymbolAction(
      onTap: () async {
        ToastRunner.runVoidCallbackWithToast(
          callback: onTap,
          successMessage: context.cl.toast_update_success,
          errorMessage: context.cl.toast_update_error,
          loadingMessage: (showLoading) ? context.cl.toast_loading : null,
          context: context,
          showProgressBar: showLoading,
          toastLoadingDuration: toastLoadingDuration,
        );
      },
      enabled: enabled,
      iconData: Icons.refresh_outlined,
      tooltip: context.cl.actions_refresh,
    );
  }
}
