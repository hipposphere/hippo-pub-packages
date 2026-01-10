part of '../page.dart';

class DictationEventLog extends StatelessWidget {
  const DictationEventLog({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = DictationTestingBloc.of(context);

    return Container(
      color: Colors.black.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Event Log',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Button(
                onTap: bloc.clearLog,
                prefix: const Icon(Icons.clear_outlined),
                label: 'Clear',
                type: ButtonType.outline,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SelectableRegion(
              selectionControls: materialTextSelectionControls,
              child: DataSubjectBuilder<List<String>>(
                subject: bloc.eventsSubject,
                builder: (context, logs) {
                  if (logs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No events yet.\n\nPress buttons on your dictation device to see events here.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: ScrollController(),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        logs[index],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
