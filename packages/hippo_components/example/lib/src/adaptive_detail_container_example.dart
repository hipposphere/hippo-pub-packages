import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';

class Folder {
  final String id;
  final String title;
  final String description;

  const Folder({required this.id, required this.title, required this.description});
}

const folders = [
  Folder(
    id: 'alpha',
    title: 'Alpha Report',
    description: 'Shows how the adaptive container handles desktop and mobile layout.',
  ),
  Folder(
    id: 'bravo',
    title: 'Bravo Notes',
    description: 'Select another item from the list to replace the current detail route.',
  ),
  Folder(
    id: 'charlie',
    title: 'Charlie Inbox',
    description: 'On mobile, selection pushes a detail route and back pops to the list.',
  ),
  Folder(
    id: 'delta',
    title: 'Delta Timeline',
    description: 'A sample secondary item used for quick route updates.',
  ),
];

class AdaptiveDetailContainerExamplePage extends StatefulWidget {
  const AdaptiveDetailContainerExamplePage({super.key});

  @override
  State<AdaptiveDetailContainerExamplePage> createState() =>
      _AdaptiveDetailContainerExamplePageState();
}

class _AdaptiveDetailContainerExamplePageState extends State<AdaptiveDetailContainerExamplePage> {
  final _controller = AdaptiveDetailController<Folder>();

  Folder _selectAlternative(Folder current) {
    final index = folders.indexOf(current);
    final nextIndex = (index + 1) % folders.length;
    return folders[nextIndex];
  }

  void _selectFolder(Folder folder) {
    _controller.selectState(
      AdaptiveDetailContainerState<Folder>(data: folder, routeName: '/folder/${folder.id}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveDetailScaffold<Folder>(
      controller: _controller,
      desktopBuilder: (context, state) {
        final selected = state?.data;
        return Scaffold(
          appBar: AppBar(title: const Text('Adaptive Detail Container (Desktop)')),
          body: Row(
            children: [
              Expanded(
                child: FolderList(folders: folders, onSelect: _selectFolder),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: DetailPanel(
                  folder: selected,
                  onBack: null,
                  onSelectNext: selected == null
                      ? null
                      : () => _controller.selectState(
                          AdaptiveDetailContainerState<Folder>(
                            data: _selectAlternative(selected),
                            routeName: '/folder/${_selectAlternative(selected).id}',
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
      mobileBuilder: (context, state) {
        if (state == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Adaptive Detail Container (Mobile)')),
            body: FolderList(folders: folders, onSelect: _selectFolder),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(state.data.title),
            leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _controller.goBack),
          ),
          body: DetailPanel(
            folder: state.data,
            onBack: _controller.goBack,
            onSelectNext: () => _controller.selectState(
              AdaptiveDetailContainerState<Folder>(
                data: _selectAlternative(state.data),
                routeName: '/folder/${_selectAlternative(state.data).id}',
              ),
            ),
          ),
        );
      },
    );
  }
}

class FolderList extends StatelessWidget {
  const FolderList({required this.folders, required this.onSelect, super.key});

  final List<Folder> folders;
  final ValueChanged<Folder> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: folders.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final folder = folders[index];
        return ListTile(
          title: Text(folder.title),
          subtitle: Text(folder.description),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onSelect(folder),
        );
      },
    );
  }
}

class DetailPanel extends StatelessWidget {
  const DetailPanel({required this.folder, required this.onSelectNext, this.onBack, super.key});

  final Folder? folder;
  final VoidCallback? onBack;
  final VoidCallback? onSelectNext;

  @override
  Widget build(BuildContext context) {
    if (folder == null) {
      return const Center(child: Text('Select an item from the list.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(folder!.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(folder!.description),
              const SizedBox(height: 24),
              if (onBack != null) ElevatedButton(onPressed: onBack, child: const Text('Go back')),
              const SizedBox(height: 24),
              if (onSelectNext != null) ...[
                ElevatedButton(onPressed: onSelectNext, child: const Text('Open another item')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
