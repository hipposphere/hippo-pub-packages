import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hotkey_api/hotkey_api.dart';

Future<void> openRawHotkeyApiExample(BuildContext context) async {
  final hotkeyBloc = RawHotkeyBloc();
  await Routing.openPage(
    context,
    BlocProvider<RawHotkeyBloc>(bloc: hotkeyBloc, child: RawHotkeyApiExample()),
  );
}

class RawHotkeyApiExample extends StatelessWidget {
  const RawHotkeyApiExample({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = RawHotkeyBloc.of(context);
    return PageContainer(
      title: 'Raw Hotkey API Example',
      body: CustomScrollView(
        controller: bloc.scrollController,
        slivers: [
          CombinedDataSubjectBuilder(
            subject1: bloc.isListeningSubject,
            subject2: bloc.filterKeysSubject,
            builder: (context, isListening, selectedKeys) {
              return SliverColumn(
                children: [
                  PaddedSectionHeader(text: 'Filtered Keys'),
                  if (selectedKeys == null)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No keys selected, all keys are listened to.',
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedKeys
                            .map((e) => Chip(label: Text(e.debugName ?? '')))
                            .toList(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: isListening
                          ? bloc.stopListening
                          : bloc.startListening,
                      child: Text(
                        isListening ? 'Stop Listening' : 'Start Listening',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: bloc.clearEvents,
                      child: const Text('Clear Events'),
                    ),
                  ),
                ],
              );
            },
          ),
          DataSubjectBuilder(
            subject: bloc.eventsSubject,
            builder: (context, events) {
              return SliverMainAxisGroup(
                slivers: [
                  SliverChild(
                    child: PaddedSectionHeader(text: 'Event History'),
                  ),
                  LimitedSliverPadded(sliver: _EventHistory(events: events)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

const _defaultFilterKeys = [
  PhysicalKeyboardKey.keyA,
  PhysicalKeyboardKey.keyB,
  PhysicalKeyboardKey.arrowUp,
];

class RawHotkeyBloc extends BlocBase {
  final filterKeysSubject = DataSubject<List<PhysicalKeyboardKey>?>.seeded(
    _defaultFilterKeys,
  );

  final eventsSubject =
      DataSubject<List<({DateTime dateTime, HotkeyEvent event})>>.seeded([]);

  final isListeningSubject = DataSubject<bool>.seeded(false);

  final ScrollController scrollController = ScrollController();

  StreamSubscription? _subscription;

  void startListening() {
    _subscription?.cancel();
    final keys = filterKeysSubject.value;
    _subscription = HotkeyApi.streamHotkeyEvents().listen((event) {
      if (event.key == null) return;
      if (keys != null && !keys.contains(event.key!)) return;
      final currentEvents = eventsSubject.value;
      eventsSubject.add([
        ...currentEvents,
        (dateTime: DateTime.now(), event: event),
      ]);
      // Auto scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
    isListeningSubject.add(true);
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    isListeningSubject.add(false);
  }

  void clearEvents() {
    eventsSubject.add([]);
  }

  void setSelectedKeys(List<PhysicalKeyboardKey> keys) {
    filterKeysSubject.add(keys);
    startListening();
  }

  @override
  void dispose() {
    eventsSubject.close();
  }

  static RawHotkeyBloc of(BuildContext context) {
    return BlocProvider.of<RawHotkeyBloc>(context);
  }
}

class _EventHistory extends StatelessWidget {
  final List<({DateTime dateTime, HotkeyEvent event})> events;
  const _EventHistory({required this.events});

  @override
  Widget build(BuildContext context) {
    return SliverBodyListItems(
      items: events,
      itemBuilder: (context, item) {
        final dateTime = item.dateTime;
        final event = item.event;
        return Text(
          "$dateTime: ${event.key?.debugName ?? event.key?.usbHidUsage} - ${event.type.name}",
        );
      },
    );
  }
}
