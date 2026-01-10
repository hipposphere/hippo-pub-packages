import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hid_api/hid_api.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

part 'bloc.dart';
part 'widgets/device_list_sidebar.dart';
part 'widgets/control_panel.dart';
part 'widgets/event_log.dart';

Future<void> openHidTestingInterface(BuildContext context) async {
  await Routing.openPage(
    context,
    BlocProvider<HidTestingInterfaceBloc>(
      bloc: HidTestingInterfaceBloc(),
      child: const HidTestingInterfacePage(),
    ),
  );
}

class HidTestingInterfacePage extends StatelessWidget {
  const HidTestingInterfacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageContainer(
      title: 'HID-Testing-Interface',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DeviceListSidebar(),
          Expanded(
            child: Column(
              children: [
                Expanded(child: ControlPanel()),
                Divider(),
                Expanded(child: EventLog()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
