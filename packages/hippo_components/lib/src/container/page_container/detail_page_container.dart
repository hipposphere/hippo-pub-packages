import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class DetailPageContainer extends StatelessWidget {
  final String title;
  final Widget leading;
  final Widget? appBarBottom;
  final Widget child;
  final List<Widget> actions;
  final Color? backgroundColor;
  final PageHeaderBackAction backAction;
  const DetailPageContainer({
    super.key,
    required this.title,
    required this.leading,
    required this.child,
    this.appBarBottom,
    this.backgroundColor,
    this.actions = const [],
    this.backAction = const PageHeaderBackAction(),
  });

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: title,
      actions: actions,
      backAction: backAction,
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          if (appBarBottom != null) appBarBottom!,
          Expanded(
            child: Row(
              children: [
                leading,
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
