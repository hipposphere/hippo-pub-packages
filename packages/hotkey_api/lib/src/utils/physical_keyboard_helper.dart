import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hotkey_api/src/utils/key_hid_map.dart';

class PhysicalKeyboardHelper {
  PhysicalKeyboardHelper._();

  static PhysicalKeyboardKey? fromPlatformKeyCode(int platformKeyCode) {
    if (Platform.isMacOS) {
      // Convert macOS key code to USB HID usage code
      return kMacOsToPhysicalKey[platformKeyCode];
    } else if (Platform.isWindows) {
      // Convert Windows virtual key code to USB HID usage code
      final usbHidCode = kWindowsToUsbHid[platformKeyCode];
      return PhysicalKeyboardKey.findKeyByCode(usbHidCode!);
    } else if (Platform.isLinux) {
      return kLinuxToPhysicalKey[platformKeyCode];
    }
    return PhysicalKeyboardKey.findKeyByCode(platformKeyCode);
  }
}
