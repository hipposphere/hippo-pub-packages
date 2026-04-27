import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hotkey_api/src/utils/key_hid_map.dart';

class PhysicalKeyboardHelper {
  PhysicalKeyboardHelper._();

  // Windows may surface OEM/non-HID keys (for example Fn on some keyboards)
  // with vkCode 0xFF. This is not mappable to a USB HID keyboard usage.
  static const Set<int> _ignoredWindowsVirtualKeyCodes = {0xFF};

  static PhysicalKeyboardKey? fromPlatformKeyCode(int platformKeyCode) {
    if (Platform.isMacOS) {
      final usbHidCode = kMacOsToUsbHid[platformKeyCode];
      if (usbHidCode == null) {
        // ignore: avoid_print
        print(
          'Warning: No USB HID code mapping found for macOS key code: $platformKeyCode',
        );
        return null;
      }
      return PhysicalKeyboardKey.findKeyByCode(usbHidCode);
    } else if (Platform.isWindows) {
      if (_ignoredWindowsVirtualKeyCodes.contains(platformKeyCode)) {
        return null;
      }

      // Convert Windows virtual key code to USB HID usage code
      final usbHidCode = kWindowsToUsbHid[platformKeyCode];
      if (usbHidCode == null) {
        // ignore: avoid_print
        print(
          'Warning: No USB HID code mapping found for Windows virtual key code: $platformKeyCode',
        );
        return null;
      }
      return PhysicalKeyboardKey.findKeyByCode(usbHidCode);
    } else if (Platform.isLinux) {
      final usbHidCode = kLinuxToUsbHid[platformKeyCode];
      if (usbHidCode == null) {
        // ignore: avoid_print
        print(
          'Warning: No USB HID code mapping found for Linux XKB key code: $platformKeyCode',
        );
        return null;
      }
      return PhysicalKeyboardKey.findKeyByCode(usbHidCode);
    }
    return PhysicalKeyboardKey.findKeyByCode(platformKeyCode);
  }
}
