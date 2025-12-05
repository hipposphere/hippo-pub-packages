import 'dart:async';

import 'package:flutter/material.dart';
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
            subject2: bloc.selectedHotkeySubject,
            builder: (context, isListening, selectedHotkey) {
              return SliverColumn(
                children: [
                  SectionHeaderWithActions(
                    label: 'Current Selection',
                    actions: [
                      TonalTappableChip(
                        leading: Icon(Icons.keyboard_outlined),
                        onTap: () async {
                          final hotkey = await SelectHotkeyModal(
                            initialHotkey: selectedHotkey,
                          ).open(context);
                          if (hotkey != null) {
                            bloc.setHotkey(hotkey);
                          }
                        },
                        label: Text('Select'),
                      ),
                      TonalTappableChip(
                        leading: Icon(Icons.clear_outlined),
                        onTap: () {
                          bloc.selectedHotkeySubject.add(null);
                        },
                        label: Text('Clear'),
                      ),
                    ],
                  ),
                  Gap(8),
                  if (selectedHotkey != null)
                    HotkeyChip(hotkey: selectedHotkey)
                  else
                    Text('No hotkey selected, all keys are listened to.'),
                  Gap(8),

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

class RawHotkeyBloc extends BlocBase {
  final selectedHotkeySubject = DataSubject<Hotkey?>.seeded(null);

  final includeRepeatingSubject = DataSubject<bool>.seeded(false);

  final eventsSubject =
      DataSubject<List<({DateTime dateTime, HotkeyEvent event})>>.seeded([]);

  final isListeningSubject = DataSubject<bool>.seeded(false);

  final ScrollController scrollController = ScrollController();

  StreamSubscription? _subscription;

  void startListening() {
    _subscription?.cancel();
    final hotkey = selectedHotkeySubject.value;
    _subscription = HotkeyApi.streamHotkeyEvents().listen((event) {
      if (event.key == null) return;
      if (hotkey != null && !hotkey.containsPhysicalKey(event.key!)) return;
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

  void setHotkey(Hotkey hotkey) {
    selectedHotkeySubject.add(hotkey);
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
