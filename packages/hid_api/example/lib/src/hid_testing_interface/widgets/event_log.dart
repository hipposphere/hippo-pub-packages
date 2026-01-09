part of '../page.dart';

class EventLog extends StatelessWidget {
  const EventLog({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = HidTestingInterfaceBloc.of(context);

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
                onTap: () => bloc.hidEventsSubject.add([]),
                label: 'Clear',
                type: ButtonType.secondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: DataSubjectBuilder<List<String>>(
              subject: bloc.hidEventsSubject,
              builder: (context, logs) {
                return ListView.builder(
                  controller: ScrollController(), // To stay at top normally
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
        ],
      ),
    );
  }
}
