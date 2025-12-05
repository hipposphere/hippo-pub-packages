import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hotkey_api/hotkey_api.dart';

enum HotkeyStatusType { pressed, released }

class HotkeyStatusController {
  HotkeyStatusController({Hotkey? initialHotkey}) {
    if (initialHotkey != null) {
      setHotkey(initialHotkey);
    }
    _initController();
  }

  StreamSubscription? _hotkeySubscription;

  // The Hotkey that should be listened on for the status
  final hotkeySubject = DataSubject<Hotkey?>.seeded(null);

  final pressedKeysSubject = DataSubject<Set<PhysicalKeyboardKey>>.seeded({});

  final statusSubject = DataSubject<HotkeyStatusType>.seeded(
    HotkeyStatusType.released,
  );

  void _initController() {
    _hotkeySubscription = HotkeyApi.streamHotkeyEvents().listen((event) {
      final eventKey = event.key;
      if (eventKey == null) return;
      final pressedKeys = pressedKeysSubject.value;
      if (hotkeySubject.value?.containsPhysicalKey(eventKey) == false) return;
      if (event.type == HotkeyEventType.down) {
        pressedKeysSubject.add({
          ...pressedKeys,
          if (event.key != null) event.key!,
        });
      } else if (event.type == HotkeyEventType.up) {
        pressedKeysSubject.add({
          ...pressedKeys.where((key) => key != event.key),
        });
      }
      _updateStatus();
    });
  }

  void _updateStatus() {
    final keys = pressedKeysSubject.value;
    final hotkey = hotkeySubject.value;

    final newStatus = hotkey?.isActive(keys) == true
        ? HotkeyStatusType.pressed
        : HotkeyStatusType.released;

    if (statusSubject.value != newStatus) {
      statusSubject.add(newStatus);
    }
  }

  Stream<HotkeyStatusType> streamHotkeyStatusType() {
    return statusSubject.stream;
  }

  void setHotkey(Hotkey hotkey) {
    hotkeySubject.add(hotkey);
    pressedKeysSubject.add({});
    statusSubject.add(HotkeyStatusType.released);
  }

  void close() {
    _hotkeySubscription?.cancel();
    hotkeySubject.close();
    pressedKeysSubject.close();
    statusSubject.close();
  }
}
