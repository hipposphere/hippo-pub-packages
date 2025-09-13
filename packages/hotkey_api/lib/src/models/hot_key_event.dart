import 'package:flutter/services.dart';

class HotkeyEvent {
  final PhysicalKeyboardKey? key;
  final HotkeyEventType type;

  const HotkeyEvent({required this.key, required this.type});

  factory HotkeyEvent.fromMap(Map<dynamic, dynamic> map) {
    return HotkeyEvent(
      key: PhysicalKeyboardKey.findKeyByCode(map['key'] as int),
      type: switch (map['type'] as String) {
        'down' => HotkeyEventType.down,
        'up' => HotkeyEventType.up,
        _ => throw UnimplementedError(
          'Unknown HotkeyEventType: ${map['type']}',
        ),
      },
    );
  }
}

enum HotkeyEventType { down, up }
