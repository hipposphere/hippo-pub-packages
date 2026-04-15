import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class PageHeaderOptionsButton extends StatelessWidget {
  final PullDownMenuItemBuilder itemBuilder;
  final Color? activeColor;
  const PageHeaderOptionsButton({super.key, required this.itemBuilder, this.activeColor});

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: itemBuilder,
      buttonBuilder: (context, showMenu) => PageHeaderSymbolAction(
        tooltip: context.cl.actions_more,
        onTap: showMenu,
        activeColor: activeColor,
        iconData: Icons.more_horiz_rounded,
      ),
    );
  }
}
