import 'package:flutter/material.dart';
import 'package:hippo_auth/hippo_auth.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

void main() {
  final hippoAuthBloc = HippoAuthBloc.create(
    baseUrl: Uri.parse('http://localhost:3005/auth'),
    sessionStore: MockKeyValueStore(),
  );
  runApp(
    MultiBlocProvider(
      blocDefiners: [BlocDefiner<HippoAuthBloc>(bloc: hippoAuthBloc)],
      child: App(brightness: Brightness.light, home: HomePage()),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HippoAuthLoginApp();
  }
}
