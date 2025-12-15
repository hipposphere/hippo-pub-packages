import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:speech_recorder_example/pages/ui_elements.dart';

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
      title: 'Hotkey API Example',
      body: CustomScrollView(
        slivers: [
          SliverGap(32),
          SliverColumn(
            children: [
              Button(
                onTap: () {
                  openUIElementsExamplePage(context);
                },
                label: 'UI Elements',
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
