import 'package:flutter/services.dart';

class HotkeyEvent {
  final PhysicalKeyboardKey key;
  final HotkeyEventType type;

  const HotkeyEvent({required this.key, required this.type});
}

enum HotkeyEventType { down, up }
