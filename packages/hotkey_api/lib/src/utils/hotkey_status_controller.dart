import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hippo_utils/hippo_utils.dart';
import 'package:hotkey_api/hotkey_api.dart';

enum HotkeyStatusType { pressed, released }

class HotkeyStatusController {
  HotkeyStatusController({Set<PhysicalKeyboardKey>? filterKeys}) {
    if (filterKeys != null) {
      setFilterKeys(filterKeys);
    }
    _initController();
  }

  StreamSubscription? _hotkeySubscription;

  // The KeyboardKeys that should be listened on for the status
  final filterKeysSubject = DataSubject<Set<PhysicalKeyboardKey>>.seeded({});

  final pressedKeysSubject = DataSubject<Set<PhysicalKeyboardKey>>.seeded({});

  void _initController() {
    _hotkeySubscription = HotkeyApi.streamHotkeyEvents().listen((event) {
      final pressedKeys = pressedKeysSubject.value;
      if (filterKeysSubject.value.contains(event.key) == false) return;
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
    });
  }

  Stream<HotkeyStatusType> streamHotkeyStatusType() {
    return pressedKeysSubject.stream.map((keys) {
      final filterKeys = filterKeysSubject.value;
      if (keys.containsAll(filterKeys) && filterKeys.isNotEmpty) {
        return HotkeyStatusType.pressed;
      } else {
        return HotkeyStatusType.released;
      }
    }).distinct();
  }

  void setFilterKeys(Set<PhysicalKeyboardKey> keys) {
    filterKeysSubject.add(keys);
    pressedKeysSubject.add({});
  }

  void close() {
    _hotkeySubscription?.cancel();
    filterKeysSubject.close();
    pressedKeysSubject.close();
  }
}
