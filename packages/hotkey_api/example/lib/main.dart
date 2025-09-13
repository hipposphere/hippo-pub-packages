import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hotkey_api_example/pages/hotkey_status.dart';
import 'package:hotkey_api_example/pages/raw_hotkey_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(home: _HomePage()));
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Hotkey API Example',
      body: CustomScrollView(
        slivers: [
          SliverGap(32),
          SliverColumn(
            children: [
              Button(
                onTap: () {
                  openRawHotkeyApiExample(context);
                },
                label: 'Raw Hotkey API',
              ),
              Gap(16),
              Button(
                onTap: () {
                  openHotkeyStatusExample(context);
                },
                label: 'Hotkey Status',
              ),
            ],
          ),
          SliverGap(32),
        ],
      ),
    );
  }
}
