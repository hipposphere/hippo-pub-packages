import 'package:flutter/services.dart';
import '../utils/physical_keyboard_helper.dart';

class HotkeyEvent {
  final PhysicalKeyboardKey? key;
  final HotkeyEventType type;

  const HotkeyEvent({required this.key, required this.type});

  factory HotkeyEvent.fromMap(Map<dynamic, dynamic> map) {
    return HotkeyEvent(
      key: PhysicalKeyboardHelper.fromPlatformKeyCode(map['key']),
      type: switch (map['type']) {
        'down' => HotkeyEventType.down,
        'up' => HotkeyEventType.up,
        'repeat' => HotkeyEventType.repeat,
        _ => throw UnimplementedError(
          'Unknown HotkeyEventType: ${map['type']}',
        ),
      },
    );
  }
}

enum HotkeyEventType { down, up, repeat }
