import 'package:flutter/material.dart';
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
      title: 'Speech Recorder Example',
      body: Placeholder(),
    );
  }
}
