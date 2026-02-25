import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';

import 'pages/context_page.dart';
import 'pages/paste_datetime_page.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App(
      brightness: Brightness.light,
      title: 'Desktop Autopaste Example',
      home: _ExampleHomePage(),
    );
  }
}

class _ExampleHomePage extends StatelessWidget {
  const _ExampleHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Desktop Autopaste Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.icon(
              onPressed: () async {
                await Routing.openPage(context, const ContextPage());
              },
              icon: const Icon(Icons.text_snippet_outlined),
              label: const Text('Open Context Example'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                await Routing.openPage(context, const PasteDateTimePage());
              },
              icon: const Icon(Icons.paste_outlined),
              label: const Text('Open Paste DateTime Example'),
            ),
          ],
        ),
      ),
    );
  }
}
