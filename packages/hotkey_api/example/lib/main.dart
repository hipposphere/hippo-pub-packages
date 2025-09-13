import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hotkey_api/hotkey_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final hotkeyBloc = HotkeyBloc();
  runApp(
    BlocProvider<HotkeyBloc>(
      bloc: hotkeyBloc,
      child: const MaterialApp(home: Page()),
    ),
  );
}

const _defaultKeys = [
  PhysicalKeyboardKey.keyA,
  PhysicalKeyboardKey.keyB,
  PhysicalKeyboardKey.arrowUp,
];

class HotkeyBloc extends BlocBase {
  final selectedKeysSubject = DataSubject<List<PhysicalKeyboardKey>>.seeded(
    _defaultKeys,
  );

  final eventsSubject =
      DataSubject<List<({DateTime dateTime, HotkeyEvent event})>>.seeded([]);

  final isListeningSubject = DataSubject<bool>.seeded(false);

  final ScrollController scrollController = ScrollController();

  StreamSubscription? _subscription;

  void startListening() {
    _subscription?.cancel();
    final keys = selectedKeysSubject.value;
    _subscription = HotkeyApi.streamHotkeyEvents().listen((event) {
      if (event.key == null) return;
      if (!keys.contains(event.key!)) return;
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
    selectedKeysSubject.add(keys);
    startListening();
  }

  @override
  void dispose() {
    eventsSubject.close();
  }

  static HotkeyBloc of(BuildContext context) {
    return BlocProvider.of<HotkeyBloc>(context);
  }
}

class Page extends StatelessWidget {
  const Page({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = HotkeyBloc.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Hotkey API Example')),
      body: CustomScrollView(
        controller: bloc.scrollController,
        slivers: [
          CombinedDataSubjectBuilder(
            subject1: bloc.isListeningSubject,
            subject2: bloc.selectedKeysSubject,
            builder: (context, isListening, selectedKeys) {
              return SliverColumn(
                children: [
                  PaddedSectionHeader(text: 'Filtered Keys'),
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
