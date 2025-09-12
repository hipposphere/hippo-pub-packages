import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double gap;
  const Gap(this.gap, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: gap, height: gap);
  }
}
