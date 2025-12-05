import 'package:flutter/services.dart';

class Hotkey {
  final Set<PhysicalKeyboardKey> physicalKeys;

  Hotkey({required this.physicalKeys}) : assert(physicalKeys.isNotEmpty);

  factory Hotkey.single(PhysicalKeyboardKey key) {
    return Hotkey(physicalKeys: {key});
  }

  factory Hotkey.fromMap(Map<String, dynamic> map) {
    return Hotkey(
      physicalKeys: List.from(map['physical_keys'])
          .map((e) => PhysicalKeyboardKey.findKeyByCode(e))
          .whereType<PhysicalKeyboardKey>()
          .toSet(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'physical_keys': physicalKeys.map((e) => e.usbHidUsage).toList()};
  }

  bool containsPhysicalKey(PhysicalKeyboardKey key) {
    return physicalKeys.contains(key);
  }

  bool isActive(Set<PhysicalKeyboardKey> pressedKeys) {
    return physicalKeys.every((key) => pressedKeys.contains(key));
  }
}
