import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

Future<void> openHotkeyStatusExample(BuildContext context) async {
  await Routing.openPage(context, HotkeyStatusExample());
}

class HotkeyStatusExample extends StatelessWidget {
  const HotkeyStatusExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Hotkey Status Example',
      body: const Placeholder(),
    );
  }
}
