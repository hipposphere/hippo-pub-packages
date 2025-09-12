import 'package:flutter/cupertino.dart';
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
  final List<Widget> actions;

  PageHeader({
    super.key,
    super.border,
    this.backAction = const PageHeaderBackAction(),
    super.transitionBetweenRoutes,
    required this.title,
    this.titleBuilder,
    required this.actions,
  }) : super(
         leading: backAction != null ? _BackActionButton(backAction: backAction) : null,
         middle: title != null
             ? Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)
             : (titleBuilder != null ? Builder(builder: titleBuilder) : null),
         trailing: Row(mainAxisSize: MainAxisSize.min, children: actions),
         automaticBackgroundVisibility: false,
       );
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
  final bool enabled;
  const PageHeaderTappableAction({super.key, required this.child, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      onTap: enabled ? onTap : null,
      margin: EdgeInsets.all(4),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            color: (onTap != null && enabled)
                ? CupertinoColors.activeBlue
                : CupertinoColors.inactiveGray,
            size: 24,
          ),
          child: DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: (onTap != null && enabled)
                  ? CupertinoColors.activeBlue
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
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  const PageHeaderTextAction({super.key, required this.label, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return PageHeaderTappableAction(onTap: onTap, enabled: enabled, child: Text(label));
  }
}

class PageHeaderSymbolAction extends StatelessWidget {
  final IconData iconData;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool enabled;
  const PageHeaderSymbolAction({
    super.key,
    required this.onTap,
    required this.iconData,
    this.tooltip,
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
            ? context.onBrightness(light: Colors.black, dark: Colors.white)
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
