import 'package:app_release_client/app_release_client.dart';
import 'package:flutter/material.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';

void main() {
  runApp(const _ExampleApp());
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();

  @override
  Widget build(BuildContext context) {
    final bloc = AppReleaseClientBloc.create(
      baseUrl: Uri.parse('https://release-manager.example.com'),
      keyValueStore: MockKeyValueStore(),
      appSlug: 'desktop-app',
      platform: AppReleasePlatform.macos,
      // optional
      arch: AppReleaseArch.arm64,
      packageTypes: const ['dmg'],
      defaultChannelSlug: 'stable',
      currentVersion: '1.0.0',
    );

    return MaterialApp(
      home: BlocProvider<AppReleaseClientBloc>(
        bloc: bloc,
        child: const _ExampleHomePage(),
      ),
    );
  }
}

class _ExampleHomePage extends StatelessWidget {
  const _ExampleHomePage();

  @override
  Widget build(BuildContext context) {
    final bloc = AppReleaseClientBloc.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('app_release_client example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppReleaseChannelSelector(),
            const SizedBox(height: 12),
            AppReleaseClientBuilder(
              builder: (context, value) {
                final uri = value?.value;
                return SelectableText(
                  uri?.toString() ?? 'No appcast URL available.',
                );
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: bloc.refreshChannels,
              child: const Text('Refresh channels'),
            ),
          ],
        ),
      ),
    );
  }
}
