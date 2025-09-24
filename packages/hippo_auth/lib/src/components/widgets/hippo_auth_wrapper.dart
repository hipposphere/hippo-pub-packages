import 'package:flutter/material.dart';
import 'package:hippo_auth/hippo_auth.dart';

class HippoAuthWrapper extends StatelessWidget {
  final WidgetBuilder loadingBuilder;
  final WidgetBuilder loginBuilder;
  final WidgetBuilder childBuilder;
  const HippoAuthWrapper({
    super.key,
    required this.loadingBuilder,
    required this.loginBuilder,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return HippoAuthBuilder(
      builder: (context, value) {
        if (value == null) {
          return loadingBuilder(context);
        }
        final session = value.value;
        if (session == null) {
          return loginBuilder(context);
        } else {
          return childBuilder(context);
        }
      },
    );
  }
}
