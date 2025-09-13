import 'package:flutter/services.dart';

int mapPhysicalKeyboardKey(PhysicalKeyboardKey key) {
  // This is a stub implementation. Replace with actual mapping logic.
  return key.usbHidUsage;
}

PhysicalKeyboardKey? unmapPhysicalKeyboardKey(int code) {
  // This is a stub implementation. Replace with actual unmapping logic.
  return PhysicalKeyboardKey.findKeyByCode(code);
}
