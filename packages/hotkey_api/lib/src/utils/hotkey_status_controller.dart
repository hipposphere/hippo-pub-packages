import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

      if (hotkeySubject.value?.containsPhysicalKey(eventKey) == false) return;
      if (event.type == HotkeyEventType.down) {
        _addToPressedKeys(eventKey);
      } else if (event.type == HotkeyEventType.up) {
        _removeFromPressedKeys(eventKey);
      }
    });
  }

  /// Reloads the hotkey API by restarting the event stream subscription.
  ///
  /// This is useful when the app starts without permissions on macOS/iOS
  /// and the user grants them later in System Settings. After granting
  /// permissions, call this method to reinitialize the event stream.
  ///
  /// Example:
  /// ```dart
  /// final controller = HotkeyStatusController();
  ///
  /// // Later, after user grants permissions:
  /// if (await permissions.isAccessibilityGranted()) {
  ///   controller.reload();
  /// }
  /// ```
  void reload() {
    _hotkeySubscription?.cancel();
    pressedKeysSubject.add({});
    _initController();
  }

  void _addToPressedKeys(PhysicalKeyboardKey key) {
    final newSet = {...pressedKeysSubject.value, key};
    pressedKeysSubject.add(newSet);
    _updateStatus();
  }

  void _removeFromPressedKeys(PhysicalKeyboardKey key) {
    final newSet = {...pressedKeysSubject.value.where((k) => k != key)};
    pressedKeysSubject.add(newSet);
    _updateStatus();
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

  /// Might be used for Flutter apps to handle key events directly when they are
  /// not processed by HotkeyApi (e.g., web platform) or not propagated to the native
  /// side.
  KeyEventResult handleFlutterKeyEvent(KeyEvent event) {
    final key = event.physicalKey;
    if (hotkeySubject.value?.containsPhysicalKey(key) == false) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      _addToPressedKeys(key);
    } else if (event is KeyUpEvent) {
      _removeFromPressedKeys(key);
    }
    return KeyEventResult.handled;
  }

  Stream<HotkeyStatusType> streamHotkeyStatusType() {
    return statusSubject.stream;
  }

  void setHotkey(Hotkey hotkey) {
    hotkeySubject.add(hotkey);
    pressedKeysSubject.add({});
    _updateStatus();
  }

  void close() {
    _hotkeySubscription?.cancel();
    hotkeySubject.close();
    pressedKeysSubject.close();
    statusSubject.close();
  }
}
