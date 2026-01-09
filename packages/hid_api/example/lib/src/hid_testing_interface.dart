import 'package:flutter/widgets.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

Future<void> openHidTestingInterface(BuildContext context) async {
  await Routing.openPage(context, HidTestingInterfacePage());
}

class HidTestingInterfacePage extends StatelessWidget {
  const HidTestingInterfacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(title: 'HID-Testing-Interface', body: Placeholder());
  }
}
