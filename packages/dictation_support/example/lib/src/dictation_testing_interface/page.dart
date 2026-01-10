import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dictation_support/dictation_support.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

part 'bloc.dart';
part 'widgets/device_list.dart';
part 'widgets/button_visualizer.dart';
part 'widgets/led_control.dart';
part 'widgets/event_log.dart';

Future<void> openDictationTestingInterface(BuildContext context) async {
  await Routing.openPage(
    context,
    BlocProvider<DictationTestingBloc>(
      bloc: DictationTestingBloc(),
      child: const DictationTestingPage(),
    ),
  );
}

class DictationTestingPage extends StatelessWidget {
  const DictationTestingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageContainer(
      title: 'Dictation Device Testing',
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DictationDeviceList(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(child: ButtonVisualizer()),
                      VerticalDivider(),
                      Expanded(child: LedControlPanel()),
                    ],
                  ),
                ),
                Divider(),
                Expanded(child: DictationEventLog()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
