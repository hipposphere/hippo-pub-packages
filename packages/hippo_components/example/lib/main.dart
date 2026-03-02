import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'src/adaptive_detail_container_example.dart';
import 'src/json_schema_editor_example.dart';

void main() {
  runApp(const HippoComponentsExampleApp());
}

class HippoComponentsExampleApp extends StatelessWidget {
  const HippoComponentsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hippo Components Examples',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
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
    _ExampleEntry(
      title: 'JSON Schema Editor',
      description: 'Edit a JSON Schema and preview/validate fields in an interactive example.',
      builder: (_) => const JsonSchemaEditorExample(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hippo Components Examples')),
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
