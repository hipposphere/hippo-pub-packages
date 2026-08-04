import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'src/adaptive_detail_container_example.dart';

void main() {
  runApp(const HippoComponentsExampleApp());
}

class HippoComponentsExampleApp extends StatelessWidget {
  const HippoComponentsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return App(
      brightness: .light,
      title: 'Hippo Components Examples',
      home: const ExampleCatalogPage(),
    );
  }
}

class ExampleCatalogPage extends StatelessWidget {
  const ExampleCatalogPage({super.key});

  static final _examples = <_ExampleEntry>[
    _ExampleEntry(
      title: 'Adaptive Detail Container',
      description:
          'Navigate between list and detail panes with adaptive behavior for mobile and desktop.',
      builder: (_) => const AdaptiveDetailContainerExamplePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      backAction: null,
      title: 'Hippo Components Examples',
      actions: [
        PageHeaderOptionsButton(
          itemBuilder: (context) => [
            PullDownMenuItem(onTap: () {}, title: 'Hallo'),
            PullDownMenuItem(onTap: () {}, title: 'Test'),
          ],
        ),
      ],
      body: CustomScrollView(
        slivers: [
          SliverGap(16),
          LimitedSliverPadded(
            sliver: SliverBodyListItems(
              items: _examples,
              spacing: 8,
              itemBuilder: (context, entry) => _ExampleTileCard(entry: entry),
            ),
          ),
          SliverGap(16),
        ],
      ),
    );
  }
}

class _ExampleEntry {
  const _ExampleEntry({required this.title, required this.description, required this.builder});

  final String title;
  final String description;
  final WidgetBuilder builder;
}

class _ExampleTileCard extends StatelessWidget {
  const _ExampleTileCard({required this.entry});

  final _ExampleEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: entry.builder));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(entry.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(entry.description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
