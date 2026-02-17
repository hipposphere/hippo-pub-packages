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

class CupertinoModalPageContainer extends StatelessWidget {
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final VoidCallback? onTapClose;
  final Widget child;
  const CupertinoModalPageContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.title,
    this.leading,
    this.trailing,
    this.onTapClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? context.onBrightness(light: Colors.white, dark: Colors.black),
      child: Column(
        children: [
          _Header(leading: leading, title: title, trailing: trailing, onTapClose: onTapClose),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(padding: EdgeInsetsGeometry.only(bottom: 16), child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class CupertinoModalContainer extends StatelessWidget {
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? title;
  final Widget? background;
  final Widget? trailing;
  final Widget child;
  const CupertinoModalContainer({
    super.key,

    required this.child,
    this.background,
    this.backgroundColor,
    this.title,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? context.onBrightness(light: Colors.white, dark: Colors.black),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ?background,
          SafeArea(top: false, child: child),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _Header(leading: leading, trailing: trailing, title: title),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final VoidCallback? onTapClose;
  const _Header({this.leading, this.title, this.trailing, this.onTapClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16, left: 16, right: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading ?? CupertinoModalCloseButton(onTap: onTapClose),
          Expanded(
            child: title == null
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(left: 32, right: 32),
                    child: Center(
                      child: DefaultTextStyle(
                        textAlign: TextAlign.center,
                        style: DefaultTextStyle.of(
                          context,
                        ).style.copyWith(fontSize: 18, fontWeight: FontWeight.w400),
                        child: title!,
                      ),
                    ),
                  ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class CupertinoModalCloseButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final IconData iconData;
  final VoidCallback? onTap;
  final String? tooltip;

  const CupertinoModalCloseButton({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
    this.iconData = Icons.close,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleTappable(
      color: backgroundColor,
      onTap:
          onTap ??
          () {
            Navigator.of(context).pop();
          },
      tooltip: tooltip,
      radius: BorderRadius.circular(32),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Icon(iconData, color: iconColor),
      ),
    );
  }
}
