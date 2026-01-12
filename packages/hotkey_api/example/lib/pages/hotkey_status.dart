import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hotkey_api/hotkey_api.dart';

Future<void> openHotkeyStatusExample(BuildContext context) async {
  await Routing.openPage(
    context,
    BlocProvider<HotkeyStatusBloc>(
      bloc: HotkeyStatusBloc(),
      child: HotkeyStatusExample(),
    ),
  );
}

class HotkeyStatusExample extends StatelessWidget {
  const HotkeyStatusExample({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = HotkeyStatusBloc.of(context);
    return DataSubjectBuilder(
      subject: bloc.absorbSubject,
      builder: (context, absorb) {
        return _OptionalAbsorb(
          absorb: absorb,
          statusController: bloc.controller,
          child: PageContainer(
            title: 'Hotkey Status Example',
            body: CustomScrollView(
              slivers: [
                SliverGap(16),
                DataSubjectBuilder(
                  subject: bloc.controller.hotkeySubject,
                  builder: (context, selectedHotkey) {
                    return SliverColumn(
                      children: [
                        SectionHeaderWithActions(
                          label: 'Current Hotkey',
                          actions: [
                            TonalTappableChip(
                              leading: Icon(Icons.keyboard_outlined),
                              onTap: () async {
                                final hotkey = await SelectHotkeyModal(
                                  initialHotkey: selectedHotkey,
                                ).open(context);
                                if (hotkey != null) {
                                  bloc.controller.setHotkey(hotkey);
                                }
                              },
                              label: Text('Select'),
                            ),
                            TonalTappableChip(
                              leading: Icon(Icons.clear_outlined),
                              onTap: () {
                                bloc.controller.hotkeySubject.add(null);
                              },
                              label: Text('Clear Hotkeys'),
                            ),
                          ],
                        ),
                        Gap(8),
                        if (selectedHotkey != null)
                          HotkeyChip(hotkey: selectedHotkey)
                        else
                          Text('No hotkey selected'),
                        Gap(8),
                        SwitchListTile(
                          title: Text('Absorb Hotkey Events'),
                          value: bloc.absorbSubject.value,
                          onChanged: (value) {
                            bloc.absorbSubject.add(value);
                          },
                        ),
                        Gap(8),
                        Divider(),
                        Gap(8),
                      ],
                    );
                  },
                ),
                SliverGap(16),
                SliverChild(
                  child: Tile(
                    title: Text('Status:'),
                    trailing: DataSubjectBuilder(
                      subject: bloc.controller.statusSubject,
                      builder: (context, status) {
                        return Text(
                          status.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                ),
                SliverChild(child: PaddedSectionHeader(text: 'Event Log')),

                LimitedSliverPadded(
                  sliver: DataSubjectBuilder(
                    subject: bloc.eventsSubject,
                    builder: (context, events) {
                      return SliverBodyListItems(
                        items: events,
                        itemBuilder: (context, event) {
                          return Text(event);
                        },
                      );
                    },
                  ),
                ),
                SliverGap(16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OptionalAbsorb extends StatelessWidget {
  final HotkeyStatusController statusController;
  final bool absorb;
  final Widget child;
  const _OptionalAbsorb({
    required this.statusController,
    required this.absorb,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (absorb) {
      return FlutterHotkeyAbsorber(
        statusController: statusController,
        child: child,
      );
    } else {
      return child;
    }
  }
}

class HotkeyStatusBloc extends BlocBase {
  final controller = HotkeyStatusController();

  final absorbSubject = DataSubject.seeded(false);

  HotkeyStatusBloc() {
    controller.statusSubject.listen((status) {
      logEvent('${DateTime.now()}: Status changed to ${status.name}');
    });
  }

  final eventsSubject = DataSubject<List<String>>.seeded([]);

  void logEvent(String event) {
    final currentEvents = eventsSubject.value;
    final updatedEvents = List<String>.from(currentEvents)..add(event);
    eventsSubject.add(updatedEvents);
  }

  @override
  void dispose() {}

  static HotkeyStatusBloc of(BuildContext context) {
    return BlocProvider.of<HotkeyStatusBloc>(context);
  }
}
