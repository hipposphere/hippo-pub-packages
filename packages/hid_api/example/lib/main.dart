import 'package:flutter/material.dart';
import 'package:hid_api_example/src/hid_testing_interface/page.dart';
import 'package:hippo_components/hippo_components.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(App(brightness: Brightness.light, home: _HomePage()));
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      backAction: null,
      title: 'HID API Example',
      body: CustomScrollView(
        slivers: [
          SliverGap(32),
          SliverColumn(
            children: [
              Button(
                onTap: () {
                  openHidTestingInterface(context);
                },
                label: 'HID Testing Interface',
              ),
              Gap(16),
            ],
          ),
          SliverGap(32),
        ],
      ),
    );
  }
}
