import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_components/hippo_components.dart';
import 'package:hippo_core/hippo_core.dart';
import 'package:hippo_core_flutter/hippo_core_flutter.dart';
import 'package:hotkey_api/hotkey_api.dart';

class RawSelectHotkeyModalController {
  final Hotkey? initialHotkey;
  final bool Function(PhysicalKeyboardKey key)? allowedKeysFilter;

  RawSelectHotkeyModalController({
    required this.initialHotkey,
    required this.allowedKeysFilter,
  });

  final subject = DataSubject<Set<PhysicalKeyboardKey>>.seeded({});

  final isListeningSubject = DataSubject<bool>.seeded(false);

  void addKey(PhysicalKeyboardKey key) {
    final selectedKeys = Set.of(subject.value);
    selectedKeys.add(key);
    subject.add(selectedKeys);
  }

  void reset() {
    subject.add({});
  }
}

class RawSelectHotkeysModal extends StatelessWidget {
  final RawSelectHotkeyModalController controller;
  final Widget Function(
    BuildContext context,
    Set<PhysicalKeyboardKey> selectedKeys,
    VoidCallback resetSelection,
  )
  builder;
  const RawSelectHotkeysModal({
    super.key,
    required this.controller,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final key = event.physicalKey;
          if (controller.allowedKeysFilter != null &&
              controller.allowedKeysFilter!(key) == false) {
            return KeyEventResult.ignored;
          }
          controller.addKey(key);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: DataSubjectBuilder(
        subject: controller.subject,
        builder: (context, selectedKeys) {
          return builder(context, selectedKeys, () => controller.reset());
        },
      ),
    );
  }
}

class SelectHotkeyModal {
  final Hotkey? initialHotkey;
  final bool Function(PhysicalKeyboardKey key)? allowedKeysFilter;

  const SelectHotkeyModal({
    required this.initialHotkey,
    this.allowedKeysFilter,
  });

  Future<Hotkey?> open(BuildContext context) async {
    final controller = RawSelectHotkeyModalController(
      initialHotkey: initialHotkey,
      allowedKeysFilter: allowedKeysFilter,
    );

    final modal = AdaptiveCupertinoModal(
      builder: (context, _, scrollController) {
        return RawSelectHotkeysModal(
          controller: controller,
          builder: (context, selectedHotkeys, resetKeys) {
            return CupertinoModalPageContainer(
              title: Text('Select Hotkey'),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverGap(16),
                  SliverColumn(
                    children: [
                      Text(
                        'Press the desired keys on your keyboard to set a hotkey.',
                      ),
                      Gap(8),
                      if (selectedHotkeys.isNotEmpty)
                        HotkeyChip(
                          hotkey: Hotkey(physicalKeys: selectedHotkeys),
                        )
                      else
                        Text('No keys selected'),
                    ],
                  ),
                  SliverColumn(
                    children: [
                      Gap(16),
                      Button(
                        prefix: Icon(Icons.restore),
                        onTap: () {
                          resetKeys();
                        },
                        label: context.cl.actions_reset,
                        type: ButtonType.outline,
                      ),
                      Gap(8),
                      Button(
                        prefix: Icon(Icons.done),
                        onTap: () {
                          Navigator.pop(context, true);
                        },
                        label: context.cl.actions_done,
                      ),
                    ],
                  ),
                  SliverGap(16),
                ],
              ),
            );
          },
        );
      },
    );

    final result = await modal.show<bool>(context);

    if (result == true) {
      return Hotkey(physicalKeys: controller.subject.value);
    } else {
      return null;
    }
  }
}
