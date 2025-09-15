import 'dart:io';
import 'package:flutter/services.dart';

class PhysicalKeyboardHelper {
  PhysicalKeyboardHelper._();

  static PhysicalKeyboardKey? fromPlatformKeyCode(int platformKeyCode) {
    if (Platform.isMacOS) {
      // Convert macOS key code to USB HID usage code
      return kMacOsToPhysicalKey[platformKeyCode];
    } else if (Platform.isWindows) {
      // Convert Windows virtual key code to USB HID usage code
      return kWindowsToPhysicalKey[platformKeyCode];
    } else if (Platform.isLinux) {
      return kLinuxToPhysicalKey[platformKeyCode];
    }
    return PhysicalKeyboardKey.findKeyByCode(platformKeyCode);
  }
}
