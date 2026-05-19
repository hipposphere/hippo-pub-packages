import 'package:flutter/material.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hotkey_api/hotkey_api.dart';

Future<void> openRawSelectHotkeysExample(BuildContext context) async {
  await Routing.openPage(context, RawSelectHotkeyExample());
}

class RawSelectHotkeyExample extends StatelessWidget {
  final DataSubject<Hotkey?> selectedHotkeySubject =
      DataSubject<Hotkey?>.seeded(null);
  RawSelectHotkeyExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Select Hotkey Example',
      body: CustomScrollView(
        slivers: [
          SliverGap(16),
          DataSubjectBuilder(
            subject: selectedHotkeySubject,
            builder: (context, selectedHotkey) {
              return SliverColumn(
                children: [
                  SectionHeaderWithActions(
                    label: 'Current Selection',
                    actions: [
                      TonalTappableChip(
                        leading: Icon(Icons.clear_outlined),
                        onTap: () {
                          selectedHotkeySubject.add(null);
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
                ],
              );
            },
          ),
          SliverGap(16),
          SliverChild(
            child: Button(
              onTap: () async {
                final hotkeys = await SelectHotkeyModal(
                  initialHotkey: selectedHotkeySubject.value,
                ).open(context);
                if (hotkeys != null) {
                  selectedHotkeySubject.add(hotkeys);
                }
              },
              label: 'Open Modal',
            ),
          ),
          SliverGap(16),
        ],
      ),
    );
  }
}
