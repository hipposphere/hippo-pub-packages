import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_api/src/utils/key_hid_map.dart';

void main() {
  test('Linux XKB key codes map to Flutter physical keys', () {
    expect(
      PhysicalKeyboardKey.findKeyByCode(kLinuxToUsbHid[0x26]!),
      PhysicalKeyboardKey.keyA,
    );
    expect(
      PhysicalKeyboardKey.findKeyByCode(kLinuxToUsbHid[0x25]!),
      PhysicalKeyboardKey.controlLeft,
    );
    expect(
      PhysicalKeyboardKey.findKeyByCode(kLinuxToUsbHid[0x40]!),
      PhysicalKeyboardKey.altLeft,
    );
    expect(
      PhysicalKeyboardKey.findKeyByCode(kLinuxToUsbHid[0x85]!),
      PhysicalKeyboardKey.metaLeft,
    );
  });

  test('macOS modifier key codes map to Flutter physical keys', () {
    expect(
      PhysicalKeyboardKey.findKeyByCode(kMacOsToUsbHid[0x38]!),
      PhysicalKeyboardKey.shiftLeft,
    );
    expect(
      PhysicalKeyboardKey.findKeyByCode(kMacOsToUsbHid[0x3B]!),
      PhysicalKeyboardKey.controlLeft,
    );
    expect(
      PhysicalKeyboardKey.findKeyByCode(kMacOsToUsbHid[0x3A]!),
      PhysicalKeyboardKey.altLeft,
    );
    expect(
      PhysicalKeyboardKey.findKeyByCode(kMacOsToUsbHid[0x37]!),
      PhysicalKeyboardKey.metaLeft,
    );
  });
}
