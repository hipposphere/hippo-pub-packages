import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:dictation_support_example/src/dictation_testing_interface/page.dart';
import 'package:dictation_support_example/src/simple_ui/page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App(brightness: Brightness.light, home: _HomePage()));
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      backAction: null,
      title: 'Dictation Support Example',
      body: CustomScrollView(
        slivers: [
          SliverGap(32),
          SliverColumn(
            children: [
              Gap(16),
              Button(
                onTap: () => openDictationTestingInterface(context),
                label: 'Open Testing Interface',
                prefix: const Icon(Icons.developer_mode),
              ),
              Gap(16),
              Button(
                onTap: () => openSimpleDictationUI(context),
                label: 'Open Simple UI',
                prefix: const Icon(Icons.touch_app),
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
