import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hippo_utils/hippo_utils.dart';

class RawSelectHotkeysModalController {
  final Set<PhysicalKeyboardKey> initialKeys;
  final bool Function(PhysicalKeyboardKey key)? filter;

  RawSelectHotkeysModalController({
    required this.initialKeys,
    required this.filter,
  });

  final subject = DataSubject<Set<PhysicalKeyboardKey>>.seeded({});

  final isListeningSubject = DataSubject<bool>.seeded(false);

  Set<PhysicalKeyboardKey> get selectedKeys => subject.value;
}

class RawSelectHotkeysModalField extends StatelessWidget {
  final RawSelectHotkeysModalController controller;
  final Widget child;
  const RawSelectHotkeysModalField({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      child: child,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final key = event.physicalKey;
          if (controller.filter != null && !controller.filter!(key)) {
            return;
          }
          final selectedKeys = controller.selectedKeys;
          if (selectedKeys.contains(key)) {
            selectedKeys.remove(key);
          } else {
            selectedKeys.add(key);
          }
          controller.subject.add(Set.from(selectedKeys));
        }
      },
    );
  }
}
